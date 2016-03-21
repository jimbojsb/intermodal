//
//  AppDelegate.h
//  intermodal
//
//  Created by Josh Butts on 2/29/16.
//  Copyright © 2016 joshbutts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IMStatusBarController.h"
#import "IMSyncManager.h"
#import "IMInboundSyncManager.h"
#import "IMVirtualMachine.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property IMStatusBarController *statusBarController;
@property IMSyncManager *syncManager;
@property IMInboundSyncManager *inboundSyncManager;
@property IMVirtualMachine *vm;
@property NSString *projectsRoot;

@end

