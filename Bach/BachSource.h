//
//  BachSource.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BachParserType.h"

@protocol BachSource <NSObject>

@required

@property(strong, nonatomic) NSURL* url;

-(BachParserType) parserType;

-(BOOL) open: (NSURL*) url;
-(int) read:(void *)buffer amount:(int) amount;
-(long) size;
-(BOOL) seek:(long)position whence:(int) whence;

@end
