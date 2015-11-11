//
//  ImageDownloadOperation.m
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "ImageDownloadOperation.h"
#import <ImageIO/ImageIO.h>


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
    
    //Check if state of operation is cancelled.
    if (self.isCancelled) {
        [self completeOperation];
        return;
    }
    
    
    //Chek for nil URL
    if (self.imageURL == nil) {
        
        NSError *unknownError = [NSError errorWithDomain:@"Missing URL"
                                                    code:420
                                                userInfo:@{NSLocalizedDescriptionKey: @"The URL is missing."}];
        [self.delegate imageDownloadOperationDidFail:self withError:unknownError];
        [self completeOperation];
        
        return;
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:self.imageURL];
    [downloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate Methods

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    [self.delegate imageDownloadOperation:self didUpdateWithProgress:progress];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    //1) Compress image by utilizing the ImageIO framwork
    UIImage *image = [UIImage imageWithCGImage:ThumbnailImageAtPath(location)];
    
    //2) Send image to Delegate
    [self.delegate imageDownloadOperationDidFinish:self withImage:image];
    
    //3) Call completion to end Concurrent Operation
    [self completeOperation];
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.delegate imageDownloadOperationDidFail:self withError:error];
        [self completeOperation];
    }
}

#pragma mark - ImageIO Compression Methods

CGImageRef ThumbnailImageAtPath (NSURL *location) {

    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef) location, NULL);

    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(640)
                                                           };
    // Generate the thumbnail
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options);
    CFRelease(source);
    
    if (thumbnail == NULL){
        fprintf(stderr, "Thumbnail image not created from image source.");
        return NULL;
    }
    
    return thumbnail;
}


@end
