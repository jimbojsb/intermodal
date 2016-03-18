//
// Created by Josh Butts on 3/16/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VM_STATE_RUNNING 1
#define VM_STATE_STOPPED 2
#define VM_STATE_ABORTED 3
#define VM_STATE_SAVED 4

@interface IMVirtualMachine : NSObject

@property NSString *name;
@property NSArray *forwardedPorts;
@property int state;

- (void)start;
- (void)stop;
- (void)forwardPorts;
- (void)delete;
- (void)refresh;
+ (void)importFromOVA;
+ (void)removeExisting;

@end