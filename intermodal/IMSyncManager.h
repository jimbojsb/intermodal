//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CDEvents/CDEvents.h>
#import <GCDAsyncSocket.h>
#import "IMProject.h"

@class IMProcessManager;

@interface IMSyncManager : NSObject <GCDAsyncSocketDelegate>

@property CDEvents *fsEventsStream;
@property NSString *root;
@property NSArray *projects;
@property GCDAsyncSocket *fseventSocket;
@property GCDAsyncSocket *connectedSocket;

- (void)listen;
- (void)startupSync;
- (NSArray *)findProjects;
- (IMProject *)projectContainingPath:(NSString *)path;
- (void)connectToInotifyStream;


@end