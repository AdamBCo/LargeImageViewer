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
        
//    NSError *error = nil;
//    NSData *data = [NSData dataWithContentsOfURL:self.imageURL options:NSDataReadingUncached error:&error];
//    if (data) {
//        
//        
//        UIImage *image = [UIImage imageWithCGImage:ThumbnailImageFromData(data, 100000000)];
//        [self.delegate imageDownloadOperationDidFinish:self withImage:image];
//        [self completeOperation];
//
//    }
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

CGImageRef ThumbnailImageAtPath (NSURL *location) {
    // Create the image source
    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef) location, NULL);
    // Create thumbnail options
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(640)
                                                           };
    // Generate the thumbnail
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options); 
    CFRelease(src);
    
    // Make sure the thumbnail image exists before continuing.
    if (thumbnail == NULL){
        fprintf(stderr, "Thumbnail image not created from image source.");
        return NULL;
    }
    
    return thumbnail;
}



CGImageRef ThumbnailImageFromData (NSData * data, NSInteger imageSize)
{
    CGImageRef        myThumbnailImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
    CFNumberRef       thumbnailSize;
    
    // Create an image source from NSData; no options.
    myImageSource = CGImageSourceCreateWithData((CFDataRef)data,
                                                NULL);
    // Make sure the image source exists before continuing.
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    
    // Package the integer as a  CFNumber object. Using CFTypes allows you
    // to more easily create the options dictionary later.
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    // Set up the thumbnail options.
    myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    myValues[2] = (CFTypeRef)thumbnailSize;

    
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    
    // Create the thumbnail image using the specified options.
    myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,
                                                           0,
                                                           myOptions);
    // Release the options dictionary and the image source
    // when you no longer need them.
    CFRelease(thumbnailSize);
    CFRelease(myOptions);
    CFRelease(myImageSource);
    
    // Make sure the thumbnail image exists before continuing.
    if (myThumbnailImage == NULL){
        fprintf(stderr, "Thumbnail image not created from image source.");
        return NULL;
    }
    
    return myThumbnailImage;
}




@end
