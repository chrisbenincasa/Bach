//
//  BachCoreAudioParser.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachDispatch.h"
#import "BachHelper.h"
#import "BachParser.h"

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BachCoreAudioParser : NSObject <BachParser>

@property(assign, nonatomic) AudioFileID audioFile;
@property(assign, nonatomic) ExtAudioFileRef extAudioFile;

@property(assign, nonatomic) UInt64 totalFrames;
@property(assign, nonatomic) Float64 bitRate;
@property(assign, nonatomic) UInt32 format;
@property(assign, nonatomic) UInt32 bitsPerChannel;
@property(assign, nonatomic) UInt32 bytesPerPacket;
@property(assign, nonatomic) UInt32 bytesPerFrame;
@property(assign, nonatomic) UInt32 framesPerPacket;
@property(assign, nonatomic) UInt32 channels;
@property(assign, nonatomic) UInt32 sampleRate;

@end
