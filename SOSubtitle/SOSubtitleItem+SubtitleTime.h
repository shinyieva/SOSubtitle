//
//  SOSubtitleItem+SubtitleTime.h
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "SOSubtitleItem.h"

@interface SOSubtitleItem (SubtitleTime)

+ (CMTime)convertSecondsMilliseconds:(NSUInteger)seconds toCMTime:(NSUInteger)milliseconds;

+ (NSUInteger)totalSecondsForHours:(NSUInteger)hours
                           minutes:(NSUInteger)minutes
                           seconds:(NSUInteger)seconds;

+ (CMTime)convertSubtitleTimeToCMTime:(SOSubtitleTime)subtitleTime;

@end
