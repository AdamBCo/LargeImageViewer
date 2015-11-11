//
//  ConcurrentOperation.m
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "ConcurrentOperation.h"

@interface ConcurrentOperation ()

@property (nonatomic, readwrite, getter = isFinished)  BOOL finished;
@property (nonatomic, readwrite, getter = isExecuting) BOOL executing;

@end

@implementation ConcurrentOperation

@synthesize finished  = _finished;
@synthesize executing = _executing;

- (void)start
{
    if ([self isCancelled]) {
        self.finished = YES;
        return;
    }
    
    self.executing = YES;
    
    [self main];
}

#pragma mark - NSOperation methods

- (void)completeOperation
{
    self.executing = NO;
    self.finished = YES;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)setExecuting:(BOOL)executing
{
    if (_executing != executing) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)setFinished:(BOOL)finished
{
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
}

@end
