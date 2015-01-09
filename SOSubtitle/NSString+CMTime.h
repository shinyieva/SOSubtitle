//
//  NSString+CMTime.h
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>

extern NSString * srtTimecodeStringForCMTime(CMTime time);

@interface NSString (CMTime)

+ (void)parseTimecodeString:(NSString *)timecodeString
                intoSeconds:(int *)totalNumSeconds
               milliseconds:(int *)milliseconds;

+ (CMTime)parseTimecodeStringIntoCMTime:(NSString *)timecodeString;

@end
