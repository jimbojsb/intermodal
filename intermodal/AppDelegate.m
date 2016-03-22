//
//  AppDelegate.m
//  intermodal
//
//  Created by Josh Butts on 2/29/16.
//  Copyright © 2016 joshbutts. All rights reserved.
//

#import "AppDelegate.h"
#import "IMEnvironmentSetup.h"
#import "IMSyncContainerManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.statusBarController = [[IMStatusBarController alloc] initWithStatusItem:statusItem];

    [IMEnvironmentSetup setupBashProfile];

    NSString *projectRoot = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"projects"];
    self.syncManager = [[IMSyncManager alloc] initWithRoot:projectRoot];

    NSMutableArray *portsToForward = [NSMutableArray new];
    for (IMProject *p in self.syncManager.projects) {
        [portsToForward addObjectsFromArray:p.ports];
    }

    if (![IMVirtualMachine exists]) {
        [IMVirtualMachine importFromOVA];
    }
    [IMVirtualMachine forwardPorts:portsToForward];
    [IMVirtualMachine start];

    NSLog(@"Waiting for vm to be ready...");
    while (![IMVirtualMachine dockerIsRunning]) {
        [NSThread sleepForTimeInterval:5];
    }
    NSLog(@"VM is ready...");
    NSLog(@"Starting sync container");

    [IMSyncContainerManager stopContainer];
    [IMSyncContainerManager runContainer];




    [self.syncManager startupSync];
    [self.syncManager connectToInotifyStream];
    [self.syncManager listen];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [IMSyncContainerManager stopContainer];
    [IMVirtualMachine stop];
}

@end
