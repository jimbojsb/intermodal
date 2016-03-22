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
        [urls addObject:[NSURL URLWithString:p.absoluteLocalPath]];
        [ignoredUrls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@/.git", p.absoluteLocalPath]]];
        if ([p.outboundExclude count] > 0) {
            for (NSString *relativeExcludePath in p.outboundExclude) {
                NSString *absoluteExcludePath = [NSString stringWithFormat:@"%@/%@", p.absoluteLocalPath, relativeExcludePath];
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
    [rsyncArguments addObject:[[self rsyncPathWithRemotePath:toPath] stringByDeletingLastPathComponent]];
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
    ]];

    NSString *projectRemoteRelativeRoot = [project.absoluteRemotePath lastPathComponent];
    [rsyncArguments addObject:[NSString stringWithFormat:@"--include=%@/", projectRemoteRelativeRoot]];

    if ([project.inboundInclude count] > 0) {
        for (NSString *includePath in project.inboundInclude) {
            NSArray *includePathComponents = [includePath componentsSeparatedByString:@"/"];
            NSMutableArray *includePathArgumentChunks = [[NSMutableArray alloc] initWithArray:@[projectRemoteRelativeRoot]];
            for (int i = 0; i < [includePathComponents count]; i++) {
                NSString *includePathComponent = includePathComponents[i];
                [includePathArgumentChunks addObject:includePathComponent];
                [rsyncArguments addObject:[NSString stringWithFormat:@"--include=%@", [[includePathArgumentChunks componentsJoinedByString:@"/"] stringByAppendingString:@"/"]]];
            }
            [includePathArgumentChunks addObject:@"***"];
            [rsyncArguments addObject:[NSString stringWithFormat:@"--include=%@", [includePathArgumentChunks componentsJoinedByString:@"/"]]];
        }
    }

    [rsyncArguments addObject:@"--exclude=*"];
    [rsyncArguments addObject:[self rsyncPathWithRemotePath:project.absoluteRemotePath]];
    [rsyncArguments addObject:[project.absoluteLocalPath stringByDeletingLastPathComponent]];
    [self rsyncWithArguments:rsyncArguments];
}


- (void)startupSync {
    for (IMProject *p in self.projects) {
        [self syncLocalPath:p.absoluteLocalPath toRemotePath:[self remotePathWithLocalPath:p.absoluteLocalPath]];
        [self syncRemotePath:[self remotePathWithLocalPath:p.absoluteLocalPath] toLocalPath:p.absoluteLocalPath];
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
    return [localPath stringByReplacingOccurrencesOfString:self.root withString:@"/sync"];
}

- (NSString *)localPathWithRemotePath:(NSString *)remotePath {
    NSRange replaceRange = [remotePath rangeOfString:@"/sync"];
    if (replaceRange.location != NSNotFound){
        NSString *pathWithoutSync = [remotePath stringByReplacingCharactersInRange:replaceRange withString:@""];
        NSString *localPath = [NSString stringWithFormat:@"%@%@", self.root, pathWithoutSync];
        return localPath;
    }
    NSLog(@"Failed to generate an rsync path for %@", remotePath);
    return nil;
}

- (NSString *)rsyncPathWithRemotePath:(NSString *)remotePath {
    NSRange replaceRange = [remotePath rangeOfString:@"/sync"];
    if (replaceRange.location != NSNotFound){
        NSString *pathWithoutSync = [remotePath stringByReplacingCharactersInRange:replaceRange withString:@""];
        NSString *rsyncString = [NSString stringWithFormat:@"127.0.0.1::sync%@", pathWithoutSync];
        return rsyncString;
    }
    NSLog(@"Failed to generate an rsync path for %@", remotePath);
    return nil;
}


- (IMProject *)projectContainingPath:(NSString *)path {
    for (IMProject *p in self.projects) {
        if ([path hasPrefix:p.absoluteLocalPath]) {
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
        [self syncRemotePath:path toLocalPath:[self localPathWithRemotePath:path]];
    }
}

- (void)rsyncWithArguments:(NSArray *)args {
    dispatch_async(self.rsyncDispatchQueue, ^{
        NSLog(@"rsync %@", [args componentsJoinedByString:@" "]);
        [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/rsync" arguments:args] waitUntilExit];
    });
}


@end