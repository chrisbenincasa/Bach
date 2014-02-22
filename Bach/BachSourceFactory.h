//
//  BachSourceFactory.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachSource.h"

#import <Foundation/Foundation.h>

@interface BachSourceFactory : NSObject

+(id<BachSource>) create: (NSURL*) url;

@end
