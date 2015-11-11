//
//  FullSizeImageViewController.m
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "FullSizeImageViewController.h"

@interface FullSizeImageViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation FullSizeImageViewController {
    UIImage *_image;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = image;
        [self.view setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Properties

-(UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setImage:_image];
    }
    return _imageView;
}

@end
