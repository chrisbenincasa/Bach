//
//  BachOutput.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachConverter.h"
#import "BachHelper.h"

#import <Foundation/Foundation.h>

@class BachConverter;

@interface BachOutput : NSObject

@property(assign, nonatomic) unsigned long long amountPlayed;
@property(assign, nonatomic) BOOL playing;
@property(assign, nonatomic) BOOL processing;

@property(assign, nonatomic) AudioUnit output;
@property(assign, nonatomic) AURenderCallbackStruct callback;
@property(assign, nonatomic) AudioStreamBasicDescription format;

@property(strong, nonatomic) BachConverter* converter;

-(id) initWithConverter:(BachConverter*) converter;
-(void) process;
-(void) play;
-(void) pause;
-(void) stop;
-(void) resume;
-(double) secondsPlayed;
-(void) setVolume: (float) vol;
-(void) setSampleRate: (float) sampleRate;

@end
