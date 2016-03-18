//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "IMPopoverController.h"

@interface IMStatusBarController : NSObject

@property NSStatusItem *statusItem;
@property IMPopoverController *popoverController;

- (id) initWithStatusItem:(NSStatusItem *)statusItem;

@end