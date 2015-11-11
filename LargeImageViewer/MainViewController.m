//
//  MainViewController.m
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "MainViewController.h"
#import "GalleryViewController.h"
#import "FullSizeImageViewController.h"
#import "ImageManager.h"
#import "ImageCollectionViewCell.h"
#import "UIView+Frame.h"

@interface MainViewController () <ImageManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation MainViewController {
    int _oldImageCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //Start Downloading Images
    for (NSURL *url in [ImageManager sharedInstance].imageURLsArray) {
        [[ImageManager sharedInstance] setDelegate:self];
        [[ImageManager sharedInstance] downloadImageWithURL:url];
    }
    
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.collectionView];

    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Update UI Elements
    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *titleString = [NSString stringWithFormat:@"%lu / %lu",(unsigned long)[ImageManager sharedInstance].imagesArray.count, (unsigned long)[ImageManager sharedInstance].imageURLsArray.count];
        [self setTitle:titleString];
        
        _oldImageCount = (int)[ImageManager sharedInstance].imagesArray.count;
        [self.collectionView reloadData];
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ImageManagerDelegate Methods

-(void)imageManagerDidUpdate:(ImageManager *)manager {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *titleString = [NSString stringWithFormat:@"%lu / %lu",(unsigned long)[ImageManager sharedInstance].imagesArray.count, (unsigned long)[ImageManager sharedInstance].imageURLsArray.count];
        [self setTitle:titleString];
            
            NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
            
            for (int i = 0; i < [ImageManager sharedInstance].imagesArray.count - _oldImageCount; i++) {
                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i+_oldImageCount inSection:0]];
            }
            
            [self.collectionView performBatchUpdates:^{
                
                [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
                
            } completion:^(BOOL finished) {
                _oldImageCount = (int)[ImageManager sharedInstance].imagesArray.count;

            }];
    });
    
}

-(void)imageManager:(ImageManager *)manager didUpdateWithProgress:(float)progress {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress];
    });

}

-(void)imageManagerDidFail:(ImageManager *)manager withError:(NSError *)error {
    
    NSString *errorMessage = [NSString stringWithFormat:@"ERROR: %@",error.localizedDescription];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:errorMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       //Update UI Elements
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           NSString *titleString = [NSString stringWithFormat:@"%lu / %lu",(unsigned long)[ImageManager sharedInstance].imagesArray.count, (unsigned long)[ImageManager sharedInstance].imageURLsArray.count];
                                           [self setTitle:titleString];
                                           
                                           _oldImageCount = (int)[ImageManager sharedInstance].imagesArray.count;
                                           
                                       });
                                   }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];


}


#pragma mark - CollectionView DataSource

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(.25, 0, .25, .25);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return .5;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return .5;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [ImageManager sharedInstance].imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = [[ImageManager sharedInstance].imagesArray objectAtIndex:indexPath.row];
    ImageCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.imageView setImage:image];
    });
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *imageViewControllers = [NSMutableArray array];
    
    for (UIImage *image in [ImageManager sharedInstance].imagesArray) {
        FullSizeImageViewController *fullSizeImageViewController = [[FullSizeImageViewController alloc] initWithImage:image];
        [imageViewControllers addObject:fullSizeImageViewController];
    }
    
    GalleryViewController *galleryViewController = [[GalleryViewController alloc] initWithViewControllers:[NSArray arrayWithArray:imageViewControllers] andIndex:@(indexPath.row).intValue];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    [self presentViewController:navigationController animated:YES completion:nil];

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(([UIScreen mainScreen].bounds.size.width/3)-.5, ([UIScreen mainScreen].bounds.size.width/3)-.5);
}


#pragma mark - Properties

-(UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 3, self.view.width, self.view.height) collectionViewLayout:layout];
        [_collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier]];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        
        
        UINib *nib = [UINib nibWithNibName:[ImageCollectionViewCell reuseIdentifier] bundle: nil];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier]];

    }
    return _collectionView;
}

-(UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.progressView.bottom, self.view.width, 44)];
        [_countLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _countLabel;
}

-(UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0,0, self.view.width, 3)];
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
        [_progressView setTransform:transform];
        [_progressView setProgressTintColor:[UIColor redColor]];

    }
    return _progressView;
}


@end
