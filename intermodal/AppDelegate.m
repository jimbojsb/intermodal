//
//  AppDelegate.m
//  intermodal
//
//  Created by Josh Butts on 2/29/16.
//  Copyright © 2016 joshbutts. All rights reserved.
//

#import "AppDelegate.h"
#import "IMStatusBarController.h"
#import "IMDockerFileFinder.h"
#import "IMProcessManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.statusBarController = [[IMStatusBarController alloc] initWithStatusItem:statusItem];
    NSString *projectsPath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"projects"];
    NSArray *dockerProjectRoots = [[[IMDockerFileFinder alloc] initWithPath:projectsPath ] scan];

    IMProcessManager *processManager = [IMProcessManager new];

    self.outboundSyncManager = [[IMOutboundSyncManager alloc] initWithLocalRoot:projectsPath watchedDirs:dockerProjectRoots processManager:processManager];
    [self.outboundSyncManager syncAllWatchedSubpathsToRemote];
    [self.outboundSyncManager listen];
    self.inboundSyncManager = [[IMInboundSyncManager alloc] initWithLocalRoot:projectsPath remoteRoot:@"/sync" processManager:processManager];
    [self.inboundSyncManager listen];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
