//
//  SOSubtitleItem.h
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import <CoreMedia/CMTime.h>
#import <CoreGraphics/CoreGraphics.h>

typedef struct {
    int hours;
    int minutes;
    int seconds;
    int milliseconds;
} SOSubtitleTime;

@interface SOSubtitleItem : NSObject

@property CMTime startTime;
@property CMTime endTime;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSAttributedString *attributedText;

@property(readonly) NSString *uniqueID;

@property (nonatomic) CGRect frame;

- (instancetype)initWithText:(NSString *)text
                       start:(SOSubtitleTime)startTime
                         end:(SOSubtitleTime)endTime;

@end
