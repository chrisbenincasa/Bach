//
//  BachSourceFactory.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BachSource.h"

@interface BachSourceFactory : NSObject

+(id<BachSource>) create: (NSURL*) url;

@end
