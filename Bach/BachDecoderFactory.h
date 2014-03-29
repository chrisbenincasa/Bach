//
//  BachDecoderFactory.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BachFileTypes.h"
#import "BachDecoderType.h"
#import "BachDecoder.h"

@protocol BachDecoder;

@interface BachDecoderFactory : NSObject

+(id<BachDecoder>) create: (NSString*) ext;

@end
