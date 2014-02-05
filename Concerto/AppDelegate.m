//
//  AppDelegate.m
//  Concerto
//
//  Created by Christian Benincasa on 2/1/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

#import "AppDelegate.h"
#import "Bach.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

-(IBAction)openFile:(id)sender {
#pragma unused(sender)
//    NSArray *allowedFiles = [NSArray arrayWithObjects:@"mp3", nil];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
//    [panel setAllowedFileTypes:allowedFiles];
    
    if (NSFileHandlingPanelOKButton == [panel runModal]) {
        NSArray *urls = [panel URLs];
        [self playWithUrl:[urls objectAtIndex:0]];
    }
}

-(void) playWithUrl: (NSURL*) url {
    Bach *player = [[Bach alloc] init];
    [player playWithUrl:url];
}

@end
