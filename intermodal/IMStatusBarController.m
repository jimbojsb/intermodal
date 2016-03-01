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
    return self;
}

@end