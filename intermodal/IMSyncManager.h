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
@property NSMutableOrderedSet *inotifyFlushQueue;
@property GCDAsyncSocket *inotifySocket;
@property GCDAsyncSocket *connectedSocket;
@property dispatch_queue_t inotifyReceiveQueue;
@property dispatch_queue_t rsyncDispatchQueue;
@property NSTimer *flushTimer;

- (id)initWithRoot:(NSString *)root;
- (void)listen;

- (void)syncLocalPath:(NSString *)fromPath toRemotePath:(NSString *)toPath;
- (void)syncRemotePath:(NSString *)fromPath toLocalPath:(NSString *)toPath;
- (void)startupSync;
- (NSArray *)findProjects;
- (NSString *)remotePathWithLocalPath:(NSString *)localPath;
- (NSString *)localPathWithRemotePath:(NSString *)remotePath;
- (NSString *)rsyncPathWithRemotePath:(NSString *)remotePath;
- (IMProject *)projectContainingPath:(NSString *)path;
- (void)connectToInotifyStream;
- (void)inotifyFlush;
- (void)rsyncWithArguments:(NSArray *)args;

@end