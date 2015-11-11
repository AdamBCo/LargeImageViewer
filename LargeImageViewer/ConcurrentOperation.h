//
//  ConcurrentOperation.h
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

//*********************************************************************
//This sublclass ensure that the NSOperation will not completele, until
//it's called "isFinished"; therfore ensuring Concurrency in an NSOperationQueue

#import <Foundation/Foundation.h>

@interface ConcurrentOperation : NSOperation

- (void)completeOperation;

@end
