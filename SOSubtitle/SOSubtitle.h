//
//  SOSubtitle.h
//  SOSubtitle
//
//  Created by so30 on 07/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

#import <CoreMedia/CMTime.h>

#pragma mark - SOMSubtileItem Interface

@interface SOSubtitleItem : NSObject

@property CMTime startTime;
@property CMTime endTime;
@property(copy) NSString *text;
@property(nonatomic, copy) NSAttributedString *attributedText;
@property(nonatomic, readonly, strong) NSDictionary *attributeOptions;

@property(readonly, getter = startTimeString) NSString *startTimeString;
@property(readonly, getter = endTimeString) NSString *endTimeString;
@property(readonly) NSString *uniqueID;

@property (nonatomic) CGRect frame;

- (instancetype)initWithText:(NSString *)text
                   startTime:(CMTime)startTime
                     endTime:(CMTime)endTime;

- (void)parseTagsWithOptions:(NSDictionary *)options;

// Without milliseconds!
-(NSString *)startTimeString;
-(NSString *)endTimeString;

// SRT timecode strings
-(NSString *)startTimecodeString;
-(NSString *)endTimecodeString;

-(NSString *)_convertCMTimeToString:(CMTime)theTime;

-(NSString *)positionString;

-(NSString *)description;

-(NSInteger)startTimeInSeconds;
-(NSInteger)endTimeInSeconds;

// These methods are for development only due to the issues involving floating-point arithmetic.
-(double)startTimeDouble;
-(double)endTimeDouble;

-(void)setStartTimeFromString:(NSString *)timecodeString;
-(void)setEndTimeFromString:(NSString *)timecodeString;

-(BOOL)containsString:(NSString *)str;

@end

#pragma mark - SOMSubtiles Interface

@interface SOSubtitle : NSObject

@property(nonatomic, strong) NSMutableArray *subtitleItems;
@property(readonly) NSUInteger totalCharacterCountOfText;

-(instancetype)initWithFile:(NSString *)filePath;
-(instancetype)initWithURL:(NSURL *)fileURL encoding:(NSStringEncoding)encoding error:(NSError **)error;
-(instancetype)initWithData:(NSData *)data;
-(instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
-(instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding error:(NSError **)error;
-(instancetype)initWithString:(NSString *)str;
-(instancetype)initWithString:(NSString *)str
                        error:(NSError **)error;
-(instancetype)initWithSubtitleItems:(NSMutableArray *)subtitleItems;

-(BOOL)_populateFromString:(NSString *)str;

- (void)parseTags;
- (void)parseTagsWithOptions:(NSDictionary *)options;

-(NSString *)srtString;
-(NSString *)srtStringWithLineBreaksInSubtitlesAllowed:(BOOL)lineBreaksAllowed;

-(NSString *)description;

-(NSUInteger)indexOfSubtitleItemWithStartTime:(CMTime)desiredTime DEPRECATED_ATTRIBUTE; // The name of this method doesn’t match what it does.
-(NSUInteger)indexOfSubtitleItemForPointInTime:(CMTime)desiredTime;

- (SOSubtitleItem *)subtitleItemAtIndex:(NSUInteger)index; // In contrast to NSArray’s -objectAtIndex:, this returns nil if the index it out of bounds.
- (SOSubtitleItem *)subtitleItemForPointInTime:(CMTime)desiredTime index:(NSUInteger *)index; // The index is optional: you can pass NULL.
- (SOSubtitleItem *)nextSubtitleItemForPointInTime:(CMTime)desiredTime index:(NSUInteger *)index; // The index is optional: you can pass NULL.

-(NSUInteger)indexOfSubtitleItemWithCharacterIndex:(NSUInteger)idx;

-(NSUInteger)totalCharacterCountOfText;

@end
