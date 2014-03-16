//
//  BachParser.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachMetadata.h"
#import "BachParserPropertyKeys.h"
#import "BachSource.h"

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol BachSource;

@protocol BachParser <NSObject>

@property (nonatomic) AudioStreamBasicDescription description;
@property (strong, nonatomic) NSDictionary* properties;
@property (strong, nonatomic) id<BachMetadata> metadata;
@property (strong, nonatomic) id<BachSource> source;

@required
-(BOOL)openSource:(id<BachSource>) src;
-(int)readFrames:(void*) buffer frames:(UInt32) nFrames;
-(void)seek:(float) position;
-(void)flush;

@end