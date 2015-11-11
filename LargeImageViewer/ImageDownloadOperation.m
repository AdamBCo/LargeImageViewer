//
//  ImageDownloadOperation.m
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "ImageDownloadOperation.h"

@interface ImageDownloadOperation () <NSURLSessionDownloadDelegate>

@end

@implementation ImageDownloadOperation

- (instancetype)initWithImageURL:(NSURL *)imageURL
{
    self = [super init];
    if (self) {
        _imageURL = imageURL;
    }
    return self;
}

-(BOOL)isEqual:(ImageDownloadOperation *)object {
    
    if (![object isKindOfClass:[ImageDownloadOperation class]]) {
        return NO;
    }
    
    return [object.imageURL.absoluteString isEqualToString:self.imageURL.absoluteString];
}


-(void)main {
    
    if (self.isCancelled) {
        return;
    }
    
    if (self.imageURL == nil) {
        return;
    }
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:self.imageURL options:NSDataReadingUncached error:&error];
    UIImage *image = nil;
    if (data) {
        image = [UIImage imageWithData:data];
        [self.delegate imageDownloadOperationDidFinish:self withImage:image];

    }
    
    

    
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
//    
//    NSURLSessionDownloadTask *imageDownloadTask = [session downloadTaskWithURL:self.imageURL];
//    
//    [imageDownloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate Methods

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    

//    [self.delegate imageDownloadOperation:self didUpdateWithProgress:progress];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    
//    [self.delegate imageDownloadOperationDidFinish:self withLocalURL:location];
    
}



@end
