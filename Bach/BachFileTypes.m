//
//  BachFileTypes.m
//  Bach
//
//  Created by Christian Benincasa on 3/11/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachFileTypes.h"

@implementation BachFileTypes

+(NSArray*)coreAudioFileTypes {
    NSArray* extensions;
    UInt32 size = sizeof(extensions);
    OSStatus err = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AllExtensions, 0, NULL, &size, &extensions);
    if (err != 0) {
        return nil;
    }
    
    return extensions;
}

+(NSArray*)flacFileTypes {
    return [NSArray arrayWithObject:@"flac"];
}

@end
