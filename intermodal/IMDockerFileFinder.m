//
// Created by Josh Butts on 3/11/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMDockerFileFinder.h"


@implementation IMDockerFileFinder

- (id)initWithPath:(NSString *)path {
    self = [super init];
    self.path = path;
    return self;
}

- (NSArray *)scanForDockerfiles {
    return [self scanForFilename:@"Dockerfile"];
}

- (NSArray *)scanForDockerComposeFiles {
    return [self scanForFilename:@"docker-compose.yml"];
}


- (NSArray *)scanForFilename:(NSString *)filename {
    NSMutableArray *paths = [NSMutableArray new];
    NSFileManager *fm = [NSFileManager new];
    NSDirectoryEnumerator *de = [fm enumeratorAtURL:[NSURL URLWithString:self.path] includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    for (NSURL *item in de) {
        NSString *directoryPath = [item path];
        NSString *file = [NSString stringWithFormat:@"%@/%@", directoryPath, filename];
        if ([fm fileExistsAtPath:file]) {
            NSLog(@"Found %@ at %@", filename, file);
            [paths addObject:file];
        }
    }
    return [NSArray arrayWithArray:paths];
}


@end