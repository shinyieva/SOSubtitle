//
//  SOSubtitleItem+SubtitleTime.m
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "SOSubtitleItem+SubtitleTime.h"

@implementation SOSubtitleItem (SubtitleTime)

+ (CMTime)convertSecondsMilliseconds:(int)seconds toCMTime:(int)milliseconds {
    CMTime secondsTime = CMTimeMake(seconds, 1);
    CMTime millisecondsTime;
    
    if (milliseconds == -1) {
        return secondsTime;
    } else {
        millisecondsTime = CMTimeMake(milliseconds, 1000);
        CMTime time = CMTimeAdd(secondsTime, millisecondsTime);
        return time;
    }
}

+ (int)totalSecondsForHours:(int)hours minutes:(int)minutes seconds:(int)seconds {
    return (hours * 3600) + (minutes * 60) + seconds;
}

+ (CMTime)convertSubtitleTimeToCMTime:(SOSubtitleTime)subtitleTime {
    int totalSeconds = [SOSubtitleItem totalSecondsForHours:subtitleTime.hours
                                                    minutes:subtitleTime.minutes
                                                    seconds:subtitleTime.seconds];
    CMTime time = [SOSubtitleItem convertSecondsMilliseconds:totalSeconds
                                                    toCMTime:subtitleTime.milliseconds];
    
    return time;
}

@end
