//
//  BachConverter.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachHelper.h"
#import "BachInput.h"
#import "BachOutput.h"

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class BachOutput;

@interface BachConverter : NSObject

// Constants
@property(assign, nonatomic) unsigned int readSize;
@property(assign, nonatomic) unsigned int bufferSize;

// Input & Output
@property(nonatomic) BachInput* input;
@property(nonatomic) BachOutput* output;

// Audio Info
@property(assign, nonatomic) AudioConverterRef converterRef;
@property(assign, nonatomic) AudioStreamBasicDescription inputInfo;
@property(assign, nonatomic) AudioStreamBasicDescription outputInfo;

// Buffers
@property(strong, nonatomic) NSMutableData* convertedBytes;
@property(assign, nonatomic) void* callbackBuffer;
@property(assign, nonatomic) void* toConvertBuffer;

-(id) initWithBufferSize:(unsigned int) nBytes;
-(void) setupInput:(BachInput *)input;
-(void) setupOutput:(BachOutput *)output;
-(void) convert;
-(BOOL) shouldBuffer;
-(void) flush;

@end
