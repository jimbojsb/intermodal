//
// Created by Josh Butts on 3/17/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMProject.h"


@implementation IMProject

- (id)initWithProjectFilePath:(NSString *)path {
    self = [super init];
    self.projectFilePath = path;
    self.absolutePath = [path stringByDeletingLastPathComponent];
    [self loadProjectFileSettings];
    return self;
}

- (void)loadProjectFileSettings {
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:self.projectFilePath];
    self.ports = settings[@"ports"];
    self.inboundSyncRules = settings[@"sync"][@"in"];
    self.outboundSyncRules = settings[@"sync"][@"out"];
}


@end