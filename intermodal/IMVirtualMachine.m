//
// Created by Josh Butts on 3/16/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMVirtualMachine.h"
#import "IMDockerComposePortScanner.h"
#import "IMDockerFileFinder.h
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "IMDockerFileFinder.h"

@implementation IMVirtualMachine

- (NSArray *)portsFromComposeFiles {
    AppDelegate *delegate = (AppDelegate *) [NSApp delegate];
    NSString *projectsRoot = delegate.projectsRoot;
    IMDockerFileFinder *dff = [[IMDockerFileFinder alloc] initWithPath:projectsRoot];
    NSArray *dockerComposeFiles = [dff scanForDockerComposeFiles];
    NSMutableSet *ports = [NSMutableSet new];
    IMDockerComposePortScanner *scanner = [IMDockerComposePortScanner new];
    for (NSString *dockerComposeFile in dockerComposeFiles) {
        NSArray *portsFromFile = [scanner scanFile:dockerComposeFile];
        [ports addObjectsFromArray:portsFromFile];
    }
    return [ports allObjects];
}


@end