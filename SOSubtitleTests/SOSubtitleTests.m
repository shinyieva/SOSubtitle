//
//  SOSubtitleTests.m
//  SOSubtitle
//
//  Created by so30 on 07/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <Bolts/Bolts.h>

#import "SOSubtitles.h"

@interface SOSubtitleTests : XCTestCase

@property (strong, nonatomic) SOSubtitle *subtitle;

@end

@implementation SOSubtitleTests

- (void)setUp {
    [super setUp];
    
    
    
}

- (void)tearDown {
    self.subtitle = nil;
    
    [super tearDown];
}

- (void)testThatSubtitleItemsInitializes {
    
    XCTestExpectation *subtitleParseExpectation = [self expectationWithDescription:@"Subtitle parse."];
    
    NSURL *url = [NSURL URLWithString:@"http://media.gvp.telefonica.com/storagearea0/GVP_SUBTITLES/00/00/01/12372_9F8FF124460A775B.srt"];
    [[[SOSubtitle alloc] subtitleFromURL:url] continueWithBlock:^id(BFTask *task) {
        self.subtitle = task.result;

        XCTAssertNotNil(self.subtitle, @"Should initialize subtitle.");
        XCTAssertNotNil(self.subtitle.subtitleItems, @"Should initialize subtitle.");
        XCTAssertEqual([self.subtitle.subtitleItems count], 100, @"Should initialize subitleItems.");

        [subtitleParseExpectation fulfill];
        
        return nil;
    }];
//    
//    
//    [[[SOSubtitle alloc] subtitleFromFile:OHPathForFileInBundle(@"subtitle.srt",nil)] continueWithBlock:^id(BFTask *task) {
//        self.subtitle = task.result;
//        
//        
//        XCTAssertNotNil(self.subtitle, @"Should initialize subtitle.");
//        XCTAssertNotNil(self.subtitle.subtitleItems, @"Should initialize subtitle.");
//        XCTAssertEqual([self.subtitle.subtitleItems count], 100, @"Should initialize subitleItems.");
//        
//        [subtitleParseExpectation fulfill];
//        return nil;
//    }];
    
    [self waitForExpectationsWithTimeout:50.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
