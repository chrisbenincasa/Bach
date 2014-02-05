//
//  BachHelper.m
//  Bach
//
//  Created by Christian Benincasa on 2/4/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachHelper.h"

@implementation BachHelper

+(BachHelper*) getInstance {
    static BachHelper* instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[BachHelper alloc] init];
    });
    return instance;
}

@end
