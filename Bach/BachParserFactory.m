//
//  BachParserFactory.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachParserFactory.h"

#import "BachCoreAudioParser.h"
#import "BachFlacParser.h"

@implementation BachParserFactory

+(id<BachParser>) create: (NSString*) ext {
    if ([[BachCoreAudioParser fileTypes] containsObject:ext]) {
        return [[BachCoreAudioParser alloc] init];
    } else if ([[BachFlacParser fileTypes] containsObject:ext]) {
        return [[BachFlacParser alloc] init];
    } else {
        return nil;
    }
}

@end
