//
//  BachCoreAudioMetadata.h
//  Bach
//
//  Created by Christian Benincasa on 3/10/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachMetadata.h"

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface BachCoreAudioMetadata : NSObject <BachMetadata>

-(NSString*)getOrUpdateMetadataValueForCommonKey:(NSString*)commonKey
                                 withID3Fallback:(NSString*)ID3FallbackKey
                              withiTunesFallback:(NSString*)iTunesFallbackKey;

-(NSString*)getMetadataValueByKey:(NSString*)key orSetWithBlock:(NSString* (^)(NSMutableDictionary*))block;
-(NSString*)findMetadataValueForCommonKey:(NSString*)key;
-(NSString*)findMetadataValueForID3Key:(NSString*)key;
-(NSString*)findMetdataValueForiTunesKey:(NSString*)key;
-(AVMetadataItem*)findMetdataItemForKey:(NSString*)key withFormat:(NSString*)format;
-(NSData*)findArtwork;

@end
