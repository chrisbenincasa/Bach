//
//  BachCoreAudioMetadata.m
//  Bach
//
//  Created by Christian Benincasa on 3/10/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachCoreAudioMetadata.h"

@interface BachCoreAudioMetadata ()

@property (strong, nonatomic) AVURLAsset* avAsset;
@property (strong, nonatomic) NSMutableDictionary* metadataDict;

@end

@implementation BachCoreAudioMetadata

@synthesize assetURL;

#pragma mark Initializers

-(id)initWithURL:(NSURL*)url {
    if (self = [super init]) {
        assetURL = url;
        _avAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    }
    
    return self;
}

-(void)setAssetURL:(NSURL *)url {
    assetURL = url;
    _avAsset = [[AVURLAsset alloc] initWithURL:assetURL options:nil];
}

#pragma mark Accessors

-(NSString*)trackName {
    if (!_avAsset) return nil;
    
    return [self getOrUpdateMetadataValueForCommonKey:AVMetadataCommonKeyTitle
                                      withID3Fallback:AVMetadataID3MetadataKeyTitleDescription
                                   withiTunesFallback:AVMetadataiTunesMetadataKeySongName];
}

-(NSString*)artistName {
    if (!_avAsset) return nil;
    
    return [self getOrUpdateMetadataValueForCommonKey:AVMetadataCommonKeyArtist
                                      withID3Fallback:AVMetadataID3MetadataKeyOriginalArtist
                                   withiTunesFallback:AVMetadataiTunesMetadataKeyArtist];
}

-(NSString*)albumName {
    if (!_avAsset) return nil;
    
    return [self getOrUpdateMetadataValueForCommonKey:AVMetadataCommonKeyAlbumName
                                      withID3Fallback:AVMetadataID3MetadataKeyAlbumTitle
                                   withiTunesFallback:AVMetadataiTunesMetadataKeyAlbum];
}

-(NSString*)date {
    if (!_avAsset) return nil;
    
    return [self getOrUpdateMetadataValueForCommonKey:AVMetadataCommonKeyCreationDate
                                      withID3Fallback:AVMetadataID3MetadataKeyYear
                                   withiTunesFallback:AVMetadataiTunesMetadataKeyReleaseDate];
}

-(NSString*)genre {
    if (!_avAsset) return nil;
    
    return [self getOrUpdateMetadataValueForCommonKey:nil
                                      withID3Fallback:nil
                                   withiTunesFallback:AVMetadataiTunesMetadataKeyUserGenre];
}

-(NSData*)artwork {
    if (!_avAsset) return nil;
    
    return [self findArtwork];
}

#pragma mark Private methods

-(NSString*)getOrUpdateMetadataValueForCommonKey:(NSString*)commonKey
                                 withID3Fallback:(NSString*)ID3FallbackKey
                              withiTunesFallback:(NSString*)iTunesFallbackKey {
    NSString* value = nil;
    
    if (commonKey) {
        value = [self getMetadataValueByKey:commonKey orSetWithBlock:^NSString *(NSMutableDictionary *meta) {
            NSString* metaValue = [self findMetadataValueForCommonKey:commonKey];
            [meta setObject:metaValue forKey:commonKey];
            return metaValue;
        }];
        
        if (value) return value;
    }
    
    if (ID3FallbackKey && !value) {
        value = [self getMetadataValueByKey:ID3FallbackKey orSetWithBlock:^NSString *(NSMutableDictionary *meta) {
            NSString* metaValue = [self findMetadataValueForID3Key:ID3FallbackKey];
            [meta setObject:metaValue forKey:ID3FallbackKey];
            return metaValue;
        }];
        
        if (value) return value;
    }
    
    if (iTunesFallbackKey && !value) {
        value = [self getMetadataValueByKey:iTunesFallbackKey orSetWithBlock:^NSString *(NSMutableDictionary *meta) {
            NSString* metaValue = [self findMetdataValueForiTunesKey:iTunesFallbackKey];
            [meta setObject:metaValue forKey:iTunesFallbackKey];
            return metaValue;
        }];
        
        if (value) return value;
    }
    
    return value;
}

-(NSString*)getMetadataValueByKey:(NSString*)key orSetWithBlock:(NSString* (^)(NSMutableDictionary*))block {
    NSString* value = [_metadataDict objectForKey:key];
    if (value) {
        return value;
    } else {
        return block(_metadataDict);
    }
}

-(NSString*)findMetadataValueForCommonKey:(NSString*)key
{
    AVMetadataItem* item = [self findMetdataItemForKey:key withFormat:AVMetadataKeySpaceCommon];
    if (item) {
        return [item stringValue];
    } else {
        return nil;
    }
}

-(NSString*)findMetadataValueForID3Key:(NSString*)key
{
    AVMetadataItem* item = [self findMetdataItemForKey:key withFormat:AVMetadataFormatID3Metadata];
    if (item) {
        return [item stringValue];
    } else {
        return nil;
    }
}

-(NSString*)findMetdataValueForiTunesKey:(NSString*)key
{
    AVMetadataItem* item = [self findMetdataItemForKey:key withFormat:AVMetadataFormatiTunesMetadata];
    if (item) {
        return [item stringValue];
    } else {
        return nil;
    }
}

-(AVMetadataItem*)findMetdataItemForKey:(NSString*)key withFormat:(NSString*)format
{
    if (!_avAsset) return nil;
    
    if (![[_avAsset availableMetadataFormats] containsObject:format]) return nil;
    
    for (AVMetadataItem* item in [_avAsset metadataForFormat:format]) {
        if ([[item key] isKindOfClass:[NSString class]]) {
            NSString* key = (NSString*)[item key];
            if ([key isEqualToString:key]) {
                return item;
            }
        } else if ([[item key] isKindOfClass:[NSNumber class]]) {
            NSNumber* keyAsNumber = (NSNumber *)[item key];
            NSString* keyAsString = stringForOSType([keyAsNumber unsignedIntValue]);
            if ([keyAsString isEqualToString:key]) {
                return item;
            }
        } else if ([[item key] isKindOfClass:[NSObject class]]) {
            NSString* keyAsString = [(NSObject *)[item key] description];
            if ([keyAsString isEqualToString:key]) {
                return item;
            }
        }
    }
    
    return nil;
}

-(NSData*)findArtwork
{
    AVMetadataItem* item = nil;
    
    item = [self findMetdataItemForKey:AVMetadataCommonKeyArtwork withFormat:AVMetadataKeySpaceCommon];
    if (item && [item isKindOfClass:[NSData class]]) {
        return (NSData*)item.value;
    }
    
    item = [self findMetdataItemForKey:AVMetadataiTunesMetadataKeyCoverArt withFormat:AVMetadataKeySpaceiTunes];
    
    if (item && [item isKindOfClass:[NSData class]]) {
        return (NSData*)item.value;
    }
    
    return nil;
}

static NSString * stringForOSType(OSType theOSType)
{
    size_t len = sizeof(OSType);
    long addr = (unsigned long)&theOSType;
    char cstring[5];
    
    len = (theOSType >> 24) == 0 ? len - 1 : len;
    len = (theOSType >> 16) == 0 ? len - 1 : len;
    len = (theOSType >>  8) == 0 ? len - 1 : len;
    len = (theOSType >>  0) == 0 ? len - 1 : len;
    
    addr += (4 - len);
    
    theOSType = EndianU32_NtoB(theOSType);      // strings are big endian
    
    strncpy(cstring, (char *)addr, len);
    cstring[len] = 0;
    
    // Standardize between 4CC and AVMetadataKey Constants
    if (cstring[0] == '\xa9') {
        cstring[0] = '@';
    }
    
    return [NSString stringWithCString:(char *)cstring encoding:NSMacOSRomanStringEncoding];
}

@end
