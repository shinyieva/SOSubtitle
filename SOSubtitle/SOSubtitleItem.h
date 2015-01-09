//
//  SOSubtitleItem.h
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import <CoreMedia/CMTime.h>

typedef struct {
    int hours;
    int minutes;
    int seconds;
    int milliseconds;
} SOSubtitleTime;

typedef struct {
    int x1;
    int x2;
    int y1;
    int y2;
} SOSubtitlePosition;

@interface SOSubtitleItem : NSObject

@property CMTime startTime;
@property CMTime endTime;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSAttributedString *attributedText;

@property(readonly, getter = startTimeString) NSString *startTimeString;
@property(readonly, getter = endTimeString) NSString *endTimeString;
@property(readonly) NSString *uniqueID;

@property (nonatomic) CGRect frame;

- (instancetype)initWithText:(NSString *)text
                       start:(SOSubtitleTime)startTime
                         end:(SOSubtitleTime)endTime;

// Without milliseconds!
-(NSString *)startTimeString;
-(NSString *)endTimeString;

// SRT timecode strings
-(NSString *)startTimecodeString;
-(NSString *)endTimecodeString;

-(NSString *)convertCMTimeToString:(CMTime)theTime;

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
