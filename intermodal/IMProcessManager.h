//
// Created by Josh Butts on 3/1/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMProcessManager : NSObject

@property dispatch_queue_t execQueue;

- (void) run:(NSString *)command withArguments:(NSArray *)arguments;
- (void) runAndWait:(NSString *)command withArguments:(NSArray *)arguments;
- (NSTask *)taskWithCommand:(NSString *)command arguments:(NSArray *)arguments;


@end