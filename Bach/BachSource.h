//
//  BachSource.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachParserType.h"

#import <Foundation/Foundation.h>

@protocol BachSource <NSObject>

@required

@property(strong, nonatomic) NSURL* url;
@property(assign, nonatomic) long size;

-(BachParserType) parserType;

-(BOOL)open: (NSURL*) url;
-(int)read:(void *)buffer amount:(int) amount;
-(BOOL) seek:(long)position startingPosition:(int)startPos;
-(long)tell;
-(BOOL)endOfSource;

@end
