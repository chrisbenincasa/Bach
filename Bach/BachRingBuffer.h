//
//  BachRingBuffer.h
//  Bach
//
//  Created by Christian Benincasa on 2/9/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BachRingBuffer : NSObject

@property(assign, nonatomic) float** data;
@property(assign, nonatomic) BOOL allocated;
@property(assign, nonatomic) SInt64 channels;
@property(assign, nonatomic) SInt64 bufferSize;
@property(strong, nonatomic) NSMutableArray* lastWrittenIndex;
@property(strong, nonatomic) NSMutableArray* lastReadIndex;
@property(strong, nonatomic) NSMutableArray* numUnreadFrames;

-(id)initWithBufferLength:(SInt64) bufferLength channels:(SInt64)numChannels;

-(void)addSigned16BitData:(const SInt16*)newData frames:(const SInt64) numFrames channel:(const SInt64) whichChannel;
-(void)fetchData:(float*) outData frames:(SInt64) numFrames channel:(SInt64) whichChannel;
-(void)clear;


@end
