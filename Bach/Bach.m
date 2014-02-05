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
        [self attachEventHandler];
    }
    
    return self;
}

-(void) playWithString:(NSString *)url {
    [self playWithUrl:[NSURL URLWithString:url]];
}

-(void) playWithUrl:(NSURL *)url {
    dispatch_async([BachBuffer process_queue], ^{
        _input = [[BachInput alloc] initWithBufferSize:(1024 * 128)];
        
        if (![_input openUrl:url]) {
            NSLog(@"unable to open url @%@", [[NSString alloc] initWithString:[url absoluteString]]);
        }
        
        _converter = [[BachConverter alloc] init];
        
        if (!_converter) {
            NSLog(@"unable to initialize converter");
        }
        
        [_converter setupInput:_input];
        
        _output = [[BachOutput alloc] initWithConverter:_converter];
        
        if (!_output) {
            NSLog(@"unabled to initialize output device");
        }
        
        [_converter setupOutput:_output];
        
        dispatch_source_merge_data([BachBuffer buffer_dispatch_source], 1);
        dispatch_resume([BachBuffer buffer_dispatch_source]);
        
        NSLog(@"success! @%@", [[NSString alloc] initWithString:[url absoluteString]]);
    });
}

-(void) attachEventHandler {
    dispatch_source_set_event_handler([BachBuffer buffer_dispatch_source], ^{
        [_input decode];
        [_converter convert];
    });
}

-(void) setVolume:(float)volume {
    _volume = volume;
    [_output setVolume: volume];
}

@end
