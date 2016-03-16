//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CDEvents/CDEvents.h>
#import "IMInboundSyncManager.h"

@class IMProcessManager;

@interface IMOutboundSyncManager : NSObject

@property CDEvents *fsEventsStream;
@property NSArray *localWatchedDirs;
@property NSString *localRoot;
@property IMProcessManager *pm;
- (id)initWithLocalRoot:(NSString *)root watchedDirs:(NSArray *)watchedDirs processManager:(IMProcessManager *)processManager;
- (void)listen;
- (void)syncSubpathOfRootToRemote:(NSString *)path;
- (void)syncAllWatchedSubpathsToRemote;


@end