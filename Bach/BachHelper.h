//
//  BachHelper.h
//  Bach
//
//  Created by Christian Benincasa on 2/4/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachBuffer.h"

#import <Foundation/Foundation.h>

@interface BachHelper : NSObject

+(BachHelper*) getInstance;

-(long) moveBytes:(unsigned int)nBytes to:(void*) to from:(NSMutableData*) from;

@end
