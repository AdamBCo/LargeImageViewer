//
//  GalleryViewController.m
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "GalleryViewController.h"

@interface GalleryViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) NSArray *imageViewControllers;

@property (nonatomic, strong) UIBarButtonItem *closeButton;


@end

@implementation GalleryViewController {
    int _index;
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers andIndex:(int)index
{
    self = [super init];
    if (self) {
        _imageViewControllers = viewControllers;
        _index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:self.closeButton];
    [self.view addSubview:self.pageController.view];
    
    NSArray *viewControllers = [NSArray arrayWithObject:[self.imageViewControllers objectAtIndex:_index]];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.pageController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - PageViewController DataSource Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = [self.imageViewControllers indexOfObject: viewController];
    if(index == 0) {
        return nil;
    } else {
        return index == 0 ? [self.imageViewControllers lastObject] : self.imageViewControllers[index - 1];
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self.imageViewControllers indexOfObject: viewController];
    if(index == self.imageViewControllers.count - 1) {
        return nil;
    } else {
        return self.imageViewControllers[(index + 1) % self.imageViewControllers.count];
    }
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return self.imageViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return _index;
}


-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSUInteger index = [self.imageViewControllers indexOfObject: [pageViewController.viewControllers lastObject]];

}

#pragma mark - Actions

-(void)onCloseButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Properties

-(UIPageViewController *)pageController {
    if (!_pageController) {
        _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
        [_pageController setDelegate:self];
        [_pageController setDataSource:self];
        [_pageController.view setBackgroundColor:[UIColor blackColor]];

    }
    return _pageController;
}

-(UIBarButtonItem *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(onCloseButtonPressed:)];
    }
    return _closeButton;
}

@end
