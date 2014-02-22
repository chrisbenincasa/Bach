//
//  BachDispatch.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BachDispatch : NSObject

+ (dispatch_queue_t) input_queue;
+ (dispatch_queue_t) process_queue;
+ (dispatch_source_t) buffer_dispatch_source;

@end
