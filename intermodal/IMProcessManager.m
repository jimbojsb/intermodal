//
// Created by Josh Butts on 3/1/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMProcessManager.h"


@implementation IMProcessManager

- (id)init {
    self = [super init];
    self.execQueue = dispatch_queue_create("com.joshbutts.intermodal.exec", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (void)run:(NSString *)command withArguments:(NSArray *)arguments {
    dispatch_async(self.execQueue, ^{
        [self runAndWait:command withArguments:arguments];
    });
}

- (void)runAndWait:(NSString *)command withArguments:(NSArray *)arguments {
    NSTask *task = [self taskWithCommand:command arguments:arguments];
    NSLog(@"running %@ %@", command, [arguments componentsJoinedByString:@" "]);
    [task launch];
    [task waitUntilExit];
}

- (NSTask *)taskWithCommand:(NSString *)command arguments:(NSArray *)arguments {
    NSTask *task = [NSTask new];
    task.launchPath = command;
    task.arguments = arguments;
    return task;
}


@end