//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CDEvents/CDEvents.h>

@interface IMSyncManager : NSObject

@property CDEvents *fsEventsStream;
@property NSArray *watchedDirs;
@property NSString *root;

- (id)initWithRoot:(NSString *)root watchedDirs:(NSArray *)watchedDirs;
- (void) listen;
- (void) syncSubpathOfRoot:(NSString *)path;
- (void) runRsyncDaemon;
- (void) syncAll;

@end