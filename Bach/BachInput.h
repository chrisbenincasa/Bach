//
//  BachInput.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BachDispatch.h"
#import "BachParser.h"
#import "BachParserFactory.h"
#import "BachParserPropertyKeys.h"
#import "BachSource.h"
#import "BachSourceFactory.h"

@interface BachInput : NSObject

@property(assign, nonatomic) unsigned int bufferSize;
@property(assign, nonatomic) unsigned int readSize;

@property(strong, nonatomic) NSMutableData* buffer;
@property(assign, nonatomic) void* inputBuf;

@property(strong, nonatomic) id<BachSource> source;
@property(strong, nonatomic) id<BachParser> parser;
@property(assign, nonatomic) int bytesPerFrame;
@property(assign, nonatomic) int bytesPerPacket;

@property(assign, nonatomic, readonly) BOOL processing;
@property(assign, nonatomic, readonly) BOOL atEnd;
@property(assign, nonatomic) BOOL shouldSeek;
@property(assign, nonatomic) float seekPosition;

-(id) initWithBufferSize:(unsigned int) nBytes;
-(BOOL) openUrl: (NSURL*) url;
-(void) decode;
-(void) seek:(float) time flush:(BOOL) flush;
-(double)totalFrames;
-(AudioStreamBasicDescription) format;
-(NSDictionary*) metadata;

@end
