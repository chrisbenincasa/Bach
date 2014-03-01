//
//  BachDispatch.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachDispatch.h"

@implementation BachDispatch

+(BachOperationQueue*) blocking_queue {
    static BachOperationQueue* blockingQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blockingQueue = [[BachOperationQueue alloc] init];
        [blockingQueue setMaxConcurrentOperationCount:1];
    });
    
    return blockingQueue;
}

+(BachOperationQueue*) operation_queue {
    static BachOperationQueue* operationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationQueue = [[BachOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:1];
    });
    
    return operationQueue;
}

@end
