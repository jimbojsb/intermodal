//
// Created by Josh Butts on 3/18/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMPopoverController.h"

@implementation IMPopoverController

- (id)initWithButton:(NSButton *)button {
    self = [super init];
    self.statusBarButton = button;
    self.popoverIsShowing = NO;
    self.popover = [NSPopover new];
    self.popover.contentViewController = self;
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0,0,150,50)];


    NSEdgeInsets windowMargins = NSEdgeInsetsMake(8,8,8,8);
    NSButton *exitButton = [NSButton new];
    exitButton.target = self;
    exitButton.action = @selector(handleExitButtonClick:);
    exitButton.title = @"Exit Intermodal";
    [exitButton setBezelStyle:NSRoundedBezelStyle];
    [self.view addSubview:exitButton];
    [exitButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).with.insets(windowMargins);
        make.left.equalTo(self.view.left).with.insets(windowMargins);
        make.right.equalTo(self.view.right).with.insets(windowMargins);
    }];
    return self;
}


- (void)toggle {
    if (self.popoverIsShowing) {
        [self.popover close];
        self.popoverIsShowing = NO;
        [self.statusBarButton highlight:NO];
    } else {
        [self.popover showRelativeToRect:self.statusBarButton.bounds ofView:self.statusBarButton preferredEdge:NSMinYEdge];
        [self.statusBarButton highlight:YES];
        self.popoverIsShowing = YES;
    }
}

- (void)handleExitButtonClick:(id)sender {
    [NSApp terminate:self];
}


@end