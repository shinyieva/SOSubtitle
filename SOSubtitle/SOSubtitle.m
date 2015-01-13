//
//  SOSubtitle.m
//  SOSubtitle
//
//  Created by so30 on 07/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "SOSubtitle.h"
#import "SOSubtitleItem.h"

#import "NSString+CMTime.h"
#import "SOSubtitleItem+SubtitlePosition.h"

#import <Bolts/Bolts.h>

NSString *const SOSubtitlesErrorDomain = @"som.shinyieva.subtitles.error";

const int kCouldNotParseSRT = 1009;

typedef enum {
    SubRipScanPositionArrayIndex,
    SubRipScanPositionTimes,
    SubRipScanPositionText
} SubRipScanPosition;

@implementation SOSubtitle

- (BFTask *)subtitleFromFile:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSStringEncoding encoding;
        NSError *error = nil;
        NSString *string = [[NSString alloc] initWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];

        if ([error code] == NSFileReadUnknownStringEncodingError) { // couldn't determine file encoding
            error = nil;
            string = [[NSString alloc] initWithContentsOfFile:filePath
                                                     encoding:NSISOLatin1StringEncoding
                                                        error:&error];
        }

        if (string == nil) {
            NSLog(@"%@", [error localizedDescription]);
            return [BFTask taskWithError:error];
        } else {
            return [self subtitleWithString:string error:NULL];
        }
    } else {
        return nil;
    }
}

- (BFTask *)subtitleFromURL:(NSURL *)fileURL
                   encoding:(NSStringEncoding)encoding
                      error:(NSError *)error {
    NSString *str = [NSString stringWithContentsOfURL:fileURL
                                             encoding:encoding
                                                error:&error];

    if (str == nil) return nil;

    return [self subtitleWithString:str error:error];
}

- (BFTask *)subtitleWithString:(NSString *)str
                         error:(NSError *)error {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    SOSubtitle *subtitle = [[SOSubtitle alloc] init];

    if (subtitle) {
        subtitle.subtitleItems = [NSMutableArray arrayWithCapacity:100];
        BOOL success = [subtitle _populateFromString:str
                                               error:&error];

        if (!success) {
            [taskCompletionSource setError:error];
        } else {
            [taskCompletionSource setResult:subtitle];
        }
    }

    return taskCompletionSource.task;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
NS_INLINE NSString * convertSubViewerLineBreaks(NSString *currentText) {
    NSUInteger currentTextLength = currentText.length;

    if (currentTextLength == 0) return currentText;

    NSRange currentTextRange = NSMakeRange(0, currentTextLength);
    NSString *subViewerLineBreak = @"[br]";
    NSRange subViewerLineBreakRange = [currentText rangeOfString:subViewerLineBreak
                                                         options:NSLiteralSearch
                                                           range:currentTextRange];

    if (subViewerLineBreakRange.location != NSNotFound) {
        NSRange subViewerLineBreakSearchRange = NSMakeRange(subViewerLineBreakRange.location,
                                                            (currentTextRange.length - subViewerLineBreakRange.location));

        currentText = [currentText stringByReplacingOccurrencesOfString:subViewerLineBreak
                                                             withString:@"\n"
                                                                options:NSLiteralSearch
                                                                  range:subViewerLineBreakSearchRange];
    }

    return currentText;
}

#pragma clang diagnostic pop

NS_INLINE BOOL scanLinebreak(NSScanner *scanner, NSString *linebreakString, int linenr) {
    BOOL success = ([scanner scanString:linebreakString intoString:NULL] && (++linenr >= 0));

    return success;
}

NS_INLINE BOOL scanString(NSScanner *scanner, NSString *str) {
    BOOL success = [scanner scanString:str intoString:NULL];

    return success;
}

// Returns YES if successful, NO if not.
- (BOOL)_populateFromString:(NSString *)str
                      error:(NSError **)error {
#if 1
    // Should handle mal-formed SRT files. May fill error even if parsing was successful!
    // Basis for implementation donated by Peter Ljunglöf (SubTTS)
#   define SCAN_LINEBREAK() scanLinebreak(scanner, linebreakString, lineNr)
#   define SCAN_STRING(str) scanString(scanner, (str))

    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:[NSCharacterSet whitespaceCharacterSet]];

    // Auto-detect linebreakString
    NSString *linebreakString = nil;
    {
        NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
        BOOL ok = ([scanner scanUpToCharactersFromSet:newlineCharacterSet intoString:NULL] &&
                   [scanner scanCharactersFromSet:newlineCharacterSet intoString:&linebreakString]);

        if (ok == NO) {
            NSLog(@"Parse error in SRT string: no line break found!");
            linebreakString = @"\n";
        }

        [scanner setScanLocation:0];
    }

    NSString *subTextLineSeparator = @"\n";
    int subtitleNr = 0;
    int lineNr = 1;

    NSRegularExpression *tagRe;

    while (SCAN_LINEBREAK());  // Skip leading empty lines.

    while (![scanner isAtEnd]) {
        NSString *subText;
        NSMutableArray *subTextLines;
        NSString *subTextLine;
        SOSubtitleTime start = { -1, -1, -1, -1 };
        SOSubtitleTime end = { -1, -1, -1, -1 };
        BOOL hasPosition = NO;
        SOSubtitlePosition position;
        int subtitleNr_;

        subtitleNr++;

        BOOL ok = ([scanner scanInt:&subtitleNr_] && SCAN_LINEBREAK() &&
                   // Start time
                   [scanner scanInt:&start.hours] && SCAN_STRING(@":") &&
                   [scanner scanInt:&start.minutes] && SCAN_STRING(@":") &&
                   [scanner scanInt:&start.seconds] &&
                   ((
#if SUBVIEWER_SUPPORT
                        (SCAN_STRING(@",") || SCAN_STRING(@".")) &&
#else
                        SCAN_STRING(@",") &&
#endif
                        [scanner scanInt:&start.milliseconds]
                        ) || YES) // We either find milliseconds or we ignore them.
                   &&

                   // Start/End separator
#if SUBVIEWER_SUPPORT
                   (SCAN_STRING(@"-->") || SCAN_STRING(@",")) &&
#else
                   SCAN_STRING(@"-->") && // We are skipping whitepace!
#endif

                   // End time
                   [scanner scanInt:&end.hours] && SCAN_STRING(@":") &&
                   [scanner scanInt:&end.minutes] && SCAN_STRING(@":") &&
                   [scanner scanInt:&end.seconds] &&
                   ((
#if SUBVIEWER_SUPPORT
                        (SCAN_STRING(@",") || SCAN_STRING(@".")) &&
#else
                        SCAN_STRING(@",") &&
#endif
                        [scanner scanInt:&end.milliseconds]
                        ) || YES) // We either find milliseconds or we ignore them.
                   &&

                   // Optional position
                   (
                       SCAN_LINEBREAK() ||
                       ( // If there is no line break, this could be position information.
                           [scanner scanString:@"X1:" intoString:NULL] &&
                           [scanner scanInt:&position.x1] &&
                           [scanner scanString:@"X2:" intoString:NULL] &&
                           [scanner scanInt:&position.x2] &&
                           [scanner scanString:@"Y1:" intoString:NULL] &&
                           [scanner scanInt:&position.y1] &&
                           [scanner scanString:@"Y2:" intoString:NULL] &&
                           [scanner scanInt:&position.y2] &&
                           SCAN_LINEBREAK() &&
                           (hasPosition = YES))
                   )
                   &&

                   // Subtitle text
                   (
                       [scanner scanUpToString:linebreakString intoString:&subTextLine] || // We either find subtitle text…
                       (subTextLine = @"") // … or we assume empty text.
                   )
                   &&

                   // End of event
                   (SCAN_LINEBREAK() || [scanner isAtEnd])
                   );

        if (!ok) {
            if (error != NULL) {
                const NSUInteger contextLength = 20;
                NSUInteger strLength = str.length;
                NSUInteger errorLocation = [scanner scanLocation];

                NSRange beforeRange, afterRange;

                beforeRange.length = MIN(contextLength, errorLocation);
                beforeRange.location = errorLocation - beforeRange.length;
                NSString *beforeError = [str substringWithRange:beforeRange];

                afterRange.length = MIN(contextLength, (strLength - errorLocation));
                afterRange.location = errorLocation;
                NSString *afterError = [str substringWithRange:afterRange];

                NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"The SRT subtitles could not be parsed: error in subtitle #%d (line %d):\n%@<HERE>%@", @"Cannot parse SRT file"),
                                              subtitleNr, lineNr, beforeError, afterError];
                NSDictionary *errorDetail = [NSDictionary dictionaryWithObjectsAndKeys:
                                             errorDescription, NSLocalizedDescriptionKey,
                                             nil];
                *error = [NSError errorWithDomain:SOSubtitlesErrorDomain code:kCouldNotParseSRT userInfo:errorDetail];
            }

            return NO;
        }

        if (subtitleNr != subtitleNr_) {
            NSLog(@"Subtitle # mismatch (line %d): got %d, expected %d. ", lineNr, subtitleNr_, subtitleNr);
            subtitleNr = subtitleNr_;
        }

#if SUBVIEWER_SUPPORT
        subTextLine = convertSubViewerLineBreaks(subTextLine);
#endif

        subTextLines = [NSMutableArray arrayWithObject:subTextLine];

        // Accumulate multi-line text if any.
        while ([scanner scanUpToString:linebreakString intoString:&subTextLine] && (SCAN_LINEBREAK() || [scanner isAtEnd]))
            [subTextLines addObject:subTextLine];

        if (subTextLines.count == 1) {
            subText = [subTextLines objectAtIndex:0];
            subText = [subText stringByReplacingOccurrencesOfString:@"|"
                                                         withString:@"\n"
                                                            options:NSLiteralSearch
                                                              range:NSMakeRange(0, subText.length)];
        } else {
            subText = [subTextLines componentsJoinedByString:subTextLineSeparator];
        }

        // Curly braces enclosed tag processing
        {
            NSString *const tagStart = @"{";

            NSRange searchRange = NSMakeRange(0, subText.length);

            NSRange tagStartRange = [subText rangeOfString:tagStart options:NSLiteralSearch range:searchRange];

            if (tagStartRange.location != NSNotFound) {
                searchRange = NSMakeRange(tagStartRange.location, subText.length - tagStartRange.location);
                NSMutableString *subTextMutable = [subText mutableCopy];

                // Remove all
                if (tagRe == nil) {
                    NSString *const tagPattern = @"\\{(\\\\|Y:)[^\\{]+\\}";

                    tagRe = [[NSRegularExpression alloc] initWithPattern:tagPattern
                                                                 options:0
                                                                   error:error];

                    if (tagRe == nil) NSLog(@"%@", *error);
                }

                [tagRe replaceMatchesInString:subTextMutable
                                      options:0
                                        range:searchRange
                                 withTemplate:@""];

                subText = [subTextMutable copy];
            }
        }

        SOSubtitleItem *item = [[SOSubtitleItem alloc] initWithText:subText
                                                              start:start
                                                                end:end];

        if (hasPosition) {
            item.frame = [SOSubtitleItem convertSubtitlePositionToCGRect:position];
        }

        [_subtitleItems addObject:item];

        while (SCAN_LINEBREAK());  // Skip trailing empty lines.
    }

#if 0
    NSLog(@"Read %d = %lu subtitles", subtitleNr, [_subtitleItems count]);
    SOSubtitleItem *sub = [_subtitleItems objectAtIndex:0];
    NSLog(@"FIRST: '%@'", sub);
    sub = [_subtitleItems lastObject];
    NSLog(@"LAST: '%@'", sub);
#endif

    return YES;

#   undef SCAN_LINEBREAK
#   undef SCAN_STRING
#else /* if 1 */
      // Assumes that str is a correctly-formatted SRT file.
    NSCharacterSet *alphanumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];

    __block SOSubtitleItem *cur = [SOSubtitleItem new];
    __block SubRipScanPosition scanPosition = SubRipScanPositionArrayIndex;
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
             // Blank lines are delimiters.
             NSRange r = [line rangeOfCharacterFromSet:alphanumericCharacterSet];

             if (r.location != NSNotFound) {
             BOOL actionAlreadyTaken = NO;

             if (scanPosition == SubRipScanPositionArrayIndex) {
                scanPosition = SubRipScanPositionTimes; // skip past the array index number.
                actionAlreadyTaken = YES;
             }

             if ((scanPosition == SubRipScanPositionTimes) && (!actionAlreadyTaken)) {
                NSArray *times = [line componentsSeparatedByString:@" --> "];
                NSString *beginning = [times objectAtIndex:0];
                NSString *ending = [times objectAtIndex:1];

                cur.startTime = [SubRip parseTimecodeStringIntoCMTime:beginning];
                cur.endTime = [SubRip parseTimecodeStringIntoCMTime:ending];

                scanPosition = SubRipScanPositionText;
                actionAlreadyTaken = YES;
             }

             if ((scanPosition == SubRipScanPositionText) && (!actionAlreadyTaken)) {
                NSString *prevText = cur.text;

                if (prevText == nil) {
                    cur.text = line;
                } else {
                    cur.text = [cur.text
                                stringByAppendingFormat:@"\n%@", line];
                }

                scanPosition = SubRipScanPositionText;
             }
             } else {
             #if SUBVIEWER_SUPPORT
             cur.text = convertSubViewerLineBreaks(cur.text);
             #endif

             [_subtitleItems addObject:cur];
             JX_RELEASE(cur);
             cur = [SOSubtitleItem new];
             scanPosition = SubRipScanPositionArrayIndex;
             }
         }];

    switch (scanPosition) {
        case SubRipScanPositionArrayIndex:
            JX_RELEASE(cur);
            break;

        case SubRipScanPositionText:
            [_subtitleItems addObject:cur];
            JX_RELEASE(cur);
            break;

        default:
            break;
    }

    return YES;

#endif /* if 1 */
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SRT file: %@", self.subtitleItems];
}

- (SOSubtitleItem *)subtitleItemForPointInTime:(CMTime)desiredTime {
    // Finds the first SOSubtitleItem whose startTime <= desiredTime < endTime.
    // Requires that we ensure the subtitleItems are ordered, because we are using binary search.
    NSUInteger *index = NULL;
    NSUInteger subtitleItemsCount = _subtitleItems.count;

    // Custom binary search.
    NSUInteger low = 0;
    NSUInteger high = subtitleItemsCount - 1;

    while (low <= high) {
        NSUInteger mid = (low + high) >> 1;
        SOSubtitleItem *thisSub = [_subtitleItems objectAtIndex:mid];
        CMTime thisStartTime = thisSub.startTime;

        if (CMTIME_COMPARE_INLINE(thisStartTime, <=, desiredTime)) {
            CMTime thisEndTime = thisSub.endTime;

            if (CMTIME_COMPARE_INLINE(desiredTime, <, thisEndTime)) {
                // desiredTime in range.
                if (index != NULL) *index = mid;

                return thisSub;
            } else {
                // Continue search in upper *half*.
                low = mid + 1;
            }
        } else { /*if (CMTIME_COMPARE_INLINE(subStartTime, >, desiredTime))*/
            if (mid == 0) break;  // Nothing found.

            // Continue search in lower *half*.
            high = mid - 1;
        }
    }

    if (index != NULL) *index = NSNotFound;

    return nil;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_subtitleItems forKey:@"subtitleItems"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    self.subtitleItems = [decoder decodeObjectForKey:@"subtitleItems"];
    return self;
}

@end
