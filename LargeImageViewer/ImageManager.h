//
//  ImageManager.h
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ImageManager;

@protocol ImageManagerDelegate <NSObject>


- (void)imageManagerDidUpdate:(ImageManager *)manager;


@end

@interface ImageManager : NSObject

+(instancetype)sharedInstance;

-(void)downloadImageWithURL:(NSURL *)url;

@property (nonatomic, assign) id <ImageManagerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *imagesArray;

@property float imageDownloadProgress;


@end
