//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMSyncManager.h"

@implementation IMSyncManager

- (void)listen {
    NSString *path = @"/Users/josh/projects";
    NSLog(@"Intermodal SyncManager listening on %@", path);
    NSArray *urls  = @[[NSURL URLWithString:path]];
    self.fsEventsStream = [[CDEvents alloc] initWithURLs:urls block:
        ^(CDEvents *watcher, CDEvent *event) {
            NSLog(
                    @"URLWatcher: %@\nEvent: %@",
                    watcher,
                    event
            );
        }
    ];
}


@end