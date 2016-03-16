//
// Created by Josh Butts on 3/15/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

#define FLUSH_ROLLUP_DURATION 3

@class IMProcessManager;

@interface IMInboundSyncManager : NSObject <GCDAsyncSocketDelegate>

@property GCDAsyncSocket *listenSocket;
@property GCDAsyncSocket *connectedSocket;
@property dispatch_queue_t queue;
@property IMProcessManager *pm;
@property NSMutableOrderedSet *syncQueue;
@property int lastFlushed;
@property NSString *remoteRoot;
@property NSString *localRoot;
@property NSTimer *flushTimer;

- (id)initWithLocalRoot:(NSString *)localRoot remoteRoot:(NSString *)remoteRoot processManager:(IMProcessManager *)processManager;
- (void)listen;
- (void)flush;


@end