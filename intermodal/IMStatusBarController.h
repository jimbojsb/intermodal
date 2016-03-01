//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface IMStatusBarController : NSObject

@property NSStatusItem *statusItem;

- (id) initWithStatusItem:(NSStatusItem *)statusItem;

@end