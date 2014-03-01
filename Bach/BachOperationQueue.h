//
//  BachOperationQueue.h
//  Bach
//
//  Created by Christian Benincasa on 3/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BachOperationQueue : NSOperationQueue

@property (nonatomic, copy) void (^callback)(void);

-(void)registerCallbackWithBlock:(void(^)(void))block;
-(void)fireCallback;

@end
