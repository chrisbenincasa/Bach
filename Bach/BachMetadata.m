//
//  BachMetadata.m
//  Bach
//
//  Created by Christian Benincasa on 3/11/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachCoreAudioMetadata.h"
#import "BachFileTypes.h"
#import "BachFLACMetadata.h"
#import "BachMetadata.h"

@implementation BachMetadata

+(id<BachMetadata>)metadataObjectForURL:(NSURL*)url
{
    NSString* extension = [url pathExtension];
    if ([[BachFileTypes coreAudioFileTypes] containsObject:extension]) {
        return [[BachCoreAudioMetadata alloc] initWithURL:url];
    } else if ([[BachFileTypes flacFileTypes] containsObject:extension]) {
        return [[BachFLACMetadata alloc] initWithURL:url];
    }
    
    return nil;
}

@end