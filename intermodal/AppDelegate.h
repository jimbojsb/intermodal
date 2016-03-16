//
//  AppDelegate.h
//  intermodal
//
//  Created by Josh Butts on 2/29/16.
//  Copyright © 2016 joshbutts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IMStatusBarController.h"
#import "IMOutboundSyncManager.h"
#import "IMInboundSyncManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property IMStatusBarController *statusBarController;
@property IMOutboundSyncManager *outboundSyncManager;
@property IMInboundSyncManager *inboundSyncManager;

@end

