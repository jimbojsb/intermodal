//
// Created by Josh Butts on 3/16/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VM_NAME @"Intermodal-0.4"
#define VBOXMANAGE @"/usr/local/bin/VBoxManage"
#define DOCKER_HOST @"tcp://127.0.0.1:2375"

@interface IMVirtualMachine : NSObject

@property NSString *name;
@property NSArray *forwardedPorts;
@property bool isRunning;

+ (void)start;
+ (void)stop;
+ (void)forwardPorts:(NSArray *)ports;
+ (void)importFromOVA;
+ (bool)exists;
+ (bool)dockerIsRunning;

@end