//
//  Bach.h
//  Bach
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "BachDispatch.h"
#import "BachConstants.h"
#import "BachConverter.h"
#import "BachInput.h"
#import "BachOutput.h"

#if __BACH_DEBUG
#import "BachStopwatch.h"
#endif

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BachState) {
    Playing,
    Paused,
    Stopped,
    Error
};

@protocol BachDelegate;

@interface Bach : NSObject

@property(strong, nonatomic) NSError *error;

@property(strong, nonatomic) id<BachDelegate> delegate;
@property(strong, nonatomic) BachInput* input;
@property(strong, nonatomic) BachConverter* converter;
@property(strong, nonatomic) BachOutput* output;

@property(assign, nonatomic) float volume;
@property(assign, nonatomic) BachState state;
@property(strong, nonatomic) NSURL* nextURL;

#pragma mark public

-(void) playWithString:(NSString*) url;
-(void) playWithUrl:(NSURL*) url;
-(void) playNextUrl:(NSURL*) url;
-(void) pause;
-(void) resume;
-(void) stop;
-(void) seek:(float) position;
-(void) setVolume:(float) volume;
-(double) totalTrackTime;
-(double) currentTrackTime;
-(NSDictionary*) metadata;

#pragma mark private

@end

// BachDelegate

@protocol BachDelegate <NSObject>

@required
-(NSURL*) getNextUrl;

@end
