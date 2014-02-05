//
//  BachConverter.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachConverter.h"

@implementation BachConverter

@synthesize input;
@synthesize output;

-(id) init {
    if (self = [super init]) {
        _convertedBytes = [NSMutableData data];
        _toConvertBuffer = malloc(1024 * 16);
    }
    
    return self;
}

-(void) dealloc {
    free(_toConvertBuffer);
    free(_callbackBuffer);
}

-(void) convert {
    int convertedAmount = 0;
    while (convertedAmount >= 0) {
        if ([_convertedBytes length] >= 1024 * 128) {
            break;
        }
        
        convertedAmount = [self convertBytes:_toConvertBuffer bytes:16 * 1024];
        dispatch_sync([BachBuffer input_queue], ^{
            [_convertedBytes appendBytes:_toConvertBuffer length: convertedAmount];
        });
    }
    
    if (![output processing]) {
        if ([_convertedBytes length] < 1024 * 128) {
            dispatch_source_merge_data([BachBuffer buffer_dispatch_source], 1);
            return;
        }
        [output process];
    }
}

-(int) convertBytes: (void*) buffer bytes:(UInt32) nBytes {
    OSStatus err;
    AudioBufferList buffers;
    
    buffers.mNumberBuffers = 1;
    buffers.mBuffers[0].mData = buffer;
    buffers.mBuffers[0].mDataByteSize = nBytes;
    buffers.mBuffers[0].mNumberChannels = _outputInfo.mChannelsPerFrame;
    
    UInt32 framesToConvert = nBytes / _outputInfo.mBytesPerFrame;
    
    err = AudioConverterFillComplexBuffer(_converterRef, fillConverterCallback, (__bridge void *)(self), &framesToConvert, &buffers, NULL);
    
    int amountRead = buffers.mBuffers[0].mDataByteSize;
    if (err == kAudioConverterErr_InvalidInputSize)	{
        amountRead += [self convertBytes:buffer + amountRead bytes:nBytes - amountRead];
    }
    
    if (err != 0) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                             code:err
                                         userInfo:nil];
        NSLog(@"Error: %@", [error localizedDescription]);
        return 0;
    }
    
    return amountRead;
}

-(void) setupInput:(BachInput *)input {
    self.input = input;
    _inputInfo = [[self input] format];
}

-(void) setupOutput:(BachOutput *)output {
    self.output = output;
    _outputInfo = [[self output] format];
    
    [self.output setSampleRate:_inputInfo.mSampleRate];
    
    _callbackBuffer = malloc((1024 * 16 / _outputInfo.mBytesPerFrame) * _inputInfo.mBytesPerPacket);
    
    OSStatus err = AudioConverterNew(&_inputInfo, &_outputInfo, &_converterRef);
    
    if (err != 0) {
        NSLog(@"Error creating converter");
    }
    
    if (_inputInfo.mChannelsPerFrame == 1) {
        SInt32 channelMap[2] = {0, 0};
        
        err = AudioConverterSetProperty(_converterRef, kAudioConverterChannelMap, sizeof(channelMap), &channelMap);
        
        if (err != 0) {
            NSLog(@"fucked up");
        }
    }
}

-(int) moveBytes:(void*) buffer bytes:(unsigned int) nBytes {
    long bytesToRead = (nBytes < [_convertedBytes length]) ? nBytes : [_convertedBytes length];
    
    dispatch_sync([BachBuffer input_queue], ^{
        memcpy(buffer, [_convertedBytes bytes], bytesToRead);
        [_convertedBytes replaceBytesInRange:NSMakeRange(0, bytesToRead) withBytes:NULL length:0];
    });
    
    return bytesToRead;
}

-(BOOL) shouldBuffer {
    return [_convertedBytes length] <= 0.5 * (1024 * 128) && ![input processing];
}

static OSStatus fillConverterCallback(AudioConverterRef inConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData) {
    
    BachConverter* converter = (__bridge BachConverter*) inUserData;
    
    int bytesToMove = (*ioNumberDataPackets) * [[converter input] format].mBytesPerPacket;
    int writeAmount = [[converter input] moveBytes:[converter callbackBuffer] bytes:bytesToMove];
    
    ioData->mBuffers[0].mData = [converter callbackBuffer];
    ioData->mBuffers[0].mDataByteSize = writeAmount;
    ioData->mBuffers[0].mNumberChannels = 2;
    ioData->mNumberBuffers = 1;
    
    if (writeAmount == 0) {
        return 100;
    }
    
    return 0;
}

@end
