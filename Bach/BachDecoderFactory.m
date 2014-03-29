//
//  BachDecoderFactory.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachDecoderFactory.h"

#import "BachCoreAudioDecoder.h"
#import "BachFLACDecoder.h"

@implementation BachDecoderFactory

+(id<BachDecoder>) create: (NSString*) ext {
    if ([[BachFileTypes coreAudioFileTypes] containsObject:ext]) {
        return [[BachCoreAudioDecoder alloc] init];
    } else if ([[BachFileTypes flacFileTypes] containsObject:ext]) {
        return [[BachFLACDecoder alloc] init];
    } else {
        return nil;
    }
}

@end
