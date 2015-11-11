//
//  LargeImageViewerTests.m
//  LargeImageViewerTests
//
//  Created by Adam Cooper on 11/10/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ImageManager.h"

@interface LargeImageViewerTests : XCTestCase <ImageManagerDelegate>

@end

@implementation LargeImageViewerTests {
    XCTestExpectation *_downloadLargeImageSuccessExpectation;
    XCTestExpectation *_downloadLargeImageFailedExpectation;

}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSURL *)largeImageURL {
    return [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/8/81/Carn_Eige_Scotland_-_Full_Panorama_from_Summit.jpeg"];
}


- (void)testLargeImageDownload {
    
    _downloadLargeImageSuccessExpectation = [self expectationWithDescription:@"Large Image Donwloading From Web"];
    
    [[ImageManager sharedInstance] setDelegate:self];
    [[ImageManager sharedInstance] downloadImageWithURL:[self largeImageURL]];
    
    [self waitForExpectationsWithTimeout:60
                                 handler:^(NSError *error) {
                                     // handler is called on _either_ success or failure
                                     if (error != nil) {
                                         XCTFail(@"timeout error: %@", error);
                                     }
                                 }];
}

- (void)testLargeImageDownloadWithNilURL {
    
    _downloadLargeImageFailedExpectation = [self expectationWithDescription:@"Large Image Donwloading With Nil URL"];
    
    [[ImageManager sharedInstance] setDelegate:self];
    [[ImageManager sharedInstance] downloadImageWithURL:nil];
    
    [self waitForExpectationsWithTimeout:60
                                 handler:^(NSError *error) {
                                     // handler is called on _either_ success or failure
                                     if (error != nil) {
                                         XCTFail(@"timeout error: %@", error);
                                     }
                                 }];
}

-(void)imageManagerDidUpdate:(ImageManager *)manager {
    NSLog(@"SUCCESS");
    [_downloadLargeImageSuccessExpectation fulfill];
    XCTAssert(YES, @"Large Image Downloaded From Web");
}

-(void)imageManagerDidFail:(ImageManager *)manager withError:(NSError *)error {
    NSLog(@"ERROR");
    [_downloadLargeImageFailedExpectation fulfill];
    XCTAssertNotNil(error, @"Large Image Downloaded Failed With Error");

}

-(void)imageManager:(ImageManager *)manager didUpdateWithProgress:(float)progress {
    NSLog(@"PROGRESS");
}

@end
