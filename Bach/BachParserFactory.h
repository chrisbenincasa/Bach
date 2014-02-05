//
//  BachParserFactory.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BachParserType.h"
#import "BachParser.h"

@protocol BachParser;

@interface BachParserFactory : NSObject

+(id<BachParser>) create: (BachParserType) type;

@end
