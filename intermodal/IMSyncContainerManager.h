//
// Created by Josh Butts on 3/18/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMVirtualMachine.h"

#define SYNC_CONTAINER_NAME @"intermodal-sync"
#define INOTIFY_CONTAINER_NAME @"intermodal-inotify"
#define CONTAINER_TAG @"intermodal/sync:0.3.2"


@interface IMSyncContainerManager : NSObject

+ (void)runContainer;
+ (void)stopContainer;

@end