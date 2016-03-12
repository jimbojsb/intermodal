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

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.statusBarController = [[IMStatusBarController alloc] initWithStatusItem:statusItem];
    self.syncManager = [IMSyncManager new];
    [self.syncManager listen];
    NSArray *dockerProjectRoots = [[[IMDockerFileFinder alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"/projects"]] scan];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
