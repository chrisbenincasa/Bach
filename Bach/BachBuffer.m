//
//  BachBuffer.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachBuffer.h"

@implementation BachBuffer

+(dispatch_queue_t) input_queue {
    static dispatch_queue_t queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        queue = dispatch_queue_create("bach.input.process", DISPATCH_QUEUE_SERIAL);
    });
    
    return queue;
}

+(dispatch_queue_t) process_queue {
    static dispatch_queue_t queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        queue = dispatch_queue_create("bach.process", DISPATCH_QUEUE_SERIAL);
    });
    
    return queue;
}

+(dispatch_source_t) buffer_dispatch_source {
    static dispatch_source_t source;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, [self process_queue]);
    });
    
    return source;
}

@end
