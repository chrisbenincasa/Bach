//
//  BachOperationQueue.m
//  Bach
//
//  Created by Christian Benincasa on 3/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachOperationQueue.h"

@implementation BachOperationQueue

-(void)registerCallbackWithBlock:(void (^)(void))block {
    self.callback = block;
}

-(void)fireCallback {
    if (self.callback) {
        [self addOperationWithBlock:self.callback];
    }
}

@end
