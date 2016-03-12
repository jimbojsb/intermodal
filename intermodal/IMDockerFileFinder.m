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

- (NSArray *)scan {
    NSMutableArray *paths = [NSMutableArray new];
    NSFileManager *fm = [NSFileManager new];
    NSDirectoryEnumerator *de = [fm enumeratorAtURL:[NSURL URLWithString:self.path] includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    for (NSURL *item in de) {
        NSString *directoryPath = [item path];
        NSString *dockerFile = [NSString stringWithFormat:@"%@/%@", directoryPath, @"Dockerfile"];
        if ([fm fileExistsAtPath:dockerFile]) {
            NSLog(@"Found dockerfile at %@", dockerFile);
            [paths addObject:directoryPath];
        }
    }
    return [NSArray arrayWithArray:paths];
}


@end