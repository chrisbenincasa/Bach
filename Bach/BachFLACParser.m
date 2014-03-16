//
//  BachFLACParser.m
//  Bach
//
//  Created by Christian Benincasa on 2/5/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachFLACMetadata.h"
#import "BachFLACParser.h"

@implementation BachFLACParser

@synthesize writeBuffer;
@synthesize description;
@synthesize properties;
@synthesize source;
@synthesize metadata;

-(void) dealloc {
    if (_decoder) {
        FLAC__stream_decoder_finish(_decoder);
        FLAC__stream_decoder_delete(_decoder);
    }
    if (writeBuffer) {
        free(writeBuffer);
    }
    
    [source close];
}

-(NSDictionary*) properties {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInteger:_bytesPerFrame], [NSNumber numberWithInteger:BYTES_PER_FRAME],
            [NSNumber numberWithInteger:_bitsPerChannel], [NSNumber numberWithInteger:BITS_PER_CHANNEL],
            [NSNumber numberWithInteger:_channels], [NSNumber numberWithInteger:CHANNELS],
            [NSNumber numberWithInteger:_sampleRate], [NSNumber numberWithInteger:SAMPLE_RATE],
            [NSNumber numberWithInteger:_totalFrames], [NSNumber numberWithInteger:TOTAL_FRAMES],
            @"big", [NSNumber numberWithInteger:ENDIAN], nil];
}

-(int) readFrames:(void *)buffer frames:(UInt32)nFrames {
    int framesRead = 0;
    while (framesRead < nFrames) {
        if (_bufferFrames == 0) {
            if (FLAC__stream_decoder_get_state(_decoder) == FLAC__STREAM_DECODER_END_OF_STREAM) {
                break;
            } else if (FLAC__stream_decoder_get_state(_decoder) == FLAC__STREAM_DECODER_SEEK_ERROR) {
                FLAC__stream_decoder_flush(_decoder);
            }
            int result = FLAC__stream_decoder_process_single(_decoder);
#if __BACH_DEBUG
            if (!result) {
                FLAC__StreamDecoderState state = FLAC__stream_decoder_get_state(_decoder);
                NSLog(@"%s", FLAC__StreamDecoderStateString[state]);
            }
#endif
        }
        
        int framesToRead = _bufferFrames;
        if (_bufferFrames > nFrames) {
            framesToRead = nFrames;
        }
        
        memcpy((uint8_t*)buffer + (framesRead * _bytesPerFrame), (uint8_t*) writeBuffer, framesToRead * _bytesPerFrame);
        
        if (framesRead <= nFrames) {
            nFrames -= framesRead;
        } else {
            nFrames = 0;
        }
        
        framesRead += framesToRead;
        _bufferFrames -= framesToRead;
        
        if (_bufferFrames > 0) {
            memmove((uint8_t*) writeBuffer, ((uint8_t*) writeBuffer) + (framesToRead * _bytesPerFrame), _bufferFrames * _bytesPerFrame);
        }
    }
    
    return framesRead;
}

-(BOOL) openSource:(id<BachSource>) src {
    self.source = src;
    
    _decoder = FLAC__stream_decoder_new();

#if __BACH_DEBUG
    if (!_decoder) {
        NSLog(@"decoder could not be enabled");
        return NO;
    }
#endif
    
    FLAC__StreamDecoderInitStatus err;
    
    err = FLAC__stream_decoder_init_stream(_decoder,
                                           FLACReadCallback,
                                           FLACSeekCallback,
                                           FLACTellCallback,
                                           FLACLengthCallback,
                                           FLACEndOfFileCallback,
                                           FLACWriteCallback,
                                           FLACMetadataCallback,
                                           FLACErrorCallback,
                                           (__bridge void*) self);
    
    if (err != FLAC__STREAM_DECODER_INIT_STATUS_OK) {
        NSLog(@"something went wrong in flac ini");
        NSLog(@"%@", [NSString stringWithUTF8String:FLAC__StreamDecoderInitStatusString[err]]);
    }
    
    FLAC__stream_decoder_process_until_end_of_metadata(_decoder);
    
    self.metadata = [[BachFLACMetadata alloc] initWithURL:[self.source url]];
    
    _writeBufferSize = (FLAC__MAX_BLOCK_SIZE + 512) * 2 * 3;
    writeBuffer = malloc(_writeBufferSize);
    
    return YES;
}

-(void)seek:(float)position {
    FLAC__stream_decoder_seek_absolute(_decoder, position);
}

-(void) flush {
    bzero(writeBuffer, _writeBufferSize);
    FLAC__stream_decoder_flush(_decoder);
}

static FLAC__StreamDecoderReadStatus FLACReadCallback(const FLAC__StreamDecoder* decoder, FLAC__byte buffer[], size_t* bytes, void* clientData) {
    BachFLACParser* parser = (__bridge BachFLACParser*) clientData;
    if (*bytes > 0) {
        *bytes = [[parser source] read:buffer amount:*bytes];
        if (*bytes == 0) {
            return FLAC__STREAM_DECODER_READ_STATUS_END_OF_STREAM;
        } else {
            return FLAC__STREAM_DECODER_READ_STATUS_CONTINUE;
        }
    } else {
        return FLAC__STREAM_DECODER_READ_STATUS_ABORT;
    }
}

static FLAC__StreamDecoderSeekStatus FLACSeekCallback(const FLAC__StreamDecoder *decoder, FLAC__uint64 absoluteByteOffset, void *clientData) {
    BachFLACParser* parser = (__bridge BachFLACParser*) clientData;
    
    int ok = [[parser source] seek:(long)absoluteByteOffset startingPosition:SEEK_SET];
    if (!ok) {
        return FLAC__STREAM_DECODER_SEEK_STATUS_ERROR;
    } else {
        return FLAC__STREAM_DECODER_SEEK_STATUS_OK;
    }
}

static FLAC__StreamDecoderTellStatus FLACTellCallback(const FLAC__StreamDecoder *decoder, FLAC__uint64* absoluteByteOffset, void* clientData) {
    BachFLACParser* parser = (__bridge BachFLACParser*) clientData;
    
    long position = [[parser source] tell];
    if (position < 0) {
        return FLAC__STREAM_DECODER_TELL_STATUS_ERROR;
    } else {
        return FLAC__STREAM_DECODER_TELL_STATUS_OK;
    }
}

static FLAC__StreamDecoderLengthStatus FLACLengthCallback(const FLAC__StreamDecoder* decoder, FLAC__uint64* streamLength, void* clientData)
{
    BachFLACParser* parser = (__bridge BachFLACParser*) clientData;
    
    *streamLength = [[parser source] size];
    return FLAC__STREAM_DECODER_LENGTH_STATUS_OK;
}

static FLAC__bool FLACEndOfFileCallback(const FLAC__StreamDecoder* decoder, void* clientData)
{
    BachFLACParser* parser = (__bridge BachFLACParser*) clientData;
    return [[parser source] endOfSource];
}

static FLAC__StreamDecoderWriteStatus FLACWriteCallback(const FLAC__StreamDecoder* decoder, const FLAC__Frame* frame, const FLAC__int32 * const buffer [], void* clientData)
{
    
    BachFLACParser* parser = (__bridge BachFLACParser*) clientData;

    void *bbuf = [parser writeBuffer];
    int8_t  *alias8;
	int16_t *alias16;
	int32_t *alias32;
	int sample, channel;
	int32_t	audioSample;
    
    switch (frame->header.bits_per_sample) {
        case 8: {
            alias8 = bbuf;
            for (sample = 0; sample < frame->header.blocksize; ++sample) {
                for (channel = 0; channel < frame->header.channels; ++channel) {
                    *alias8++ = (int8_t)buffer[channel][sample];
                }
            }
            break;
        }
        case 16: {
            alias16 = bbuf;
            for (sample = 0; sample < frame->header.blocksize; ++sample) {
                for (channel = 0; channel < frame->header.channels; ++channel) {
                    *alias16++ = (int16_t)OSSwapHostToBigInt16(buffer[channel][sample]);
                }
            }
            break;
        }
        case 24: {
            alias8 = bbuf;
            for (sample = 0; sample < frame->header.blocksize; ++sample) {
                for (channel = 0; channel < frame->header.channels; ++channel) {
                    audioSample = buffer[channel][sample];
                    *alias8++ = (int8_t)(audioSample >> 16);
                    *alias8++ = (int8_t)(audioSample >> 8);
                    *alias8++ = (int8_t)audioSample;
                }
            }
            break;
        }
        case 32: {
            alias32 = bbuf;
            for (sample = 0; sample < frame->header.blocksize; ++sample) {
                for (channel = 0; channel < frame->header.channels; ++channel) {
                    *alias32++ = (int32_t)OSSwapHostToBigInt32(buffer[channel][sample]);
                }
            }
            break;
        }
        default: return FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
    }
    
    [parser setBufferFrames:frame->header.blocksize];
    
    return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

static void FLACMetadataCallback(const FLAC__StreamDecoder* decoder, const FLAC__StreamMetadata* metadata, void* clientData)
{
    BachFLACParser* parser = (__bridge BachFLACParser*) clientData;
    if (metadata->type == FLAC__METADATA_TYPE_STREAMINFO) {
        FLAC__StreamMetadata_StreamInfo info = metadata->data.stream_info;
        [parser setChannels:info.channels];
        [parser setBitsPerChannel:info.bits_per_sample];
        [parser setBytesPerFrame:(info.bits_per_sample / 8) * [parser channels]];
        [parser setSampleRate:info.sample_rate];
        [parser setTotalFrames:info.total_samples];
    } else if (metadata->type == FLAC__METADATA_TYPE_VORBIS_COMMENT) {
        FLAC__StreamMetadata_VorbisComment comment = metadata->data.vorbis_comment;
        for (int i = 0; i < comment.num_comments; i++) {
            FLAC__byte* entry = comment.comments[i].entry;
            NSString* entryString = [[NSString alloc] initWithBytes:entry length:comment.comments[i].length encoding:NSASCIIStringEncoding];
            NSArray* entryArr = [entryString componentsSeparatedByString:@"="];
            NSString* key = [[NSString stringWithString:[entryArr objectAtIndex:0]] lowercaseString];
            NSString* value = [NSString stringWithString:[entryArr objectAtIndex:1]];
            NSMutableDictionary* meta = [NSMutableDictionary dictionaryWithDictionary:[parser metadata]];
            [meta setObject:value forKey:key];
            parser.metadata = meta;
        }
    }
}

static void FLACErrorCallback(const FLAC__StreamDecoder* decoder, FLAC__StreamDecoderErrorStatus status, void* clientData)
{
    
}

@end
