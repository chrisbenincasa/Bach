//
//  BachMetadata.h
//  Bach
//
//  Created by Christian Benincasa on 3/10/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BachMetadata;

// BachMetadata static methods

@interface BachMetadata : NSObject

+(id<BachMetadata>)metadataObjectForURL:(NSURL*)url;

@end

// BachMetadata Protocol

@protocol BachMetadata <NSObject>

@required

@property (strong, nonatomic) NSURL* assetURL;

-(id)initWithURL:(NSURL*)url;

@required

-(NSString*)trackName;
-(NSString*)artistName;
-(NSString*)albumName;
-(NSString*)genre;
-(NSString*)date;
-(NSData*)artwork;

@optional

@end
