//
// Created by Josh Butts on 3/15/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMInboundSyncManager.h"
#import "IMProcessManager.h"


@implementation IMInboundSyncManager

-(id)initWithLocalRoot:(NSString *)localRoot remoteRoot:(NSString *)remoteRoot processManager:(IMProcessManager *)processManager {
    self = [super init];
    self.pm = processManager;
    self.queue = dispatch_queue_create("com.joshbutts.intermodal.inotify", NULL);
    self.listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.queue];
    self.remoteRoot = remoteRoot;
    self.localRoot = localRoot;
    self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:FLUSH_ROLLUP_DURATION target:self selector:@selector(flush) userInfo:nil repeats:YES];
    return self;
}

- (void)listen {
    NSLog(@"Intermodal InotifyServer listening on 2874");
    NSError *error = nil;
    if (![self.listenSocket acceptOnPort:2874 error:&error])
    {
        NSLog(@"Socket error: %@", error);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSString *fileChanged = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *changedPath = [fileChanged stringByDeletingLastPathComponent];
        [self.syncQueue addObject:changedPath];
    });
    [sock readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"Received inotify connection");
    if (self.connectedSocket != nil) {
        [self.connectedSocket disconnect];
    }
    self.connectedSocket = newSocket;
    [self.connectedSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)flush {
    NSArray *pathsToSync;
    @synchronized (self) {
        pathsToSync = [self.syncQueue array];
        self.syncQueue = [NSMutableOrderedSet new];
        self.lastFlushed = (int) [[NSDate date] timeIntervalSince1970];
    }
    for (NSString *path in pathsToSync) {
        NSString *relativeSubpath = [path stringByReplacingOccurrencesOfString:self.remoteRoot withString:@""];
        NSString *localPath = [[NSString stringWithFormat:@"%@%@", self.localRoot, relativeSubpath] stringByDeletingLastPathComponent];
        NSString *remotePath = [[NSString stringWithFormat:@"127.0.0.1::%@", path] stringByReplacingOccurrencesOfString:@"::/" withString:@"::"];
        NSString *rsyncCommand = @"/usr/bin/rsync";
        NSArray *rsyncArguments = @[
                @"--port",
                @"2873",
                @"-rtqz",
                @"--links",
                @"--exclude=.git/",
                remotePath,
                localPath

        ];
        //NSLog(@"%@", rsyncArguments);
        [self.pm run:rsyncCommand withArguments:rsyncArguments];
    }
}



@end