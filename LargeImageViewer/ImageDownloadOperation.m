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
    
    if (self.isCancelled) {
        return;
    }
    
    if (self.imageURL == nil) {
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
    
    UIImage *image = [UIImage imageWithCGImage:ThumbnailImageAtPath(location)];
    [self.delegate imageDownloadOperationDidFinish:self withImage:image];
    [self completeOperation];
    
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
