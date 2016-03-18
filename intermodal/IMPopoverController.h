//
// Created by Josh Butts on 3/18/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface IMPopoverController : NSViewController

@property NSPopover *popover;
@property NSButton *statusBarButton;
@property bool popoverIsShowing;

- (id)initWithButton:(NSButton *)button;
- (void)toggle;

@end