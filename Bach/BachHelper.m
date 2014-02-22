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

-(void) printError:(OSStatus) error {
    char* str = malloc(8 * sizeof(char));
    if (str) {
        char* errorString = formatError(str, error);
        NSLog(@"%s", errorString);
        free(str);
        free(errorString);
    }
}

-(void) printError:(OSStatus) error withString:(NSString*) description {
    char* str = malloc(8 * sizeof(char));
    if (str) {
        char* errorString = formatError(str, error);
        NSLog(@"%@ %s", description, errorString);
        free(str);
        free(errorString);
    }
}

// http://stackoverflow.com/questions/2196869/how-do-you-convert-an-iphone-osstatus-code-to-something-useful
static char *formatError(char *str, OSStatus error) {
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    return str;
}

@end
