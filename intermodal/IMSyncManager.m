//
// Created by Josh Butts on 2/29/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMDockerFileFinder.h"
#import "IMSyncManager.h"
#import "IMProcessManager.h"
#import "IMProject.h"

@implementation IMSyncManager

- (id)initWithLocalRoot:(NSString *)root processManager:(IMProcessManager *)processManager {
    self = [super init];
    self.localRoot = root;
    self.projects = [self findProjects];
    self.pm = processManager;
    return self;
}

- (void)listen {
    NSLog(@"listening for fsevents on %i projects in %@", (int) [self.projects count], self.localRoot);

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
                       [self syncPath:absolutePath toPath:[self remotePathWithLocalPath:absolutePath] withProject:[self projectContainingPath:absolutePath]];
                   }
               onRunLoop:[NSRunLoop currentRunLoop]
    sinceEventIdentifier:kCDEventsSinceEventNow
    notificationLantency:0.5
 ignoreEventsFromSubDirs:NO
             excludeURLs:ignoredUrls
     streamCreationFlags:kCDEventsDefaultEventStreamFlags];
}

- (void)syncPath:(NSString *)fromPath toPath:(NSString *)toPath withProject:(IMProject *)project {
    NSString *rsyncCommand = @"/usr/bin/rsync";
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
    [self.pm run:rsyncCommand withArguments:rsyncArguments];
}

- (void)syncAllLocalToRemote {
    for (IMProject *p in self.projects) {
        [self syncPath:p.absolutePath toPath:[self remotePathWithLocalPath:p.absolutePath] withProject:p];
    }
}

- (NSArray *)findProjects {
    NSMutableArray *projects = [NSMutableArray new];
    NSFileManager *fm = [NSFileManager new];
    NSDirectoryEnumerator *de = [fm enumeratorAtURL:[NSURL URLWithString:self.localRoot] includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
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
    return [[[localPath stringByReplacingOccurrencesOfString:self.localRoot withString:@"127.0.0.1::sync"] stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
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


@end