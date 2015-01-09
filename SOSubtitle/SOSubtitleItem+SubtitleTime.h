//
//  SOSubtitleItem+SubtitleTime.h
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "SOSubtitleItem.h"

@interface SOSubtitleItem (SubtitleTime)

+ (CMTime)convertSecondsMilliseconds:(int) seconds toCMTime:(int)milliseconds;

+ (int)totalSecondsForHours:(int)hours minutes:(int)minutes seconds:(int)seconds;

+ (CMTime)convertSubtitleTimeToCMTime:(SOSubtitleTime)subtitleTime;

@end
