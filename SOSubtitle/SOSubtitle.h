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

@property (nonatomic, strong) NSMutableArray *subtitleItems;
@property (readonly) NSUInteger totalCharacterCountOfText;

- (BFTask *)subtitleFromFile:(NSString *)filePath;
- (BFTask *)subtitleFromURL:(NSURL *)fileURL encoding:(NSStringEncoding)encoding error:(NSError *)error;
- (BFTask *)subtitleWithString:(NSString *)str error:(NSError *)error;

- (NSString *)srtString;
- (NSString *)srtStringWithLineBreaksInSubtitlesAllowed:(BOOL)lineBreaksAllowed;

- (NSString *)description;

- (NSUInteger)indexOfSubtitleItemWithStartTime:(CMTime)desiredTime DEPRECATED_ATTRIBUTE; // The name of this method doesn’t match what it does.
- (NSUInteger)indexOfSubtitleItemForPointInTime:(CMTime)desiredTime;

- (SOSubtitleItem *)subtitleItemAtIndex:(NSUInteger)index; // In contrast to NSArray’s -objectAtIndex:, this returns nil if the index it out of bounds.
- (SOSubtitleItem *)subtitleItemForPointInTime:(CMTime)desiredTime index:(NSUInteger *)index; // The index is optional: you can pass NULL.
- (SOSubtitleItem *)nextSubtitleItemForPointInTime:(CMTime)desiredTime index:(NSUInteger *)index; // The index is optional: you can pass NULL.

- (NSUInteger)indexOfSubtitleItemWithCharacterIndex:(NSUInteger)idx;

- (NSUInteger)      totalCharacterCountOfText;

@end
