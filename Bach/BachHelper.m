//
//  BachHelper.m
//  Bach
//
//  Created by Christian Benincasa on 2/4/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachHelper.h"

@implementation BachHelper

+(BachHelper*) getInstance {
    static BachHelper* instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[BachHelper alloc] init];
    });
    return instance;
}

-(long) moveBytes:(unsigned int)nBytes to:(void*)to from:(NSMutableData*) from {
    long bytesToMove = (nBytes < [from length]) ? nBytes : [from length];
    dispatch_sync([BachBuffer input_queue], ^{
        memcpy(to, [from bytes], bytesToMove);
        [from replaceBytesInRange:NSMakeRange(0, bytesToMove) withBytes:NULL length:0];
    });
    
    return bytesToMove;
}

@end
