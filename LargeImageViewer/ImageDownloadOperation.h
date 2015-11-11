//
//  ImageDownloadOperation.h
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConcurrentOperation.h"
@class ImageDownloadOperation;

@protocol ImageDownloadOperationDelegate <NSObject>

- (void)imageDownloadOperationDidFinish:(ImageDownloadOperation *)operation withImage:(UIImage *)image;
- (void)imageDownloadOperation:(ImageDownloadOperation *)operation didUpdateWithProgress:(float)progress;

@end


@interface ImageDownloadOperation : ConcurrentOperation

@property (atomic, strong) NSURL *imageURL;

- (instancetype)initWithImageURL:(NSURL *)imageURL;

@property (nonatomic, assign) id <ImageDownloadOperationDelegate> delegate;

@end
