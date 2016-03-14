//
// Created by Josh Butts on 3/1/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMProcessManager.h"


@implementation IMProcessManager

- (void)run:(NSString *)command withArguments:(NSArray *)arguments {
    NSTask *task = [NSTask new];
    task.launchPath = command;
    task.arguments = arguments;
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        NSLog(@"running %@ %@", command, [arguments componentsJoinedByString:@" "]);
        [task launch];
        [task waitUntilExit];
    });
}

@end