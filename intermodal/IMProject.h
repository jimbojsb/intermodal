//
// Created by Josh Butts on 3/17/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMProject : NSObject

@property NSArray *ports;
@property NSArray *outboundExclude;
@property NSArray *inboundInclude;
@property NSString *projectFilePath;
@property NSString *absoluteLocalPath;
@property NSString *absoluteRemotePath;

- (id)initWithProjectFilePath:(NSString *)path;
- (void)loadProjectFileSettings;

@end