//
//  BachFileSource.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "BachSource.h"

@interface BachFileSource : NSObject<BachSource>

@property(assign, nonatomic) FILE* fd;

@end
