//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMSyncManager.h"
#import "IMProcessManager.h"

@implementation IMSyncManager

- (id)initWithRoot:(NSString *)root watchedDirs:(NSArray *)watchedDirs {
    self = [super init];
    self.root = root;
    NSMutableArray *cleanedDirs = [NSMutableArray new];
    for (NSString *dir in watchedDirs) {
        [cleanedDirs addObject:[dir stringByReplacingOccurrencesOfString:self.root withString:@""]];
    }
    self.watchedDirs = [NSArray arrayWithArray:cleanedDirs];
    return self;
}


- (void)listen {
    NSLog(@"Intermodal SyncManager listening on %@", self.root);
    NSArray *urls  = @[[NSURL URLWithString:self.root]];
    self.fsEventsStream = [[CDEvents alloc] initWithURLs:urls block:
        ^(CDEvents *watcher, CDEvent *event) {
            NSString *absolutePath = [event.URL path];
            if ([absolutePath rangeOfString:@".git"].location == NSNotFound) {
                NSString *subpathString = [absolutePath stringByReplacingOccurrencesOfString:self.root withString:@""];
                NSString *dirCheck = [NSString stringWithFormat:@"/%@", [subpathString componentsSeparatedByString:@"/"][1]];
                if ([self.watchedDirs containsObject:dirCheck]) {
                    NSLog(@"fsevent on %@", absolutePath);
                    [self syncSubpathOfRoot:subpathString];
                }
            }
        }
    ];

}

- (void)syncSubpathOfRoot:(NSString *)path {
    NSString *localPath = [NSString stringWithFormat:@"%@%@", self.root, path];
    NSString *remotePath = [NSString stringWithFormat:@"127.0.0.1::sync%@", [path stringByDeletingLastPathComponent]];
    NSString *rsyncCommand = @"/usr/bin/rsync";
    NSArray *rsyncArguments = @[
            @"--port",
            @"2873",
            @"-rtqz",
            @"--delete",
            @"--links",
            @"--exclude=\".git\"",
            localPath,
            remotePath
    ];
    [[IMProcessManager new] run:rsyncCommand withArguments:rsyncArguments];
}

- (void)runRsyncDaemon {
    NSString *configArgument = [NSString stringWithFormat:@"--config=%@", [[NSBundle mainBundle] pathForResource:@"rsyncd" ofType:@"conf"]];
    [[IMProcessManager new] run:@"/usr/bin/rsync" withArguments:@[
            @"--daemon",
            @"--no-detach",
            configArgument
    ]];
}

- (void)syncAll {
    for (NSString *subpath in self.watchedDirs) {
        [self syncSubpathOfRoot:subpath];
    }
}


@end