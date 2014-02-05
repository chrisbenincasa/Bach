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

-(BachParserType) parserType {
    return CoreAudio;
}

-(long) size {
    long curpos = ftell(_fd);
    fseek (_fd, 0, SEEK_END);
    long size = ftell(_fd);
    fseek(_fd, curpos, SEEK_SET);
	return size;
}

-(BOOL) open:(NSURL *)url {
	[self setUrl:url];
	_fd = fopen([[self.url path] UTF8String], "r");
	return (_fd != NULL);
}

-(int) read:(void *)buffer amount:(int)amount {
	return fread(buffer, 1, amount, _fd);
}

-(BOOL) seek:(long)position whence:(int)whence {
	return (fseek(_fd, position, whence) == 0);
}

@end
