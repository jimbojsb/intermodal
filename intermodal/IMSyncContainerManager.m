//
// Created by Josh Butts on 3/18/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMSyncContainerManager.h"


@implementation IMSyncContainerManager

+ (void)runContainer {
    NSArray *rsyncArgs = @[
            @"-H",
            DOCKER_HOST,
            @"run",
            @"-d",
            @"--name",
            SYNC_CONTAINER_NAME,
            @"--privileged",
            @"--restart",
            @"always",
            @"-p",
            @"2873:2873",
            @"-v",
            @"/sync:/sync",
            CONTAINER_TAG,
            @"rsyncd.sh"
    ];
    NSTask *rsyncdTask = [NSTask launchedTaskWithLaunchPath:[[NSBundle mainBundle] pathForResource:@"docker" ofType:nil] arguments:rsyncArgs];
    [rsyncdTask waitUntilExit];

    NSArray *inotifyArgs = @[
            @"-H",
            DOCKER_HOST,
            @"run",
            @"-d",
            @"--name",
            INOTIFY_CONTAINER_NAME,
            @"--privileged",
            @"--restart",
            @"always",
            @"-p",
            @"2874:2874",
            @"-v",
            @"/sync:/sync",
            CONTAINER_TAG,
            @"rsyncd.sh"
    ];
    NSTask *inotifyTask = [NSTask launchedTaskWithLaunchPath:[[NSBundle mainBundle] pathForResource:@"docker" ofType:nil] arguments:inotifyArgs];
    [inotifyTask waitUntilExit];
}

+ (void)stopContainer {
    NSTask *rsyncdKillTask = [NSTask launchedTaskWithLaunchPath:[[NSBundle mainBundle] pathForResource:@"docker" ofType:nil] arguments:@[@"-H", DOCKER_HOST, @"rm", @"-f", SYNC_CONTAINER_NAME]];
    [rsyncdKillTask waitUntilExit];
    NSTask *inotifyKillTask = [NSTask launchedTaskWithLaunchPath:[[NSBundle mainBundle] pathForResource:@"docker" ofType:nil] arguments:@[@"-H", DOCKER_HOST, @"rm", @"-f", INOTIFY_CONTAINER_NAME]];
    [inotifyKillTask waitUntilExit];
}

@end