//
//  BachStopwatch.m
//  Bach
//
//  Created by Christian Benincasa on 2/22/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachStopwatch.h"

@implementation BachStopwatch

-(void) start {
    _began = [NSDate date];
}

-(void) reset {
    [self start];
}

-(unsigned long) getElapsedMillis {
    return [_began timeIntervalSinceNow] * -1000;
}

@end
