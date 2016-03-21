//
//  AppDelegate.m
//  intermodal
//
//  Created by Josh Butts on 2/29/16.
//  Copyright © 2016 joshbutts. All rights reserved.
//

#import "AppDelegate.h"
#import "IMStatusBarController.h"
#import "IMProcessManager.h"
#import "IMEnvironmentSetup.h"

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

//
//
//    [self.syncManager syncAllLocalToRemote];
//    [self.syncManager listen];

//    self.inboundSyncManager = [[IMInboundSyncManager alloc] initWithLocalRoot:self.projectsRoot remoteRoot:@"/sync" processManager:processManager];
//    [self.inboundSyncManager listen];
//    self.vm = [IMVirtualMachine new];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [IMVirtualMachine stop];
}

@end
