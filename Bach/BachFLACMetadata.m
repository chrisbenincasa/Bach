//
//  BachFLACMetadata.m
//  Bach
//
//  Created by Christian Benincasa on 3/10/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachFLACMetadata.h"

static NSString* kVorbisTrackKey = @"title";
static NSString* kVorbisArtistKey = @"artist";
static NSString* kVorbisAlbumArtistKey = @"albumartist";
static NSString* kVorbisAlbumKey = @"album";
static NSString* kVorbisDateKey = @"date";
static NSString* kVorbisGenreKey = @"genre";
static NSString* kVorbisTrackNumberKey = @"tracknumber";
static NSString* kVorbisDiscNumberKey = @"discnumber";
static NSString* kVorbisTotalDiscNumberKey = @"totaldiscs";

@interface BachFLACMetadata ()

@property (strong, nonatomic) BachFileSource* source;
@property (assign, nonatomic) FLAC__StreamDecoder* decoder;
@property (strong, nonatomic) NSMutableDictionary* metadataDict;
@property (strong, nonatomic) NSData* picture;

@end

@implementation BachFLACMetadata

@synthesize assetURL;

#pragma mark Initialization

-(id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        assetURL = url;
        _source = [[BachFileSource alloc] init];
        if (![_source open:assetURL]) {
            return nil;
        }
        _metadataDict = [NSMutableDictionary dictionary];
        _decoder = FLAC__stream_decoder_new();
        FLAC__stream_decoder_set_metadata_respond(_decoder, FLAC__METADATA_TYPE_VORBIS_COMMENT);
        FLAC__StreamDecoderInitStatus err;
        err = FLAC__stream_decoder_init_stream(_decoder,
                                               FLACReadCallback,
                                               NULL, //FLACSeekCallback,
                                               NULL, //FLACTellCallback,
                                               NULL, //FLACLengthCallback,
                                               NULL, //FLACEndOfFileCallback,
                                               FLACWriteCallback,
                                               FLACMetadataCallback,
                                               FLACErrorCallback,
                                               (__bridge void*) self);
        
        if (err != FLAC__STREAM_DECODER_INIT_STATUS_OK) {
            NSLog(@"Could not initialize FLAC metadata");
            NSLog(@"%@", [NSString stringWithUTF8String:FLAC__StreamDecoderInitStatusString[err]]);
            return nil;
        }
        
        FLAC__stream_decoder_process_until_end_of_metadata(_decoder);
    }
    
    return self;
}

-(void)dealloc
{
    FLAC__stream_decoder_finish(_decoder);
    FLAC__stream_decoder_delete(_decoder);
    [_source close];
}

#pragma mark Accessors

-(NSString*)trackName
{
    return [_metadataDict objectForKey:kVorbisTrackKey];
}

-(NSString*)artistName
{
    return [_metadataDict objectForKey:kVorbisArtistKey];
}

-(NSString*)albumName
{
    return [_metadataDict objectForKey:kVorbisAlbumKey];
}

-(NSString*)genre
{
    return [_metadataDict objectForKey:kVorbisGenreKey];
}

-(NSString*)date
{
    return [_metadataDict objectForKey:kVorbisDateKey];
}

-(NSData*)artwork
{
    return _picture;
}

#pragma mark FLAC callbacks

static FLAC__StreamDecoderReadStatus FLACReadCallback(const FLAC__StreamDecoder* decoder, FLAC__byte buffer[], size_t* bytes, void* clientData)
{
    BachFLACMetadata* meta = (__bridge BachFLACMetadata*) clientData;
    if (*bytes > 0) {
        *bytes = [[meta source] read:buffer amount:*bytes];
        if (*bytes == 0) {
            return FLAC__STREAM_DECODER_READ_STATUS_END_OF_STREAM;
        } else {
            return FLAC__STREAM_DECODER_READ_STATUS_CONTINUE;
        }
    } else {
        return FLAC__STREAM_DECODER_READ_STATUS_ABORT;
    }
}

static FLAC__StreamDecoderWriteStatus FLACWriteCallback(const FLAC__StreamDecoder* decoder, const FLAC__Frame* frame, const FLAC__int32 * const buffer [], void* clientData)
{
    
    return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

static void FLACMetadataCallback(const FLAC__StreamDecoder* decoder, const FLAC__StreamMetadata* metadata, void* clientData)
{
    BachFLACMetadata* meta = (__bridge BachFLACMetadata*) clientData;
    if (metadata->type == FLAC__METADATA_TYPE_VORBIS_COMMENT) {
        FLAC__StreamMetadata_VorbisComment comment = metadata->data.vorbis_comment;
        __block NSMutableDictionary* metadataDict = [NSMutableDictionary dictionary];
        for (int i = 0; i < comment.num_comments; i++) {
            FLAC__byte* entry = comment.comments[i].entry;
            NSString* entryString = [[NSString alloc] initWithBytes:entry length:comment.comments[i].length encoding:NSASCIIStringEncoding];
            NSArray* entryArr = [entryString componentsSeparatedByString:@"="];
            NSString* key = [[NSString stringWithString:[entryArr objectAtIndex:0]] lowercaseString];
            NSString* value = [NSString stringWithString:[entryArr objectAtIndex:1]];
            [metadataDict setObject:value forKey:key];
        }
        [meta.metadataDict addEntriesFromDictionary:metadataDict];
    } else if (metadata->type == FLAC__METADATA_TYPE_CUESHEET) {
        //FLAC__StreamMetadata_CueSheet cueSheet = metadata->data.cue_sheet;
    } else if (metadata->type == FLAC__METADATA_TYPE_PICTURE) {
        FLAC__StreamMetadata_Picture picture = metadata->data.picture;
        meta.picture = [NSData dataWithBytes:picture.data length:picture.data_length];
    }
}

static void FLACErrorCallback(const FLAC__StreamDecoder* decoder, FLAC__StreamDecoderErrorStatus status, void* clientData)
{
    
}

@end
