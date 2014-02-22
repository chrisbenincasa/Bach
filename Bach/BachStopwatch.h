//
//  BachStopwatch.h
//  Bach
//
//  Created by Christian Benincasa on 2/22/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BachStopwatch : NSObject

@property(strong, nonatomic) NSDate* began;

-(void) start;
-(void) reset;
-(unsigned long) getElapsedMillis;

@end
