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
@property (strong, nonatomic) NSString* trackName;
@property (strong, nonatomic) NSString* artistName;

@end

@implementation BachCoreAudioMetadata

@synthesize assetURL;

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

-(NSString*)trackName {
    if (!_avAsset) return nil;
    
    if (!_trackName) {
        NSString* track = [self getMetadataValueForCommonKey:AVMetadataCommonKeyTitle];
        if (!track) {
            track = [self getMetadataValueForID3Key:AVMetadataID3MetadataKeyTitleDescription];
        }
        _trackName = track;
    }
    
    return _trackName;
}

-(NSString*)artistName {
    if (!_avAsset) return nil;
    
    if (!self.artistName) {
        NSString* artist = [self getMetadataValueForCommonKey:AVMetadataCommonKeyArtist];
        if (!artist) {
            artist = [self getMetadataValueForID3Key:AVMetadataID3MetadataKeyOriginalArtist];
        }
        
        self.artistName = artist;
    }
    
    return self.artistName;
}

-(NSString*)getMetadataValueForCommonKey:(NSString*)key {
    for (AVMetadataItem* item in [_avAsset commonMetadata]) {
        if ([item.commonKey isEqualToString:key]) {
            return [item stringValue];
        }
    }
    
    return nil;
}

-(NSString*)getMetadataValueForID3Key:(NSString*)key {
    for (AVMetadataItem* item in [_avAsset metadataForFormat:AVMetadataFormatID3Metadata]) {
        if ([[item key] isKindOfClass:[NSNumber class]]) {
            NSNumber* keyAsNumber = (NSNumber *)[item key];
            NSString* keyAsString = stringForOSType([keyAsNumber unsignedIntValue]);
            if ([keyAsString isEqualToString:key]) {
                return [item stringValue];
            }
        } else if ([[item key] isKindOfClass:[NSObject class]]) {
            NSString* keyAsString = [(NSObject *)[item key] description];
            if ([keyAsString isEqualToString:key]) {
                return [item stringValue];
            }
        }
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
    
    return [NSString stringWithCString:(char *)cstring encoding:NSMacOSRomanStringEncoding];
}

static NSString * stringForDataDescription(NSData *data)
{
    NSMutableString *str = [NSMutableString stringWithCapacity:64];
    NSUInteger length = [data length];
    const unsigned char *bytes = (const unsigned char *)[data bytes];
    int i;
    
    [str appendFormat:@"[ data length = %u, bytes = 0x", (unsigned int)length];
    
    // Dump 24 bytes of data in hex
    if (length <= 24) {
        for (i = 0; i < length; i++)
            [str appendFormat:@"%02x", bytes[i]];
    } else {
        for (i = 0; i < 16; i++)
            [str appendFormat:@"%02x", bytes[i]];
        [str appendFormat:@" ... "];
        for (i = length - 8; i < length; i++)
            [str appendFormat:@"%02x", bytes[i]];
    }
    [str appendFormat:@" ]"];
    
    return str;
}

@end
