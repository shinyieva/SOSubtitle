//
//  SOSubtitle.h
//  SOSubtitle
//
//  Created by so30 on 07/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import <CoreMedia/CMTime.h>

@class SOSubtitleItem;
@class BFTask;

@interface SOSubtitle : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *subtitleItems;

/**
 Fetch subtitle form given URL.
 
 @param url Subtitle source URL.
 
 @return A `BFTask`  that will return an `SOSubtitle` object when completed successfully.
 */
- (BFTask *)subtitleFromURL:(NSURL *)url;

/**
 Finds the first SOSubtitleItem whose startTime <= desiredTime < endTime.
 
 @param desiredTime Playback time for display subtitle in `CMTime` format.
 */
- (SOSubtitleItem *)subtitleItemForPointInTime:(CMTime)desiredTime;

/**
 Finds the first SOSubtitleItem whose startTime <= desiredTime < endTime.
 
 @param time Playback time to display subtitle in `NSTimeInterval` format
 */
- (SOSubtitleItem *)subtitleItemAtTime:(NSTimeInterval)time;

@end
