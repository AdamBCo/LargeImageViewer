//
//  GalleryViewController.m
//  LargeImageViewer
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "GalleryViewController.h"
#import "ImageManager.h"

@interface GalleryViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) NSArray *imageViewControllers;

@property (nonatomic, strong) UIBarButtonItem *closeBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *deleteBarButtonItem;


@end

@implementation GalleryViewController {
    int _index;
    NSTimer *_animationTimer;
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
    
    [self.navigationItem setLeftBarButtonItem:self.closeBarButtonItem];
    [self.navigationItem setRightBarButtonItem:self.deleteBarButtonItem];
    
    [self.view addSubview:self.pageController.view];
    
    NSArray *viewControllers = [NSArray arrayWithObject:[self.imageViewControllers objectAtIndex:_index]];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.pageController didMoveToParentViewController:self];
    
    
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                       target: self
                                                     selector: @selector(animatePageSwipe)
                                                     userInfo: nil
                                                      repeats: YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_animationTimer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Animations

-(void)animatePageSwipe {
    
    //Check to see if we have a single image loaded.
    if (self.imageViewControllers.count <= 1) {
        [_animationTimer invalidate];
        return;
    }
    
    //Check to see if we are at the end of the pageController
    if (_index + 1 >= self.imageViewControllers.count) {
        _index = 0;
        NSArray *viewControllers = [NSArray arrayWithObject:[self.imageViewControllers objectAtIndex:_index]];
        [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        return;
    }
    
    _index++;

    UIViewController *viewController = [self.imageViewControllers objectAtIndex:_index];
    
    UIPageViewControllerNavigationDirection animateDirection = UIPageViewControllerNavigationDirectionForward;
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.pageController.view setUserInteractionEnabled:NO];
    [self.pageController setViewControllers:@[ viewController ]
                                  direction:animateDirection
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     [weakSelf.pageController.view setUserInteractionEnabled:YES];
                                 }];
    
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
    
    NSString *titleString = [NSString stringWithFormat:@"%d / %lu", _index + 1, self.imageViewControllers.count];
    [self setTitle:titleString];
    
    return _index;
}


-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    _index = @([self.imageViewControllers indexOfObject: [pageViewController.viewControllers lastObject]]).intValue;
}

#pragma mark - Actions

-(void)onCloseButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onDeleteButtonPressed:(UIBarButtonItem *)sender {
    
    [[ImageManager sharedInstance].imagesArray removeObjectAtIndex:_index];
    [[ImageManager sharedInstance].imageURLsArray removeObjectAtIndex:_index];
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

-(UIBarButtonItem *)closeBarButtonItem {
    if (!_closeBarButtonItem) {
        _closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(onCloseButtonPressed:)];
    }
    return _closeBarButtonItem;
}

-(UIBarButtonItem *)deleteBarButtonItem {
    if (!_deleteBarButtonItem) {
        _deleteBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onDeleteButtonPressed:)];
    }
    return _deleteBarButtonItem;
}

@end
