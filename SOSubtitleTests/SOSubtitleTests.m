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

#import "SOSubtitles.h"

@interface SOSubtitleTests : XCTestCase

@property (strong, nonatomic) SOSubtitle *subtitle;

@end

@implementation SOSubtitleTests

- (void)setUp {
    [super setUp];
    
    self.subtitle = [[SOSubtitle alloc] initWithFile:OHPathForFileInBundle(@"subtitle.srt",nil)];
}

- (void)tearDown {
    self.subtitle = nil;
    
    [super tearDown];
}

- (void)testThatSubtitleItemsInitializes {
    XCTAssertNotNil(self.subtitle, @"Should initialize subtitle.");
    XCTAssertNotNil(self.subtitle.subtitleItems, @"Should initialize subtitle.");
    XCTAssertEqual([self.subtitle.subtitleItems count], 720, @"Should initialize subitleItems.");
}

@end
