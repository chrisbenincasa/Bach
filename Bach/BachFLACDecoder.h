//
//  BachFLACDecoder.h
//  Bach
//
//  Created by Christian Benincasa on 2/5/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachFLACMetadata.h"
#import "BachDecoder.h"
#import "FLAC/all.h"

#import <Foundation/Foundation.h>

@interface BachFLACDecoder : NSObject <BachDecoder>

@property(assign, nonatomic) void* writeBuffer;
@property(assign, nonatomic) int bufferFrames;
@property(assign, nonatomic) long writeBufferSize;

@property(assign, nonatomic) FLAC__StreamDecoder* decoder;
@property(assign, nonatomic) UInt64 totalFrames;
@property(assign, nonatomic) UInt32 bitsPerChannel;
@property(assign, nonatomic) UInt32 bytesPerFrame;
@property(assign, nonatomic) UInt32 channels;
@property(assign, nonatomic) UInt32 sampleRate;

@end
