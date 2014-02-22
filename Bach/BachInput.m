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
        _bufferSize = 1024 * 128;
        _readSize = _bufferSize / 8;
        _buffer = [NSMutableData data];
        _inputBuf = malloc(_readSize);
    }
    
    return self;
}

-(id) initWithBufferSize:(unsigned int) nBytes {
    if (self = [super init]) {
        _bufferSize = nBytes;
        _readSize = _bufferSize / 8;
        _buffer = [NSMutableData data];
        _inputBuf = malloc(_readSize);
    }
    return self;
}

-(void) dealloc {
    free(_inputBuf);
}

-(BOOL) openUrl:(NSURL *)url {
    _source = [BachSourceFactory create:url];
    
    if (!_source) {
#if BACH_DEBUG
        NSLog(@"unable to initialize source");
#endif
        return NO;
    }
    
    if (![_source open:url]) {
#if BACH_DEBUG
        NSLog(@"unable to open url within source");
#endif
        return NO;
    }
    
    _parser = [BachParserFactory create:[url pathExtension]];
    
    if (!_parser) {
#if BACH_DEBUG
        NSLog(@"unable to initialize parser");
#endif
        return NO;
    }
    
    if (![_parser openSource:_source]) {
#if BACH_DEBUG
        NSLog(@"unable to open source within parser");
#endif
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
        if ([_buffer length] >= _bufferSize) {
            processing = NO;
            break;
        }
        
        framesRead = [_parser readFrames:_inputBuf frames:(_readSize / _bytesPerFrame)];
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

-(void) seek:(float) time flush:(BOOL) flush {
    _seekPosition = time * [[[_parser properties] objectForKey:[NSNumber numberWithInteger:SAMPLE_RATE]] floatValue];
    if (flush) {
        dispatch_sync([BachBuffer input_queue], ^{
            [_buffer setLength:0];
        });
        [_parser flush];
    }
    [_parser seek: _seekPosition];
}

-(double) totalFrames {
    return [[[_parser properties] objectForKey:[NSNumber numberWithInteger:TOTAL_FRAMES]] doubleValue];
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

-(NSDictionary*) metadata {
    return [_parser metadata];
}

@end
