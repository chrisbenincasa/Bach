//
//  BachParserFactory.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachParserFactory.h"

#import "BachCoreAudioParser.h"
#import "BachFLACParser.h"

@implementation BachParserFactory

+(id<BachParser>) create: (NSString*) ext {
    if ([[BachFileTypes coreAudioFileTypes] containsObject:ext]) {
        return [[BachCoreAudioParser alloc] init];
    } else if ([[BachFileTypes flacFileTypes] containsObject:ext]) {
        return [[BachFLACParser alloc] init];
    } else {
        return nil;
    }
}

@end
