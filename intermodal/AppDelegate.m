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
    self.projectsRoot = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"projects"];

    IMProcessManager *processManager = [IMProcessManager new];

    self.outboundSyncManager = [[IMOutboundSyncManager alloc] initWithLocalRoot:self.projectsRoot processManager:processManager];
    [self.outboundSyncManager syncAllWatchedSubpathsToRemote];
    [self.outboundSyncManager listen];
    self.inboundSyncManager = [[IMInboundSyncManager alloc] initWithLocalRoot:self.projectsRoot remoteRoot:@"/sync" processManager:processManager];
    [self.inboundSyncManager listen];
    self.vm = [IMVirtualMachine new];
    [self.vm portsFromComposeFiles];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
