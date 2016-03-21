//
// Created by Josh Butts on 3/16/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMVirtualMachine.h"

@implementation IMVirtualMachine

+ (void)start {
    NSTask *task = [NSTask launchedTaskWithLaunchPath:VBOXMANAGE arguments:@[
            @"startvm",
            @"--type",
            @"headless",
            VM_NAME
    ]];
    [task waitUntilExit];
}

+ (void)stop {
    NSTask *task = [NSTask launchedTaskWithLaunchPath:VBOXMANAGE arguments:@[
            @"controlvm",
            VM_NAME,
            @"poweroff",
    ]];
    [task waitUntilExit];
}

+ (void)forwardPorts:(NSArray *)ports {

    NSString *existingPortForwardCommand = [NSString stringWithFormat:@"%@ showvminfo %@ --details | grep -i \"nic 1 rule\" | cut -d\" \" -f8", VBOXMANAGE, VM_NAME];
    NSTask *listPortsTask = [NSTask new];
    NSPipe *stdOut = [NSPipe pipe];
    listPortsTask.launchPath = @"/bin/bash";
    listPortsTask.arguments = @[@"-l", @"-c", existingPortForwardCommand];
    [listPortsTask setStandardOutput:stdOut];
    [listPortsTask launch];
    [listPortsTask waitUntilExit];
    NSString *result = [[NSString alloc] initWithData:[[stdOut fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    NSArray *portNames = [result componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *portName in portNames) {
        if ([portName isEqualToString:@""]) {
            continue;
        }

        NSTask *deletePortTask = [NSTask new];
        deletePortTask.launchPath = VBOXMANAGE;
        deletePortTask.arguments = @[
            @"modifyvm",
            VM_NAME,
            @"--natpf1",
            @"delete",
            [portName stringByReplacingOccurrencesOfString:@"," withString:@""]
        ];
        [deletePortTask launch];
        [deletePortTask waitUntilExit];
    }

    NSMutableArray *natPfArgs = [[NSMutableArray alloc] initWithArray:@[
        @"modifyvm",
            VM_NAME,
            @"--natpf1",
            @"docker,tcp,,2375,,2375",
            @"--natpf1",
            @"ssh,tcp,,2222,,22",
            @"--natpf1",
            @"rsync,tcp,,2873,,2873",
            @"--natpf1",
            @"inotify,tcp,,2874,,2874"
    ]];

    for (NSNumber *n in ports) {
        [natPfArgs addObject:@"--natpf1"];
        [natPfArgs addObject:[NSString stringWithFormat:@"%@,tcp,,%@,,%@", n, n, n]];
    }

    NSTask *task = [NSTask launchedTaskWithLaunchPath:VBOXMANAGE arguments:natPfArgs];
    [task waitUntilExit];
}

+ (bool)exists {
    NSTask *task = [NSTask launchedTaskWithLaunchPath:VBOXMANAGE arguments:@[@"showvminfo", VM_NAME]];
    [task waitUntilExit];
    int exitCode = [task terminationStatus];
    if (exitCode == 0) {
        NSLog(@"checked for vm, found it");
        return YES;
    } else {
        NSLog(@"checked for vm, didn't find it");
        return NO;
    }
}

+ (void)importFromOVA {
    NSTask *task = [NSTask launchedTaskWithLaunchPath:VBOXMANAGE arguments:@[@"import", [[NSBundle mainBundle] pathForResource:VM_NAME ofType:@"ova"]]];
    [task waitUntilExit];
}

+ (bool)dockerIsRunning {
    NSTask *task = [NSTask launchedTaskWithLaunchPath:[[NSBundle mainBundle] pathForResource:@"docker" ofType:nil] arguments:@[@"-H", DOCKER_HOST, @"version"]];
    [task waitUntilExit];
    int exitCode = [task terminationStatus];
    return exitCode == 0;
}


@end