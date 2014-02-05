//
//  BachSourceFactory.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachSourceFactory.h"

#import "BachFileSource.h"

@implementation BachSourceFactory

+(id<BachSource>) create: (NSURL*) url {
    NSString* scheme = [url scheme];
    if ([scheme caseInsensitiveCompare:@"file"] == NSOrderedSame) {
        return [[BachFileSource alloc] init];
    }
    
    return nil;
}

@end
