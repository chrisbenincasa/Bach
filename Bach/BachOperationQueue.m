//
//  BachOperationQueue.m
//  Bach
//
//  Created by Christian Benincasa on 3/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachOperationQueue.h"

@implementation BachOperationQueue

-(id)init {
    if (self = [super init]) {
        self.resumed = NO;
    }
    
    return self;
}

-(void)resume {
    self.resumed = YES;
    
    [self addOperationWithBlock:self.callback];
}

-(void)performBlockRepeatedly:(void (^)(void))block {
    self.callback = block;
}

-(void)fireCallback {
    [self addOperationWithBlock:self.callback];
}

@end
