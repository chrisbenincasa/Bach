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
    
    self.source = [BachSourceFactory create:url];
    
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
    
    self.decoder = [BachDecoderFactory create:[url pathExtension]];
    
    if (!_decoder) {
#if BACH_DEBUG
        NSLog(@"unable to initialize parser");
#endif
        return NO;
    }
    
    if (![_decoder openSource:_source]) {
#if BACH_DEBUG
        NSLog(@"unable to open source within parser");
#endif
        return NO;
    }
    
    int bitsPerChannel = [[[_decoder properties] objectForKey:[NSNumber numberWithInteger:BITS_PER_CHANNEL]] intValue];
    int channels = [[[_decoder properties] objectForKey: [NSNumber numberWithInteger:CHANNELS]] intValue];
    _bytesPerFrame = (bitsPerChannel / 8) * channels;
    
    [self setAtEnd:NO];
    
    return YES;
}

-(void) decode {
    processing = YES;
    int bufferLength = 0;
    int framesRead = 0;
    
    do {
        if ([_buffer length] >= _bufferSize) {
            framesRead = 1;
            break;
        }
        
        framesRead = [_decoder readFrames:_inputBuf frames:(_readSize / _bytesPerFrame)];
        bufferLength = framesRead * _bytesPerFrame;

        [[BachDispatch blocking_queue] addOperationWithBlock:^{
            [_buffer appendBytes:_inputBuf length:bufferLength];
        }];
        [[BachDispatch blocking_queue] waitUntilAllOperationsAreFinished];
    } while (framesRead > 0);
    
    if (framesRead <= 0) {
        [self setAtEnd:YES];
        NSDictionary* stateChangeInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], kBachEndOfInputKey, nil];
        NSNotification* stateChange = [NSNotification notificationWithName:kBachEndOfInputKey object:nil userInfo:stateChangeInfo];
        [[NSNotificationCenter defaultCenter] postNotification:stateChange];
    }
    
    processing = NO;
}

-(void) seek:(float) time flush:(BOOL) flush {
    _seekPosition = time * [[[_decoder properties] objectForKey:[NSNumber numberWithInteger:SAMPLE_RATE]] floatValue];
    if (flush) {
        [[BachDispatch blocking_queue] addOperationWithBlock:^{
            [_buffer setLength:0];
        }];
        [[BachDispatch blocking_queue] waitUntilAllOperationsAreFinished];
        [_decoder flush];
    }
    [_decoder seek: _seekPosition];
}

-(double) totalFrames {
    return [[[_decoder properties] objectForKey:[NSNumber numberWithInteger:TOTAL_FRAMES]] doubleValue];
}

-(AudioStreamBasicDescription) format {
    AudioStreamBasicDescription desc;
    desc.mFormatID = kAudioFormatLinearPCM;
    desc.mFormatFlags = 0;
    
    desc.mSampleRate = [[[_decoder properties] objectForKey:[NSNumber numberWithInteger:SAMPLE_RATE]] doubleValue];
    desc.mBitsPerChannel = [[[_decoder properties] objectForKey:[NSNumber numberWithInteger:BITS_PER_CHANNEL]] intValue];
    desc.mChannelsPerFrame = [[[_decoder properties] objectForKey:[NSNumber numberWithInteger:CHANNELS]] intValue];
    desc.mBytesPerFrame = (desc.mBitsPerChannel / 8) * desc.mChannelsPerFrame;
    
    desc.mFramesPerPacket = 1;
    desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
    desc.mReserved = 0;
    
    if ([[[_decoder properties] objectForKey:[NSNumber numberWithInteger:ENDIAN]] isEqualToString:@"big"]) {
        desc.mFormatFlags |= kLinearPCMFormatFlagIsBigEndian;
        desc.mFormatFlags |= kLinearPCMFormatFlagIsAlignedHigh;
    }
    
    if ([[[_decoder properties] objectForKey:[NSNumber numberWithInteger:UNSIGNED]] boolValue] == NO) {
        desc.mFormatFlags |= kLinearPCMFormatFlagIsSignedInteger;
    }
    
    return desc;
}

-(id<BachMetadata>) metadata {
    return [_decoder metadata];
}

@end
