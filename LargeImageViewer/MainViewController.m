//
//  MainViewController.m
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "MainViewController.h"
#import "FullSizeImageViewController.h"
#import "ImageManager.h"
#import "ImageCollectionViewCell.h"
#import "UIView+Frame.h"

@interface MainViewController () <ImageManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *largeImageURLs;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation MainViewController {
    int _oldImageCount;
    BOOL _updatingUI;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UINib *nib = [UINib nibWithNibName:[ImageCollectionViewCell reuseIdentifier] bundle: nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier]];
    
    for (NSURL *url in self.largeImageURLs) {
        [[ImageManager sharedInstance] setDelegate:self];
        [[ImageManager sharedInstance] downloadImageWithURL:url];
    }
    [self.view addSubview:self.collectionView];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ImageManagerDelegate Methods

-(void)imageManagerDidUpdate:(ImageManager *)manager {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        if (!_updatingUI) {
            _updatingUI = YES;
            
            NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
            
            for (int i = 0; i < [ImageManager sharedInstance].imagesArray.count - _oldImageCount; i++)
                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i+_oldImageCount inSection:0]];
            
            [self.collectionView performBatchUpdates:^{
                
                [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
                
            } completion:^(BOOL finished) {
                _oldImageCount = (int)[ImageManager sharedInstance].imagesArray.count;
                _updatingUI = NO;

            }];
        }
        
    });
        

    
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
    
    UIImage *image = [[ImageManager sharedInstance].imagesArray objectAtIndex:indexPath.row];

    FullSizeImageViewController *fullSizeImageViewController = [[FullSizeImageViewController alloc] initWithImage:image];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:fullSizeImageViewController];
    [self presentViewController:navigationController animated:YES completion:nil];

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(([UIScreen mainScreen].bounds.size.width/3)-.5, ([UIScreen mainScreen].bounds.size.width/3)-.5);
}


#pragma mark - Properties



-(UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:[ImageCollectionViewCell reuseIdentifier]];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];

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
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        [_progressView setCenter:self.view.center];

    }
    return _progressView;
}


-(NSArray *)largeImageURLs {
    if (!_largeImageURLs) {
        _largeImageURLs = @[[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/8/81/Carn_Eige_Scotland_-_Full_Panorama_from_Summit.jpeg"],
                         [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/1/1c/NGC_6302_Hubble_2009.full.jpg"],
                         [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/3/3c/Merging_galaxies_NGC_4676_(captured_by_the_Hubble_Space_Telescope).jpg"],
                         [NSURL URLWithString:@"http://spaceflight.nasa.gov/gallery/images/shuttle/sts-125/hires/s125e012033.jpg"],
                         [NSURL URLWithString:@"http://mayang.com/textures/Plants/images/Flowers/large_flower_6080110.JPG"],
                         [NSURL URLWithString:@"http://setiathome.berkeley.edu/img/head_20.png"],
                         [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/c/ca/Star-forming_region_S106_(captured_by_the_Hubble_Space_Telescope).jpg"],
                         [NSURL URLWithString:@"http://hdwallpaper.freehdw.com/0003/nature-landscapes_widewallpaper_large-flowers-close-up_21096.jpg"],
                         [NSURL URLWithString:@"http://media.cleveland.com/neobirding_impact/photo/11460704-large.jpg"],
                         [NSURL URLWithString:@"http://www.factzoo.com/sites/all/img/birds/great-hornbill-flying.jpg"]];

    }
    return _largeImageURLs;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
