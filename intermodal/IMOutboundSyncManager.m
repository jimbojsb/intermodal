//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMOutboundSyncManager.h"
#import "IMProcessManager.h"

@implementation IMOutboundSyncManager

- (id)initWithLocalRoot:(NSString *)root watchedDirs:(NSArray *)watchedDirs processManager:(IMProcessManager *)processManager {
    self = [super init];
    self.localRoot = root;
    NSMutableArray *cleanedDirs = [NSMutableArray new];
    for (NSString *dir in watchedDirs) {
        [cleanedDirs addObject:[dir stringByReplacingOccurrencesOfString:self.localRoot withString:@""]];
    }
    self.localWatchedDirs = [NSArray arrayWithArray:cleanedDirs];
    self.pm = processManager;
    return self;
}


- (void)listen {
    NSLog(@"Intermodal SyncManager started at %@", self.localRoot);


    NSArray *urls  = @[[NSURL URLWithString:self.localRoot]];
    self.fsEventsStream = [[CDEvents alloc] initWithURLs:urls block:
        ^(CDEvents *watcher, CDEvent *event) {
            NSString *absolutePath = [event.URL path];
            if ([absolutePath rangeOfString:@".git"].location == NSNotFound) {
                NSString *subpathString = [absolutePath stringByReplacingOccurrencesOfString:self.localRoot withString:@""];
                NSString *dirCheck = [NSString stringWithFormat:@"/%@", [subpathString componentsSeparatedByString:@"/"][1]];
                if ([self.localWatchedDirs containsObject:dirCheck]) {
                    //NSLog(@"fsevent on %@", absolutePath);
                    [self syncSubpathOfRootToRemote:subpathString];
                }
            }
        }
    ];

}

- (void)syncSubpathOfRootToRemote:(NSString *)path {
    NSString *localPath = [NSString stringWithFormat:@"%@%@", self.localRoot, path];
    NSString *remotePath = [NSString stringWithFormat:@"127.0.0.1::sync%@", [path stringByDeletingLastPathComponent]];
    NSString *rsyncCommand = @"/usr/bin/rsync";
    NSArray *rsyncArguments = @[
            @"--port",
            @"2873",
            @"-rtqz",
            @"--delete",
            @"--ignore-missing-args"
            @"--links",
            @"--exclude=.git/",
            localPath,
            remotePath
    ];
    [self.pm run:rsyncCommand withArguments:rsyncArguments];
}

- (void)syncAllWatchedSubpathsToRemote {
    for (NSString *subpath in self.localWatchedDirs) {
        [self syncSubpathOfRootToRemote:subpath];
    }
}


@end