//
//  ImageManager.m
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "ImageManager.h"
#import "ImageDownloadOperation.h"

@interface ImageManager () <ImageDownloadOperationDelegate>

@property (nonatomic, strong) NSOperationQueue *largeImageDownloadQueue;

@end

@implementation ImageManager

+(instancetype)sharedInstance {
    
    static ImageManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ImageManager alloc] init];
    });
    
    return _sharedInstance;
}


#pragma mark - Public Methods

-(void)downloadImageWithURL:(NSURL *)url {
    
    ImageDownloadOperation *imageDownloadOperation = [[ImageDownloadOperation alloc] initWithImageURL:url];
    [imageDownloadOperation setDelegate:self];
    if (![self.largeImageDownloadQueue.operations containsObject:imageDownloadOperation]) {
        [self.largeImageDownloadQueue addOperation:imageDownloadOperation];
    }
}

#pragma mark - ImageDownloadOperationDelegate Methods

-(void)imageDownloadOperationDidFinish:(ImageDownloadOperation *)operation withImage:(UIImage *)image{
    [self.imagesArray addObject:image];
    [self.delegate imageManagerDidUpdate:self];

}

-(void)imageDownloadOperation:(ImageDownloadOperation *)operation didUpdateWithProgress:(float)progress {
    self.imageDownloadProgress = progress;
    [self.delegate imageManagerDidUpdate:self];
}


#pragma mark - Properties

-(NSOperationQueue *)largeImageDownloadQueue {
    if (!_largeImageDownloadQueue) {
        _largeImageDownloadQueue = [[NSOperationQueue alloc] init];
        [_largeImageDownloadQueue setName:@"Large Image Download Queue"];
        [_largeImageDownloadQueue setMaxConcurrentOperationCount:1];

    }
    return _largeImageDownloadQueue;
}

-(NSMutableArray *)imagesArray {
    if (!_imagesArray) {
        _imagesArray = [NSMutableArray array];
    }
    return _imagesArray;
}


@end
