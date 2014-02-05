//
//  BachInput.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachInput.h"

@implementation BachInput

@synthesize processing;

-(id) init {
    if (self = [super init]) {
        _buffer = [NSMutableData data];
        _inputBuf = malloc(1024 * 16);
    }
    
    return self;
}

-(id) initWithBufferSize:(unsigned int)nBytes {
    if (self = [super init]) {
        _buffer = [NSMutableData data];
        _inputBuf = malloc(nBytes);
    }
    return self;
}

-(void) dealloc {
    free(_inputBuf);
}

-(BOOL) openUrl:(NSURL *)url {
    _source = [BachSourceFactory create:url];
    
    if (!_source) {
        NSLog(@"unable to initialize source");
        return NO;
    }
    
    if (![_source open:url]) {
        NSLog(@"unable to open url within source");
        return NO;
    }
    
    _parser = [BachParserFactory create:[_source parserType]];
    
    if (!_parser) {
        NSLog(@"unable to initialize parser");
        return NO;
    }
    
    if (![_parser openSource:_source]) {
        NSLog(@"unable to open source within parser");
        return NO;
    }
    
    int bitsPerChannel = [[[_parser properties] objectForKey:[NSNumber numberWithInteger:BITS_PER_CHANNEL]] intValue];
    int channels = [[[_parser properties] objectForKey: [NSNumber numberWithInteger:CHANNELS]] intValue];
    _bytesPerFrame = (bitsPerChannel / 8) * channels;
    
    return YES;
}

-(void) decode {
    processing = YES;
    int bufferLength = 0;
    int framesRead = 0;
    
    while(processing && framesRead >= 0) {
        if ([_buffer length] >= 1024 * 128) {
            processing = NO;
            break;
        }
        
        framesRead = [_parser readFrames:_inputBuf frames:(16 * 1024) / _bytesPerFrame];
        bufferLength = framesRead * _bytesPerFrame;
        
        dispatch_sync([BachBuffer input_queue], ^{
            [_buffer appendBytes:_inputBuf length:bufferLength];
        });
    }
    
    if (framesRead < 0) {
        _atEnd = YES;
    }
    
    processing = NO;
}

-(int) moveBytes:(void*) buffer bytes:(int) nBytes {
    int bytesToRead = (nBytes < [_buffer length]) ? nBytes : (int)[_buffer length];
    
    dispatch_sync([BachBuffer input_queue], ^{
        memcpy(buffer, [_buffer bytes], bytesToRead);
        [_buffer replaceBytesInRange:NSMakeRange(0, bytesToRead) withBytes:NULL length:0];
    });
    
    return bytesToRead;
}

-(AudioStreamBasicDescription) format {
    AudioStreamBasicDescription desc;
    desc.mFormatID = kAudioFormatLinearPCM;
    desc.mFormatFlags = 0;
    
    desc.mSampleRate = [[[_parser properties] objectForKey:[NSNumber numberWithInteger:SAMPLE_RATE]] doubleValue];
    desc.mBitsPerChannel = [[[_parser properties] objectForKey:[NSNumber numberWithInteger:BITS_PER_CHANNEL]] intValue];
    desc.mChannelsPerFrame = [[[_parser properties] objectForKey:[NSNumber numberWithInteger:CHANNELS]] intValue];
    desc.mBytesPerFrame = (desc.mBitsPerChannel / 8) * desc.mChannelsPerFrame;
    
    desc.mFramesPerPacket = 1;
    desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
    desc.mReserved = 0;
    
    if ([[[_parser properties] objectForKey:[NSNumber numberWithInteger:ENDIAN]] isEqualToString:@"big"]) {
        desc.mFormatFlags |= kLinearPCMFormatFlagIsBigEndian;
        desc.mFormatFlags |= kLinearPCMFormatFlagIsAlignedHigh;
    }
    
    if ([[[_parser properties] objectForKey:[NSNumber numberWithInteger:UNSIGNED]] boolValue] == NO) {
        desc.mFormatFlags |= kLinearPCMFormatFlagIsSignedInteger;
    }
    
    return desc;
}

@end
