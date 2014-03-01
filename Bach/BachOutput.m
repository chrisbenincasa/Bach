//
//  BachOutput.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachOutput.h"

#import <AudioUnit/AudioUnit.h>

@implementation BachOutput

@synthesize playing = isPlaying;
@synthesize processing = isProcessing;

-(id) initWithConverter:(BachConverter*) converter {
    if (self = [super init]) {
        _output = NULL;
        [self setup];
        _converter = converter;
        _amountPlayed = 0;
    }
    
    return self;
}

-(void) process {
    isProcessing = YES;
    isPlaying = YES;
    __block OSStatus err;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        err = AudioOutputUnitStart(_output);
        if (err != 0) {
            NSLog(@"error playing shit");
        }
    }];
}

-(void) play {
    isProcessing = YES;
    isPlaying = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        AudioOutputUnitStart(_output);
    }];
}

-(void) pause {
    isPlaying = NO;
    AudioOutputUnitStop(_output);
}

-(void) resume {
    isPlaying = YES;
    AudioOutputUnitStart(_output);
}

-(void) stop {
    isPlaying = NO;
    isProcessing = NO;
    _amountPlayed = 0;
    AudioOutputUnitStop(_output);
}

-(void) setVolume: (float) vol {
    AudioUnitSetParameter(_output, kHALOutputParam_Volume, kAudioUnitScope_Global, 0, vol / 100.0f, 0);
}

-(void) mute {
    [self setVolume:0.0];
}

-(double) secondsPlayed {
    return (_amountPlayed / _format.mBytesPerFrame) / _format.mSampleRate;
}

-(BOOL) setup {
    OSStatus err;
    
    if (_output) {
        [self stop];
    }
    
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_DefaultOutput;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
  
    AudioComponent component = AudioComponentFindNext(NULL, &desc);
    if (!component) {
        NSLog(@"no component found");
        return NO;
    }
    
    err = AudioComponentInstanceNew(component, &_output);
    
    if (err != 0) {
        NSLog(@"unable to create new audio component instance, error code %d", err);
        return NO;
    }
    
    if (AudioUnitInitialize(_output) != 0) {
        NSLog(@"unable to init audio unit");
        return NO;
    }

    AudioStreamBasicDescription streamDesc;
    UInt32 size = sizeof(AudioStreamBasicDescription);
    Boolean writeable;
    
    AudioUnitGetPropertyInfo(_output, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &size, &writeable);
    err = AudioUnitGetProperty(_output, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &streamDesc, &size);
    
    if (err != 0) {
        NSLog(@"get property returned with error %d", err);
        return NO;
    }
    
    streamDesc.mChannelsPerFrame = 2;
    streamDesc.mFormatID = kAudioFormatLinearPCM;
    streamDesc.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    streamDesc.mBytesPerFrame = streamDesc.mChannelsPerFrame * (streamDesc.mBitsPerChannel / 8);
    streamDesc.mBytesPerPacket = streamDesc.mBytesPerFrame * streamDesc.mFramesPerPacket;
    
    err = AudioUnitSetProperty(_output, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamDesc, size);
    
    if (err != 0) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    _format = streamDesc;
    
    _callback.inputProc = renderCallback;
    _callback.inputProcRefCon = (__bridge void *)(self);
    
    err = AudioUnitSetProperty(_output, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &_callback, sizeof(AURenderCallbackStruct));
    
    if (err != 0) {
        NSLog(@"couldnt set output property");
    }
    
    return YES;
}

-(void) setSampleRate: (float)sampleRate {
    OSStatus err;
    UInt32 size = sizeof(AudioStreamBasicDescription);
    _format.mSampleRate = sampleRate;
    
    err = AudioUnitSetProperty(_output, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_format, size);
    
    if (err != 0) {
        NSLog(@"unable to set sample rate for output");
    }
    
    err = AudioUnitSetProperty(_output, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &_format, size);
    
    if (err != 0) {
        NSLog(@"unable to set sample rate for input");
    }
    [self setFormat:_format];
}

-(int)readData:(void*)to amount:(unsigned int) nBytes {
    if (!_converter) {
        // TODO: throw
        return 0;
    }
    
    long bytesRead = [[BachHelper getInstance] moveBytes:nBytes to:to from:[_converter convertedBytes]];
    _amountPlayed += bytesRead;
    
    if ([_converter shouldBuffer]) {
        [[BachDispatch operation_queue] fireCallback];
    }
    
    return (int) bytesRead;
}

static OSStatus renderCallback (void* inRefCon, AudioUnitRenderActionFlags* ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames,AudioBufferList * ioData) {
    
    @autoreleasepool {
        BachOutput* output = (__bridge BachOutput*)inRefCon;
        void* readPointer = ioData->mBuffers[0].mData;
        
        int bytesToRead = inNumberFrames * [output format].mBytesPerFrame;
        int bytesRead = [output readData:readPointer amount:bytesToRead];
        
        if (bytesRead < bytesToRead) {
            int bytesReRead = [output readData:(readPointer + bytesRead) amount:bytesToRead - bytesRead];
            bytesRead += bytesReRead;
        }
        
        ioData->mBuffers[0].mNumberChannels = [output format].mChannelsPerFrame;
        ioData->mBuffers[0].mDataByteSize = bytesRead;
        ioData->mNumberBuffers = 1;
    }
    
    return 0;
}

@end
