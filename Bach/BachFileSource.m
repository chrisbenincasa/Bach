//
//  BachFileSource.m
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachFileSource.h"

@implementation BachFileSource

@synthesize url;
@synthesize size;

-(BachParserType) parserType {
    return CoreAudio;
}

-(BOOL) open:(NSURL *)newUrl {
	[self setUrl:newUrl];
	_fd = fopen([[self.url path] UTF8String], "rb");
    if (_fd != NULL) {
        fseek (_fd, 0, SEEK_END);
        self.size = ftell(_fd);
        rewind(_fd);
        return YES;
    } else {
        return NO;
    }
}

-(int) read:(void *)buffer amount:(int)amount {
	return fread(buffer, 1, amount, _fd);
}

-(long)tell {
    return ftell(_fd);
}

-(BOOL) seek:(long)position startingPosition:(int)startPos {
	return (fseek(_fd, position, startPos) == 0);
}

-(BOOL) endOfSource {
    return ftell(_fd) == SEEK_END;
}

@end
