//
//  Bach.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BachBuffer.h"
#import "BachConverter.h"
#import "BachInput.h"
#import "BachOutput.h"

@interface Bach : NSObject

@property(strong, nonatomic) NSError *error;

@property(strong, nonatomic) BachInput* input;
@property(strong, nonatomic) BachConverter* converter;
@property(strong, nonatomic) BachOutput* output;

@property(assign, nonatomic) float volume;

-(void) playWithString:(NSString*) url;
-(void) playWithUrl:(NSURL*) url;
-(void) startPlayback:(NSURL*) url;;
-(void) attachEventHandler;

@end
