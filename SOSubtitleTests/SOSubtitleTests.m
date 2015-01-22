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

#import "SOAsyncTestHelper.h"
#import "SOSubtitles.h"

@interface SOSubtitleTests : XCTestCase

@end

@implementation SOSubtitleTests

- (void)testThatSubtitleInitializesFromURL {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString * path = OHPathForFileInBundle(@"subtitle.srt", nil);
        return [OHHTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:200
                                                   headers:nil];
    }];
    
    SOSubtitle * __block subtitle = nil;
    NSError * __block error = nil;
    
    NSURL *url = [NSURL URLWithString:@"http://test.com/subtitle.srt"];
    [[[SOSubtitle alloc] subtitleFromURL:url] continueWithBlock:^id(BFTask *task) {
        subtitle = task.result;
        
        return nil;
    }];
    
    SOAssertEventually(subtitle, @"Should complete with response.");
    XCTAssertNotNil(subtitle.subtitleItems, @"Should initialize subtitle.");
    XCTAssertEqual([subtitle.subtitleItems count], 100, @"Should initialize subitleItems.");
    XCTAssertNil(error, @"Should complete without error.");
}

@end
