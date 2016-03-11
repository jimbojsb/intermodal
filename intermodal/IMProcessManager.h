//
// Created by Josh Butts on 3/1/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMProcessManager : NSObject

- (void) run:(NSString *)command withArguments:(NSArray *)arguments;

@end