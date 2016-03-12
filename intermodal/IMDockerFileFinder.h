//
// Created by Josh Butts on 3/11/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMDockerFileFinder : NSObject

@property NSString *path;

- (id)initWithPath:(NSString *)path;
- (NSArray *)scan;

@end