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
    
    if (![self.largeImageDownloadQueue.operations containsObject:imageDownloadOperation]) {
        [imageDownloadOperation setDelegate:self];
        [self.largeImageDownloadQueue addOperation:imageDownloadOperation];
    }
}

#pragma mark - ImageDownloadOperationDelegate Methods

-(void)imageDownloadOperationDidFail:(ImageDownloadOperation *)operation withError:(NSError *)error {
    [self.delegate imageManagerDidFail:self withError:error];
}

-(void)imageDownloadOperationDidFinish:(ImageDownloadOperation *)operation withImage:(UIImage *)image{
    [self.imagesArray addObject:image];
    [self.delegate imageManagerDidUpdate:self];
}

-(void)imageDownloadOperation:(ImageDownloadOperation *)operation didUpdateWithProgress:(float)progress {
    [self.delegate imageManager:self didUpdateWithProgress:progress];
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

-(NSMutableArray *)imageURLsArray {
    if (_imageURLsArray) {
        return _imageURLsArray;
    }
    
    _imageURLsArray = [[NSMutableArray alloc] initWithObjects:
                       [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/8/81/Carn_Eige_Scotland_-_Full_Panorama_from_Summit.jpeg"],
                       [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/1/1c/NGC_6302_Hubble_2009.full.jpg"],
                       [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/3/3c/Merging_galaxies_NGC_4676_(captured_by_the_Hubble_Space_Telescope).jpg"],
                       [NSURL URLWithString:@"http://spaceflight.nasa.gov/gallery/images/shuttle/sts-125/hires/s125e012033.jpg"],
                       [NSURL URLWithString:@"http://mayang.com/textures/Plants/images/Flowers/large_flower_6080110.JPG"],
                       [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/3/3d/LARGE_elevation.jpg"],
                       [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/c/ca/Star-forming_region_S106_(captured_by_the_Hubble_Space_Telescope).jpg"],
                       [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/c/cc/ESC_large_ISS022_ISS022-E-11387-edit_01.JPG"],
                       [NSURL URLWithString:@"http://www.highreshdwallpapers.com/wp-content/uploads/2011/09/Large-Format-HD-Wallpaper.jpg"],
                       [NSURL URLWithString:@"http://www.largeformatphotography.info/qtluong/delicatearch.big.jpeg" ], nil];
    
    
    return _imageURLsArray;
}


@end
