//
//  Bach.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "Bach.h"

@implementation Bach

-(id) init {
    if (self = [super init]) {
        _volume = 100.0f;
        _error = nil;
        [self setState: Stopped];
        [self attachEventHandler];
    }
    
    return self;
}

#pragma mark public

-(void) playWithString:(NSString *)url {
    [self playWithUrl:[NSURL URLWithString:url]];
}

-(void) playWithUrl:(NSURL *)url {
    // If we're already playing, just reinit and flush the buffers
    if (_state == Playing) {
        dispatch_async([BachDispatch process_queue], ^{
            [_input openUrl:url];
            [_converter flush];
            [_converter setInput:_input];
            [_converter setOutput:_output];
            [_output setAmountPlayed:0.0];
            [self setState: Playing];
            dispatch_source_merge_data([BachDispatch buffer_dispatch_source], 1);
        });
        return;
    }
    
    dispatch_async([BachDispatch process_queue], ^{
        
#if __BACH_DEBUG
        BachStopwatch* stopwatch = [[BachStopwatch alloc] init];
        [stopwatch start];
#endif
        // TODO mess with buffer size.
        // Big buffer = less reads when using CoreAudio
        // Small buffer = lower latency when seeking
        _input = [[BachInput alloc] initWithBufferSize:(1024 * 128)];
        
        if (![_input openUrl:url]) {
#if __BACH_DEBUG
            NSLog(@"unable to open url @%@", [[NSString alloc] initWithString:[url absoluteString]]);
#endif
        }
        
#if __BACH_DEBUG
        NSLog(@"took %lu millis to init input", [stopwatch getElapsedMillis]);
        
        [stopwatch reset];
#endif
        _converter = [[BachConverter alloc] initWithBufferSize:(1024 * 128)];
        
        if (!_converter) {
#if __BACH_DEBUG
            NSLog(@"unable to initialize converter");
#endif
            return;
        }
        
        [_converter setupInput:_input];
        
#if __BACH_DEBUG
        NSLog(@"took %lu to init converter with input", [stopwatch getElapsedMillis]);
        
        [stopwatch reset];
#endif
        
        _output = [[BachOutput alloc] initWithConverter:_converter];
        
        if (!_output) {
#if __BACH_DEBUG
            NSLog(@"unabled to initialize output device");
#endif
            return;
        }
        
#if __BACH_DEBUG
        NSLog(@"took %lu to init output", [stopwatch getElapsedMillis]);
        
        [stopwatch reset];
#endif
        
        [_converter setupOutput:_output];
        
#if __BACH_DEBUG
        NSLog(@"took %lu to init converter with output", [stopwatch getElapsedMillis]);
#endif
        
        [self setState: Playing];
        
        dispatch_source_merge_data([BachDispatch buffer_dispatch_source], 1);
        dispatch_resume([BachDispatch buffer_dispatch_source]);
    });
}

#pragma mark Player Operations

-(void) pause {
    if ([_output playing]) {
        [_output pause];
        [self setState: Paused];
    }
}

-(void) resume {
    if (![_output playing]) {
        [_output resume];
        [self setState: Playing];
    }
}

-(void) stop {
    if ([_output playing] && [_output processing]) {
        [_output stop];
        self.output = nil;
        self.input = nil;
        self.converter = nil;
        [self setState: Stopped];
    }
}

-(void) seek:(float)position {
    if ([_output processing]) {
        [_output setAmountPlayed:position * [_output format].mBytesPerFrame * [_output format].mSampleRate];
        [_input seek:position flush:YES];
    }
}

#pragma mark Info Operations

-(double) currentTrackTime {
    return [_output secondsPlayed];
}

-(double) totalTrackTime {
    return [_input totalFrames] / [_output format].mSampleRate;
}

-(void) setVolume:(float) volume {
    _volume = volume;
    [_output setVolume: volume];
}

-(void) setState:(BachState) newState {
    _state = newState;
    NSDictionary* stateChangeInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[self state]], kBachStateKey, nil];
    NSNotification* stateChange = [NSNotification notificationWithName:kBachStateKey object:nil userInfo:stateChangeInfo];
    [[NSNotificationCenter defaultCenter] postNotification:stateChange];
}

-(NSDictionary*) metadata {
    return [_input metadata];
}

#pragma mark private

-(void) attachEventHandler {
    dispatch_source_set_event_handler([BachDispatch buffer_dispatch_source], ^{
        [_input decode];
        [_converter convert];
    });
}

@end
