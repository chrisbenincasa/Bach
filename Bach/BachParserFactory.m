//
//  BachParserFactory.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachParserFactory.h"

#import "BachCoreAudioParser.h"

@implementation BachParserFactory

+(id<BachParser>) create: (BachParserType) type {
    switch (type) {
        case CoreAudio:
            return [[BachCoreAudioParser alloc] init];
        default:
            return nil;
    }
}

@end
