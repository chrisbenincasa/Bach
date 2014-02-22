//
//  BachParserPropertyKeys.h
//  Bach
//
//  Created by Christian Benincasa on 2/2/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BachParserPropertyKeys) {
    BIT_RATE,
    BYTES_PER_PACKET,
    BYTES_PER_FRAME,
    FRAMES_PER_PACKET,
    BITS_PER_CHANNEL,
    CHANNELS,
    TOTAL_FRAMES,
    SAMPLE_RATE,
    ENDIAN,
    UNSIGNED
};
