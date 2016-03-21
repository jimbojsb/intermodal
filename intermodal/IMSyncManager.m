//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMSyncManager.h"

@implementation IMSyncManager

- (id)initWithRoot:(NSString *)root {
    self = [super init];
    self.root = root;
    self.projects = [self findProjects];
    self.rsyncDispatchQueue = dispatch_queue_create("com.joshbutts.intermodal.rsync", DISPATCH_QUEUE_SERIAL);
    self.inotifyReceiveQueue = dispatch_queue_create("com.joshbutts.intermodal.inotify", NULL);
    self.inotifyFlushQueue = [NSMutableOrderedSet new];
    return self;
}

- (void)listen {
    NSLog(@"listening for fsevents on %i projects in %@", (int) [self.projects count], self.root);

    NSMutableArray *urls = [NSMutableArray new];
    NSMutableArray *ignoredUrls = [NSMutableArray new];
    for (IMProject *p in self.projects) {
        [urls addObject:[NSURL URLWithString:p.absolutePath]];
        [ignoredUrls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@/.git", p.absolutePath]]];
        if ([p.outboundExclude count] > 0) {
            for (NSString *relativeExcludePath in p.outboundExclude) {
                NSString *absoluteExcludePath = [NSString stringWithFormat:@"%@/%@", p.absolutePath, relativeExcludePath];
                [ignoredUrls addObject:[NSURL URLWithString:absoluteExcludePath]];
            }
        }
    }

    self.fsEventsStream = [[CDEvents alloc]
            initWithURLs:urls
                   block:^(CDEvents *watcher, CDEvent *event) {
                       NSString *absolutePath = [event.URL path];
                       [self syncLocalPath:absolutePath toRemotePath:[self remotePathWithLocalPath:absolutePath]];
                   }
               onRunLoop:[NSRunLoop currentRunLoop]
    sinceEventIdentifier:kCDEventsSinceEventNow
    notificationLantency:0.5
 ignoreEventsFromSubDirs:NO
             excludeURLs:ignoredUrls
     streamCreationFlags:kCDEventsDefaultEventStreamFlags];
}

- (void)syncLocalPath:(NSString *)fromPath toRemotePath:(NSString *)toPath {
    IMProject *project = [self projectContainingPath:fromPath];
    NSMutableArray *rsyncArguments = [[NSMutableArray alloc] initWithArray:@[
            @"--port",
            @"2873",
            @"-rtqz",
            @"--delete",
            @"--links",
            @"--exclude=.git/"
    ]];

    if ([project.outboundExclude count] > 0) {
        for (NSString *excludePath in project.outboundExclude) {
            [rsyncArguments addObject:[NSString stringWithFormat:@"--exclude=%@", excludePath]];
        }
    }

    [rsyncArguments addObject:fromPath];
    [rsyncArguments addObject:toPath];
    [self rsyncWithArguments:rsyncArguments];
}

- (void)syncRemotePath:(NSString *)fromPath toLocalPath:(NSString *)toPath {
    IMProject *project = [self projectContainingPath:toPath];
    NSMutableArray *rsyncArguments = [[NSMutableArray alloc] initWithArray:@[
            @"--port",
            @"2873",
            @"-rtqz",
            @"--delete",
            @"--links",
            @"--exclude=*"
    ]];

    if ([project.inboundInclude count] > 0) {
        for (NSString *excludePath in project.inboundInclude) {
            [rsyncArguments addObject:[NSString stringWithFormat:@"--include=%@", excludePath]];
        }
    }

    [rsyncArguments addObject:fromPath];
    [rsyncArguments addObject:toPath];
    [self rsyncWithArguments:rsyncArguments];
}


- (void)syncAllLocalToRemote {
    for (IMProject *p in self.projects) {
        [self syncLocalPath:p.absolutePath toRemotePath:[self remotePathWithLocalPath:p.absolutePath]];
    }
}

- (NSArray *)findProjects {
    NSMutableArray *projects = [NSMutableArray new];
    NSFileManager *fm = [NSFileManager new];
    NSDirectoryEnumerator *de = [fm enumeratorAtURL:[NSURL URLWithString:self.root] includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    for (NSURL *item in de) {
        NSString *directoryPath = [item path];
        NSString *file = [NSString stringWithFormat:@"%@/%@", directoryPath, @"intermodal.plist"];
        if ([fm fileExistsAtPath:file]) {
            [projects addObject:[[IMProject alloc] initWithProjectFilePath:file]];
            NSLog(@"Found project at %@", directoryPath);
        }
    }
    return [NSArray arrayWithArray:projects];
}

- (NSString *)remotePathWithLocalPath:(NSString *)localPath {
    return [[[localPath stringByReplacingOccurrencesOfString:self.root withString:@"127.0.0.1::sync"] stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
}

- (NSString *)localPathWithRemotePath:(NSString *)remotePath {
    return nil;
}

- (IMProject *)projectContainingPath:(NSString *)path {
    for (IMProject *p in self.projects) {
        if ([path hasPrefix:p.absolutePath]) {
            return p;
        }
    }
    return nil;
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSString *fileChanged = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *changedPath = [fileChanged stringByDeletingLastPathComponent];
        [self.inotifyFlushQueue addObject:changedPath];
    });
    [sock readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Made inotifystream connection");
    if (self.connectedSocket != nil) {
        [self.connectedSocket disconnect];
    }
    self.connectedSocket = sock;
    [self.connectedSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)connectToInotifyStream {
    self.inotifySocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.inotifyReceiveQueue];
    NSError *err = nil;
    [self.inotifySocket connectToHost:@"127.0.0.1" onPort:2874 error:&err];
    if (err != nil) {
        NSLog(@"%@", err);
    }
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(inotifyFlush) userInfo:nil repeats:YES];
}

- (void)inotifyFlush {
    NSArray *pathsToSync;
    @synchronized (self) {
        pathsToSync = [self.inotifyFlushQueue array];
        self.inotifyFlushQueue = [NSMutableOrderedSet new];
    }
    for (NSString *path in pathsToSync) {
        NSString *remoteRsyncPath = [NSString stringWithFormat:@"127.0.0.1::%@", path];
        [self syncRemotePath:remoteRsyncPath toLocalPath:[self localPathWithRemotePath:remoteRsyncPath]];
    }
}

- (void)rsyncWithArguments:(NSArray *)args {
    dispatch_async(self.rsyncDispatchQueue, ^{
        NSLog(@"rsync %@", [args componentsJoinedByString:@" "]);
        [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/rsync" arguments:args] waitUntilExit];
    });
}


@end