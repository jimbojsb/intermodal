//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CDEvents/CDEvents.h>
#import "IMInboundSyncManager.h"
#import "IMProject.h"

@class IMProcessManager;

@interface IMSyncManager : NSObject

@property CDEvents *fsEventsStream;
@property NSArray *localWatchedDirs;
@property NSString *localRoot;
@property IMProcessManager *pm;
@property NSArray *projects;

- (id)initWithLocalRoot:(NSString *)root processManager:(IMProcessManager *)processManager;
- (void)listen;

- (void)syncPath:(NSString *)fromPath toPath:(NSString *)toPath withProject:(IMProject *)project;
- (void)syncAllLocalToRemote;
- (NSArray *)findProjects;
- (NSString *)remotePathWithLocalPath:(NSString *)localPath;
- (NSString *)localPathWithRemotePath:(NSString *)remotePath;
- (IMProject *)projectContainingPath:(NSString *)path;


@end