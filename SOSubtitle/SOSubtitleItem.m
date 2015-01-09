//
//  SOSubtitleItem.m
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "SOSubtitleItem.h"

#import "NSString+CMTime.h"
#import "NSString+HTML.h"
#import "SOSubtitleItem+SubtitleTime.h"
#import "SOSubtitleItem+SubtitlePosition.h"

@implementation SOSubtitleItem

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        _uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    
    return self;
}

- (instancetype)initWithText:(NSString *)text
                       start:(SOSubtitleTime)startTime
                         end:(SOSubtitleTime)endTime {
    self = [self init];
    
    if (self != nil) {
        _text = text;
        _attributedText = [text HTMLString];
        _startTime = [SOSubtitleItem convertSubtitleTimeToCMTime:startTime];
        _endTime = [SOSubtitleItem convertSubtitleTimeToCMTime:endTime];
        _frame = CGRectZero;
    }
    
    return self;
}

- (NSString *)startTimeString {
    return [self convertCMTimeToString:self.startTime];
}

- (NSString *)endTimeString {
    return [self convertCMTimeToString:self.endTime];
}

- (NSString *)convertCMTimeToString:(CMTime)theTime {
    // Need a string of format "hh:mm:ss". (No milliseconds.)
    NSTimeInterval seconds = (NSTimeInterval)CMTimeGetSeconds(theTime);
    NSDate *date1 = [NSDate new];
    NSDate *date2 = [NSDate dateWithTimeInterval:seconds sinceDate:date1];
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *converted = [[NSCalendar currentCalendar] components:unitFlags fromDate:date1 toDate:date2 options:0];
    
    NSString *str = [NSString stringWithFormat:@"%02d:%02d:%02d",
                     (int)[converted hour],
                     (int)[converted minute],
                     (int)[converted second]];
    
    return str;
}

- (NSString *)startTimecodeString {
    return srtTimecodeStringForCMTime(self.startTime);
}

- (NSString *)endTimecodeString {
    return srtTimecodeStringForCMTime(self.endTime);
}

- (NSString *)positionString {
    if (CGRectIsEmpty(self.frame)) {
        return @"";
    } else {
        SOSubtitlePosition position = [SOSubtitleItem convertCGRectToSubtitlePosition:self.frame];
        NSString *str = [NSString stringWithFormat:@"  X1:%d X2:%d Y1:%d Y2:%d",
                         position.x1,
                         position.x2,
                         position.y1,
                         position.y2];
        return str;
    }
}

- (NSString *)description {
    NSString *text = self.text;
    NSString *position = self.positionString;
    
    return [NSString stringWithFormat:@"%@ ---> %@%@: %@", self.startTimecodeString, self.endTimecodeString, position, text];
}

- (BOOL)isEqual:(id)obj {
    if (obj == nil) {
        return NO;
    }
    
    if (![obj isKindOfClass:[SOSubtitleItem class]]) {
        return NO;
    }
    
    SOSubtitleItem *other = (SOSubtitleItem *)obj;
    
    id otherText = other.text;
    
    return ((CMTimeCompare(other.startTime, self.startTime) == 0) &&
            (CMTimeCompare(other.endTime, self.endTime) == 0) &&
            ((otherText == self.text) || [otherText isEqualToString:self.text]));
}

- (BOOL)isEqualToSOSubtitleItem:(SOSubtitleItem *)other {
    if (other == nil) {
        return NO;
    }
    
    id otherText = other.text;
    
    return ((CMTimeCompare(other.startTime, self.startTime) == 0) &&
            (CMTimeCompare(other.endTime, self.endTime) == 0) &&
            ((otherText == self.text) || [otherText isEqualToString:self.text]));
}

- (NSInteger)startTimeInSeconds {
    return (NSInteger)CMTimeGetSeconds(self.startTime);
}

- (NSInteger)endTimeInSeconds {
    return (NSInteger)CMTimeGetSeconds(self.endTime);
}

- (double)startTimeDouble {
    return (double)CMTimeGetSeconds(self.startTime);
}

- (double)endTimeDouble {
    return (double)CMTimeGetSeconds(self.endTime);
}

- (void)setStartTimeFromString:(NSString *)timecodeString {
    self.startTime = [NSString parseTimecodeStringIntoCMTime:timecodeString];
}

- (void)setEndTimeFromString:(NSString *)timecodeString {
    self.endTime = [NSString parseTimecodeStringIntoCMTime:timecodeString];
}

- (BOOL)containsString:(NSString *)str {
    NSRange searchResult = [self.text rangeOfString:str options:NSCaseInsensitiveSearch];
    
    if (searchResult.location == NSNotFound) {
        if ([str length] < 9) {
            searchResult = [[self startTimeString] rangeOfString:str options:NSCaseInsensitiveSearch];
            
            if (searchResult.location == NSNotFound) {
                searchResult = [[self endTimeString] rangeOfString:str options:NSCaseInsensitiveSearch];
                
                if (searchResult.location == NSNotFound) {
                    return NO;
                } else {
                    return YES;
                }
            } else {
                return YES;
            }
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}

@end
