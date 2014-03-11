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
        _readSize = 1024 * 16;
        _bufferSize = 1024 * 128;
        _convertedBytes = [NSMutableData data];
        _toConvertBuffer = malloc(_readSize);
    }
    
    return self;
}

-(id) initWithBufferSize:(unsigned int) nBytes {
    if (self = [super init]) {
        _bufferSize = nBytes;
        _readSize = nBytes / 8;
        _convertedBytes = [NSMutableData data];
        _toConvertBuffer = malloc(_readSize);
    }
    
    return self;
}

-(void) dealloc {
    free(_toConvertBuffer);
    free(_callbackBuffer);
}

-(void) convert {
    int convertedAmount = 0;
    do {
        if ([_convertedBytes length] >= _bufferSize) {
            break;
        }
        
        convertedAmount = [self convertBytes:_toConvertBuffer bytes:_readSize];
        [[BachDispatch blocking_queue] addOperationWithBlock:^{
            [_convertedBytes appendBytes:_toConvertBuffer length: convertedAmount];
        }];
        [[BachDispatch blocking_queue] waitUntilAllOperationsAreFinished];
        
    } while (convertedAmount > 0);
    
    if (![output processing]) {
        if ([_convertedBytes length] < _bufferSize) {
            [[BachDispatch operation_queue] fireCallback];
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
    } else if (err == 100) {
        return 0;
    } else if (err != 0) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                             code:err
                                         userInfo:nil];
        NSLog(@"Error: %@", [error localizedDescription]);
        return 0;
    }
    
    return amountRead;
}

-(void) setupInput:(BachInput *)bachIn {
    self.input = bachIn;
    _inputInfo = [[self input] format];
}

-(void) setupOutput:(BachOutput *)bachOut {
    self.output = bachOut;
    [self.output setSampleRate:_inputInfo.mSampleRate];
    _outputInfo = [[self output] format];
    
    _callbackBuffer = malloc((_readSize / _outputInfo.mBytesPerFrame) * _inputInfo.mBytesPerPacket);
    
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

-(BOOL) shouldBuffer {
    return [_convertedBytes length] <= 0.5 * (_bufferSize) && ![input processing]; // TODO: Adjust this
}

-(void) flush {
    [[BachDispatch blocking_queue] addOperationWithBlock:^{
        self.convertedBytes = [NSMutableData data];
    }];
    [[BachDispatch blocking_queue] waitUntilAllOperationsAreFinished];
}

static OSStatus fillConverterCallback(AudioConverterRef inConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData) {
    
    BachConverter* converter = (__bridge BachConverter*) inUserData;
    
    int bytesToMove = (*ioNumberDataPackets) * [[converter input] format].mBytesPerPacket;
    long writeAmount = [[BachHelper getInstance] moveBytes:bytesToMove to:[converter callbackBuffer] from:[[converter input] buffer]];
    
    if (writeAmount == 0) {
        ioData->mBuffers[0].mDataByteSize = 0;
        *ioNumberDataPackets = 0;
        return 100;
    }
    
    ioData->mBuffers[0].mData = [converter callbackBuffer];
    ioData->mBuffers[0].mDataByteSize = writeAmount;
    ioData->mBuffers[0].mNumberChannels = 2;
    ioData->mNumberBuffers = 1;
    
    return 0;
}

@end
