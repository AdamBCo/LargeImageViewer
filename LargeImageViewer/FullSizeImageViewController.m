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
@property (nonatomic, strong) UIBarButtonItem *closeButton;

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
    
    [self.navigationItem setRightBarButtonItem:self.closeButton];
    [self.view addSubview:self.imageView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

-(void)onCloseButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(UIBarButtonItem *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(onCloseButtonPressed:)];
    }
    return _closeButton;
}

@end
