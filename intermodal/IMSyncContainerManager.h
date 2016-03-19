//
// Created by Josh Butts on 3/18/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMSyncContainerManager : NSObject

- (void)runContainer;
- (void)stopContainer;
- (bool)containerIsRunning;

@end