//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMSyncManager.h"

@implementation IMSyncManager

- (id)init {
    self = [super init];
    self.root = NSHomeDirectory();
    self.projects = [self findProjects];
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
//                       [self syncLocalPath:absolutePath toRemotePath:[self remotePathWithLocalPath:absolutePath]];
                   }
               onRunLoop:[NSRunLoop currentRunLoop]
    sinceEventIdentifier:kCDEventsSinceEventNow
    notificationLantency:0.5
 ignoreEventsFromSubDirs:NO
             excludeURLs:ignoredUrls
     streamCreationFlags:kCDEventsDefaultEventStreamFlags];
}



- (void)startupSync {
    for (IMProject *p in self.projects) {

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

- (IMProject *)projectContainingPath:(NSString *)path {
    for (IMProject *p in self.projects) {
        if ([path hasPrefix:p.absoluteLocalPath]) {
            return p;
        }
    }
    return nil;
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
//    dispatch_async(dispatch_get_main_queue(), ^ {
//        NSString *fileChanged = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSString *changedPath = [fileChanged stringByDeletingLastPathComponent];
//        [self.inotifyFlushQueue addObject:changedPath];
//    });
//    [sock readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
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
    self.fseventSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("com.joshbutts.intermodal.fsevents", NULL)];
    NSError *err = nil;
    [self.fseventSocket connectToHost:@"127.0.0.1" onPort:2873 error:&err];
    if (err != nil) {
        NSLog(@"%@", err);
    }
}

@end