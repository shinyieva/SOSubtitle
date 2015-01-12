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

- (NSString *)description;

- (SOSubtitleItem *)subtitleItemForPointInTime:(CMTime)desiredTime;

@end
