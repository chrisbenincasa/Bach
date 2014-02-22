//
//  BachRingBuffer.m
//  Bach
//
//  Created by Christian Benincasa on 2/9/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachRingBuffer.h"

@implementation BachRingBuffer

@synthesize channels = _channels;

-(id)initWithBufferLength:(SInt64) bufferLength channels:(SInt64)numChannels {
    
    if (self = [super init]) {
        if (numChannels > 4) {
            _channels = 4;
        } else if (_channels < 0) {
            _channels = 1;
        } else {
            _channels = numChannels;
        }
        
        for (int i = 0; i < _channels; ++i) {
            _data[i] = (float*) calloc(bufferLength, sizeof(float));
            
        }
        
        _lastWrittenIndex = [[NSMutableArray alloc] init];
        _lastReadIndex = [[NSMutableArray alloc] init];
        _numUnreadFrames = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) dealloc {
    for (int i = 0; i < _channels; ++i) {
        free(_data[i]);
    }
}

-(void)addSigned16BitData:(const SInt16*)newData frames:(const SInt64) numFrames channel:(const SInt64) whichChannel {
    SInt64 idx;
    for (int i = 0; i < numFrames; ++i) {
        idx = ([[_lastWrittenIndex objectAtIndex:whichChannel] intValue] + 1) % _bufferSize;
        _data[whichChannel][idx] = (float) newData[i];
    }
    SInt64 newLastIndex = ([[_lastWrittenIndex objectAtIndex:whichChannel] integerValue] + numFrames) % _bufferSize;
    [_lastWrittenIndex setObject:[NSNumber numberWithInteger:newLastIndex] atIndexedSubscript:whichChannel];
    SInt64 newNumUnread = [[_numUnreadFrames objectAtIndex:whichChannel] integerValue] + numFrames;
    if (newNumUnread > _bufferSize) {
        [_numUnreadFrames setObject:[NSNumber numberWithInteger:_bufferSize] atIndexedSubscript:whichChannel];
    } else {
        [_numUnreadFrames setObject:[NSNumber numberWithInteger: newNumUnread] atIndexedSubscript:whichChannel];
    }
}

-(void)fetchData:(float *)outData frames:(SInt64)numFrames channel:(SInt64)whichChannel {
    SInt64 idx;
    for (int i = 0; i < numFrames; ++i) {
        idx = [[_lastReadIndex objectAtIndex:whichChannel] integerValue] + i % _bufferSize;
        outData[i] = _data[whichChannel][idx];
    }
    
    SInt64 newLastIndex = [[_lastReadIndex objectAtIndex:whichChannel] integerValue] + numFrames % _bufferSize;
    [_lastReadIndex setObject:[NSNumber numberWithInteger:newLastIndex] atIndexedSubscript:whichChannel];
    SInt64 newNumUnread = [[_numUnreadFrames objectAtIndex:whichChannel] integerValue] - numFrames;
    if (newNumUnread <= 0) {
        [_numUnreadFrames setObject:[NSNumber numberWithInteger:0] atIndexedSubscript:whichChannel];
    } else {
        [_numUnreadFrames setObject:[NSNumber numberWithInteger:newNumUnread] atIndexedSubscript:whichChannel];
    }
}

-(void) clear {
    for (int i = 0; i < _channels; ++i) {
        memset(_data[i], 0, sizeof(float) * _bufferSize);
        [_lastWrittenIndex setObject:[NSNumber numberWithInt:0] atIndexedSubscript:i];
        [_lastReadIndex setObject:[NSNumber numberWithInt:0] atIndexedSubscript:i];
    }
}

@end
