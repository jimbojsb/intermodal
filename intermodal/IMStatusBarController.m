//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMStatusBarController.h"


@implementation IMStatusBarController

- (id)initWithStatusItem:(NSStatusItem *)statusItem {
    self = [super init];
    self.statusItem = statusItem;
    self.statusItem.button.image = [NSImage imageNamed:@"status-icon"];
    self.statusItem.button.target = self.popoverController;
    self.statusItem.button.action = @selector(toggle);
    [self.statusItem.button sendActionOn:(NSLeftMouseDownMask | NSRightMouseDownMask)];
    self.popoverController = [[IMPopoverController alloc] initWithButton:self.statusItem.button];
    [self.statusItem setTarget:self.popoverController];
    [self.statusItem setAction:@selector(toggle)];
    return self;
}

@end