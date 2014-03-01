//
//  BachDispatch.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachOperationQueue.h"

#import <Foundation/Foundation.h>

@interface BachDispatch : NSObject

+(BachOperationQueue*) operation_queue;
+(BachOperationQueue*) blocking_queue;

@end
