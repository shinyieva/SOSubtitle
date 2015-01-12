//
//  NSString+CMTime.m
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "NSString+CMTime.h"

#import "SOSubtitleItem+SubtitlePosition.h"
#import "SOSubtitleItem+SubtitleTime.h"

@implementation NSString (CMTime)

NSString * srtTimecodeStringForCMTime(CMTime time) {
    const CMTimeScale millisecondTimescale = 1000;
    
    CMTimeScale timescale = time.timescale;
    
    if (timescale != millisecondTimescale) {
        time = CMTimeConvertScale(time, millisecondTimescale, kCMTimeRoundingMethod_RoundTowardZero);
    }
    
    CMTimeValue total_milliseconds = time.value;
    CMTimeValue milliseconds = total_milliseconds % millisecondTimescale;
    CMTimeValue total_seconds = (total_milliseconds - milliseconds) / millisecondTimescale;
    CMTimeValue seconds = total_seconds % 60;
    CMTimeValue total_minutes = (total_seconds - seconds) / 60;
    CMTimeValue minutes = total_minutes % 60;
    CMTimeValue hours = (total_minutes - minutes) / 60;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d,%03d",
            (int)hours,
            (int)minutes,
            (int)seconds,
            (int)milliseconds];
}

+ (void)parseTimecodeString:(NSString *)timecodeString
                intoSeconds:(int *)totalNumSeconds
               milliseconds:(int *)milliseconds {
    NSArray *timeComponents = [timecodeString componentsSeparatedByString:@":"];
    
    int hours = [(NSString *)[timeComponents objectAtIndex:0] intValue];
    int minutes = [(NSString *)[timeComponents objectAtIndex:1] intValue];
    
    NSArray *secondsComponents = [(NSString *)[timeComponents objectAtIndex:2] componentsSeparatedByString : @","];
    
#if SUBVIEWER_SUPPORT
    
    if (secondsComponents.count < 2) secondsComponents = [(NSString *)[timeComponents objectAtIndex:2] componentsSeparatedByString : @"."];
    
#endif
    int seconds = [(NSString *)[secondsComponents objectAtIndex:0] intValue];
    
    if (secondsComponents.count < 2) {
        *milliseconds = -1;
    } else {
        *milliseconds = [(NSString *)[secondsComponents objectAtIndex:1] intValue];
    }
    
    *totalNumSeconds = [SOSubtitleItem totalSecondsForHours:hours minutes:minutes seconds:seconds];
}

+ (CMTime)parseTimecodeStringIntoCMTime:(NSString *)timecodeString {
    int milliseconds;
    int totalNumSeconds;
    
    [self parseTimecodeString:timecodeString
                  intoSeconds:&totalNumSeconds
                 milliseconds:&milliseconds];
    
    CMTime time = [SOSubtitleItem convertSecondsMilliseconds:totalNumSeconds toCMTime:milliseconds];
    
    return time;
}

@end
