//
//  BachConverter.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BachInput.h"
#import "BachOutput.h"

@class BachOutput;

@interface BachConverter : NSObject

@property(assign, nonatomic) AudioConverterRef converterRef;

@property(nonatomic) BachInput* input;
@property(nonatomic) BachOutput* output;

@property(assign, nonatomic) AudioStreamBasicDescription inputInfo;
@property(assign, nonatomic) AudioStreamBasicDescription outputInfo;

@property(strong, nonatomic) NSMutableData* convertedBytes;
@property(assign, nonatomic) void* callbackBuffer;
@property(assign, nonatomic) void* toConvertBuffer;

-(void) setupInput:(BachInput *)input;
-(void) setupOutput:(BachOutput *)output;

-(void) convert;
-(void*) getConvertedBytes:(int) nBytes;
-(int) moveBytes:(void*) buffer bytes:(unsigned int) nBytes;
-(BOOL) shouldBuffer;

@end
