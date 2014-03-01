//
//  BachCoreAudioParser.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachCoreAudioParser.h"

@implementation BachCoreAudioParser

@synthesize description;
@synthesize properties;
@synthesize source;
@synthesize metadata;

+(NSArray*) fileTypes {
    NSArray* extensions;
    UInt32 size = sizeof(extensions);
    OSStatus err = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AllExtensions, 0, NULL, &size, &extensions);
    if (err != 0) {
        return nil;
    }
    
    return extensions;
}

-(void) dealloc {
    ExtAudioFileDispose(_extAudioFile);
    AudioFileClose(_audioFile);
    [source close];
}

-(NSDictionary*) properties {
    return [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithFloat:_bitRate], [NSNumber numberWithInteger:BIT_RATE],
     [NSNumber numberWithInteger:_bytesPerPacket], [NSNumber numberWithInteger:BYTES_PER_PACKET],
     [NSNumber numberWithInteger:_bytesPerFrame], [NSNumber numberWithInteger:BYTES_PER_FRAME],
     [NSNumber numberWithInteger:_bitsPerChannel], [NSNumber numberWithInteger:BITS_PER_CHANNEL],
     [NSNumber numberWithInteger:_framesPerPacket], [NSNumber numberWithInteger:FRAMES_PER_PACKET],
     [NSNumber numberWithInteger:_channels], [NSNumber numberWithInteger:CHANNELS],
     [NSNumber numberWithInteger:_totalFrames], [NSNumber numberWithInteger:TOTAL_FRAMES],
     [NSNumber numberWithInteger:_sampleRate], [NSNumber numberWithInteger:SAMPLE_RATE],
     @"big", [NSNumber numberWithInteger:ENDIAN], nil];
}

-(int) readBytes:(void*) buffer bytes:(UInt32) nBytes {
    UInt32 framesToRead = nBytes / _bytesPerFrame;
    return [self readFrames:buffer frames:framesToRead] * _bytesPerFrame;
}

-(int) readFrames:(void*) buffer frames:(UInt32) nFrames {
    OSStatus err;
    AudioBufferList buffers;
    
    buffers.mNumberBuffers = 1;
    buffers.mBuffers[0].mNumberChannels = _channels;
    buffers.mBuffers[0].mDataByteSize = (_bitsPerChannel / 8) * nFrames * _channels;
    buffers.mBuffers[0].mData = buffer;
    
    err = ExtAudioFileRead(_extAudioFile, &nFrames, &buffers);
    if (err != 0) {
        return 0;
    }
    
    return nFrames;
}

-(int) readPackets:(void*) buffer packets:(UInt32) nPackets {
    UInt32 packetsToRead = nPackets * _framesPerPacket;
    return [self readFrames:buffer frames:packetsToRead] / _framesPerPacket;
}

-(void) seek:(float)position {
    OSStatus err;
    err = ExtAudioFileSeek(_extAudioFile, position);
#if BACH_DEBUG
    if (!err) {
        NSLog(@"unable to seek to position");
    }
#endif
}

-(void) flush {
    // NOP
}

-(BOOL) openSource:(id<BachSource>) src {
    self.source = src;
    OSStatus err;
    
    err = AudioFileOpenWithCallbacks((__bridge void*) source, readAudioFile, NULL, getSizeProc, NULL, 0, &_audioFile);
    
    if (err != 0) {
#if __BACH_DEBUG
        [[BachHelper getInstance] printError:err withString:@"unable to open audio file. error code:"];
#endif
        return NO;
    }
    
    err = ExtAudioFileWrapAudioFileID(_audioFile, NO, &_extAudioFile);
    
    if (err != 0) {
#if __BACH_DEBUG
        [[BachHelper getInstance] printError:err withString:@"unable to wrap audio file. error code:"];
#endif
        return NO;
    }
    
    if([self initializeAudioFileInfo]) {
        return YES;
    } else {
#if __BACH_DEBUG
        NSLog(@"unable to init audio file info.");
#endif
        return NO;
    }
}

-(BOOL) initializeAudioFileInfo {
    OSStatus err;
    AudioStreamBasicDescription basicDesc;
    UInt32 size = sizeof(basicDesc);
    
    err = ExtAudioFileGetProperty(_extAudioFile, kExtAudioFileProperty_FileDataFormat, &size, &basicDesc);
    
    if (err != 0) {
        return NO;
    }
    
    /*
     // double buffer size fo 128K
     UInt32 bufferSizeBytes = 1024 * 128;
     UInt32 uint32Size = sizeof(UInt32);
    
     err = ExtAudioFileSetProperty(_extAudioFile, kExtAudioFileProperty_IOBufferSizeBytes, uint32Size, &bufferSizeBytes);
    */
    
    // TODO: doing this synchroniously seems to be bottleneck...investigate more
    [[BachDispatch operation_queue] addOperationWithBlock:^{
        SInt64 totalSize;
        UInt32 size = sizeof(totalSize);
        OSStatus err = ExtAudioFileGetProperty(_extAudioFile, kExtAudioFileProperty_FileLengthFrames, &size, &totalSize);
        
        if (err != 0) {
            ExtAudioFileDispose(_extAudioFile);
        }
        
        _totalFrames = totalSize;
    }];

    AudioFileID audioFile;
    size = sizeof(audioFile);
    err = ExtAudioFileGetProperty(_extAudioFile, kExtAudioFileProperty_AudioFile, &size, &audioFile);
    
    if (err == 0) {
        // Load metadata asynchroniously?
        UInt32 dictionarySize = 0;
        err = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyInfoDictionary, &dictionarySize, 0);
        if (!err) {
            CFDictionaryRef dictionary;
            AudioFileGetProperty(audioFile, kAudioFilePropertyInfoDictionary, &dictionarySize, &dictionary);
            self.metadata = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)dictionary];
            CFRelease(dictionary);
        }
    }

    AudioStreamBasicDescription result;
    bzero(&result, sizeof(AudioStreamBasicDescription));
    
    _bitRate = 0;
    _bitsPerChannel = (basicDesc.mBitsPerChannel != 0) ? basicDesc.mBitsPerChannel : 16;
    _channels = basicDesc.mChannelsPerFrame;
    _sampleRate = basicDesc.mSampleRate;
    
    result.mFormatID = kAudioFormatLinearPCM;
    result.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian;
    
    result.mSampleRate = _sampleRate;
    result.mChannelsPerFrame = _channels;
    result.mBitsPerChannel = _bitsPerChannel;
    
    result.mBytesPerPacket = _channels * (_bitsPerChannel / 8);
    result.mFramesPerPacket = 1;
    result.mBytesPerFrame = _channels * (_bitsPerChannel / 8);
    
    err = ExtAudioFileSetProperty(_extAudioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(result), &result);
    
    if (err != 0) {
        return NO;
    }
    
    description = result;
    _format = kAudioFormatLinearPCM;
    _framesPerPacket = 1;
    _bytesPerPacket = _channels * (_bitsPerChannel / 8);
    
    return YES;
}

static OSStatus readAudioFile(void* clientData, SInt64 inPosition, UInt32 requestCount, void* buffer, UInt32* actualCount) {
    id<BachSource> src = (__bridge id<BachSource>) clientData;
    [src seek:(long)inPosition startingPosition:0];
    *actualCount = [src read:buffer amount:requestCount];
    return 0;
}

static SInt64 getSizeProc(void* clientData) {
    id<BachSource> source = (__bridge id<BachSource>) clientData;
    return [source size];
}

@end
