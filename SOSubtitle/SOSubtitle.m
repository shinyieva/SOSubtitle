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

#import <Bolts/Bolts.h>
#import <AFNetworking/AFNetworking.h>

NSString *const SOSubtitlesErrorDomain = @"som.shinyieva.subtitles.error";

const int SOSubtitlesErrorCouldNotParseSRT = 1009;
const int SOSubtitlesErrorEmptySubtitle = 1010;

typedef enum {
    SOSubtitleScanPositionArrayIndex,
    SOSubtitleScanPositionTimes,
    SOSubtitleScanPositionText
} SOSubtitleScanPosition;

@interface SOSubtitle ()

@property (strong, nonatomic, readwrite) NSMutableArray *subtitleItems;

@property (strong, nonatomic) NSDictionary *subtitleItemsDictionary;

@end

@implementation SOSubtitle

- (NSDictionary *)subtitleItemsDictionary {
    if (!_subtitleItemsDictionary) {
        NSMutableDictionary *aux = [[NSMutableDictionary alloc] init];
        for (SOSubtitleItem *item in self.subtitleItems) {
            [aux setObject:item forKey:@(floor(CMTimeGetSeconds(item.startTime)))];
        }
        _subtitleItemsDictionary = [aux copy];
    }
    return _subtitleItemsDictionary;
}

- (BFTask *)subtitleFromURL:(NSURL *)url {
    NSError *error;
    
    return [[self fetchSubtitleFromURL:url
                                 error:error] continueWithBlock:^id (BFTask *task) {
        if (task.result) {
            NSString *string = [[NSString alloc] initWithData:task.result
                                                     encoding:NSUTF8StringEncoding];
            
            if (!string) {
                string = [[NSString alloc] initWithData:task.result encoding:NSASCIIStringEncoding];
            }
            
            if (string) {
                return [self subtitleWithString:string error:error];
            } else {
                NSError *error = [NSError errorWithDomain:SOSubtitlesErrorDomain
                                                     code:SOSubtitlesErrorCouldNotParseSRT
                                                 userInfo:nil];
                return [BFTask taskWithError:error];
            }
        } else {
            return [BFTask taskWithError:task.error];
        }
    }];
}

- (BFTask *)fetchSubtitleFromURL:(NSURL *)fileURL
                           error:(NSError *)error {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *operation = [manager GET:fileURL.absoluteString
                                          parameters:nil
                                             success:nil
                                             failure:nil];
    
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [completionSource setResult:responseObject];
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [completionSource setError:error];
                                     }];
    
    return completionSource.task;
}

- (BFTask *)subtitleWithString:(NSString *)str
                         error:(NSError *)error {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    SOSubtitle *subtitle = [[SOSubtitle alloc] init];
    
    subtitle.subtitleItems = [NSMutableArray arrayWithCapacity:100];
    BOOL success = [subtitle parseFromString:str error:error];
    
    if ([subtitle.subtitleItems count] == 0) {
        error = [NSError errorWithDomain:SOSubtitlesErrorDomain
                                    code:SOSubtitlesErrorEmptySubtitle
                                userInfo:nil];
    }
    
    if (!success || [subtitle.subtitleItems count] == 0) {
        [taskCompletionSource setError:error];
    } else {
        [taskCompletionSource setResult:subtitle];
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
- (BOOL)parseFromString:(NSString *)str error:(NSError *)error {
#if 1
    return [self subtitleItemsFromMalformedString:str error:error];
#else /* if 1 */
    return [self subtitleItemsFromRegularString:str error:error];
#endif /* if 1 */
}

- (BOOL)subtitleItemsFromMalformedString:(NSString *)str error:(NSError *)error{
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
                error = [NSError errorWithDomain:SOSubtitlesErrorDomain
                                            code:SOSubtitlesErrorCouldNotParseSRT
                                        userInfo:errorDetail];
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
        while ([scanner scanUpToString:linebreakString intoString:&subTextLine] &&
               (SCAN_LINEBREAK() || [scanner isAtEnd]))
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
                                                                   error:&error];
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
        
        [_subtitleItems addObject:item];
        
        while (SCAN_LINEBREAK());  // Skip trailing empty lines.
    }
    return YES;
    
#   undef SCAN_LINEBREAK
#   undef SCAN_STRING
}

- (BOOL)subtitleItemsFromRegularString:(NSString *)str error:(NSError **)error {
    // Assumes that str is a correctly-formatted SRT file.
    NSCharacterSet *alphanumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];
    
    __block SOSubtitleItem *cur = [SOSubtitleItem new];
    __block SOSubtitleScanPosition scanPosition = SOSubtitleScanPositionArrayIndex;
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        // Blank lines are delimiters.
        NSRange r = [line rangeOfCharacterFromSet:alphanumericCharacterSet];
        
        if (r.location != NSNotFound) {
            BOOL actionAlreadyTaken = NO;
            
            if (scanPosition == SOSubtitleScanPositionArrayIndex) {
                scanPosition = SOSubtitleScanPositionTimes;     // skip past the array index number.
                actionAlreadyTaken = YES;
            }
            
            if ((scanPosition == SOSubtitleScanPositionTimes) && (!actionAlreadyTaken)) {
                NSArray *times = [line componentsSeparatedByString:@" --> "];
                NSString *beginning = [times objectAtIndex:0];
                NSString *ending = [times objectAtIndex:1];
                
                cur.startTime = [NSString parseTimecodeStringIntoCMTime:beginning];
                cur.endTime = [NSString parseTimecodeStringIntoCMTime:ending];
                
                scanPosition = SOSubtitleScanPositionText;
                actionAlreadyTaken = YES;
            }
            
            if ((scanPosition == SOSubtitleScanPositionText) && (!actionAlreadyTaken)) {
                NSString *prevText = cur.text;
                
                if (prevText == nil) {
                    cur.text = line;
                } else {
                    cur.text = [cur.text
                                stringByAppendingFormat:@"\n%@", line];
                }
                
                scanPosition = SOSubtitleScanPositionText;
            }
        } else {
#if SUBVIEWER_SUPPORT
            cur.text = convertSubViewerLineBreaks(cur.text);
#endif
            
            [_subtitleItems addObject:cur];
            
            cur = [SOSubtitleItem new];
            scanPosition = SOSubtitleScanPositionArrayIndex;
        }
        
        switch (scanPosition) {
            case SOSubtitleScanPositionArrayIndex:
                break;
                
            case SOSubtitleScanPositionText:
                [_subtitleItems addObject:cur];
                break;
                
            default:
                break;
        }
    }];
    
    return YES;
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

- (SOSubtitleItem *)subtitleItemAtTime:(NSTimeInterval)time {
    return self.subtitleItemsDictionary[@(floor(time))];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_subtitleItems forKey:@"subtitleItems"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.subtitleItems = [decoder decodeObjectForKey:@"subtitleItems"];
    }
    return self;
}

@end
