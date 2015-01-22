//
//  SOSubtitleItemTests.m
//  SOSubtitle
//
//  Created by so30 on 15/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "SOSubtitles.h"
#import <XCTest/XCTest.h>

@interface SOSubtitleItemTests : XCTestCase

@property (strong, nonatomic) SOSubtitleItem *subtitleItem;

@end

@implementation SOSubtitleItemTests

- (void)setUp {
    [super setUp];

    NSString *subText = @"";
    SOSubtitleTime subStartTime = { 0, 5, 25, 0 };
    SOSubtitleTime subEndTime = { 0, 8, 35, 0 };
    
    self.subtitleItem = [[SOSubtitleItem alloc] initWithText:subText
                                                       start:subStartTime
                                                         end:subEndTime];
    
}

- (void)tearDown {
    self.subtitleItem = nil;
    
    [super tearDown];
}

- (void)testsThatSubtitleItemInitializes {
    XCTAssertEqualObjects(self.subtitleItem.text, @"", @"Shoul initialize subtitle text.");
}

@end
