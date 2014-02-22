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
    dispatch_async([BachBuffer process_queue], ^{
        NSDate* date = [NSDate date];
        // TODO mess with buffer size.
        // Big buffer = less reads when using CoreAudio
        // Small buffer = lower latency when seeking
        _input = [[BachInput alloc] initWithBufferSize:(1024 * 128)];
        
        if (![_input openUrl:url]) {
#if __BACH_DEBUG
            NSLog(@"unable to open url @%@", [[NSString alloc] initWithString:[url absoluteString]]);
#endif
        }
        
        double timePassed = [date timeIntervalSinceNow] * -1000;
        NSLog(@"took %.2f to init input", timePassed);
        
        date = [NSDate date];

        _converter = [[BachConverter alloc] initWithBufferSize:(1024 * 128)];
        
        if (!_converter) {
#if __BACH_DEBUG
            NSLog(@"unable to initialize converter");
#endif
        }
        
        [_converter setupInput:_input];
        
        timePassed = [date timeIntervalSinceNow] * -1000;
        NSLog(@"took %.2f to init converter with input", timePassed);
        
        
        date = [NSDate date];
        _output = [[BachOutput alloc] initWithConverter:_converter];
        
        if (!_output) {
#if __BACH_DEBUG
            NSLog(@"unabled to initialize output device");
#endif
        }
        
        timePassed = [date timeIntervalSinceNow] * -1000;
        NSLog(@"took %.2f to init output", timePassed);
        
        date = [NSDate date];
        
        [_converter setupOutput:_output];
        
        timePassed = [date timeIntervalSinceNow] * -1000;
        NSLog(@"took %.2f to init conveter with output", timePassed);
        
        [self setState: Playing];
        
        dispatch_source_merge_data([BachBuffer buffer_dispatch_source], 1);
        dispatch_resume([BachBuffer buffer_dispatch_source]);
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
        [self setState: Stopped];
    }
}

-(void) seek:(float)position {
    if ([_output processing]) {
        [_output setAmountPlayed:position * [_output format].mBytesPerFrame * [_output format].mSampleRate];
        [_input seek:position flush:[_output playing]];
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
    dispatch_source_set_event_handler([BachBuffer buffer_dispatch_source], ^{
        [_input decode];
        [_converter convert];
    });
}

@end
