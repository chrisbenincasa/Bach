//
//  BachFileTypes.h
//  Bach
//
//  Created by Christian Benincasa on 3/11/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

@interface BachFileTypes : NSObject

+(NSArray*)coreAudioFileTypes;
+(NSArray*)flacFileTypes;

@end
