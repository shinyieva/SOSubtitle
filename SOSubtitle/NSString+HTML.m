//
//  NSString+HTML.m
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "NSString+HTML.h"

#import <CoreText/CoreText.h>

@implementation NSString (HTML)

- (NSAttributedString *)HTMLString {
    
    static const CGFloat kDefaultFontSize = 20.0;
    static NSString * kDefaultFontFamily = @"HelveticaNeue";
    
    NSString *string = [self copy];
    
    if ([string length] > 0) {
        if ([[string substringToIndex:1] isEqualToString:@"\n"]) {
            string = [string substringFromIndex:1];
        }
    }
    
    NSMutableAttributedString *HTMLString;
    NSRange HTMLStringRange;
    if ([string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch].location != NSNotFound) {
        NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
        HTMLString =  [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUTF16StringEncoding]
                                                              options:options
                                                   documentAttributes:nil
                                                                error:NULL];
        HTMLStringRange = NSMakeRange(0, [HTMLString.string length]);
        
        //Edit font size
        [HTMLString beginEditing];
        [HTMLString enumerateAttribute:NSFontAttributeName
                               inRange:HTMLStringRange
                               options:0
                            usingBlock:^(id value, NSRange range, BOOL *stop) {
                                if (value) {
                                    UIFont *oldFont = (UIFont *)value;
                                    NSString *fontName = kDefaultFontFamily;
                                    if ([oldFont.fontName rangeOfString:@"Italic"].location != NSNotFound) {
                                        fontName = [fontName stringByAppendingString:@"-Italic"];
                                    } else if ([oldFont.fontName rangeOfString:@"Bold"].location != NSNotFound) {
                                        fontName = [fontName stringByAppendingString:@"-Bold"];
                                    }
                                    UIFont *newFont = [UIFont fontWithName:fontName size:kDefaultFontSize];
                                    //Workaround for iOS 7.0.3 && 7.0.4 font bug
                                    if (newFont == nil && ([UIFontDescriptor class] != nil)) {
                                        newFont = (__bridge_transfer UIFont*)CTFontCreateWithName((__bridge CFStringRef)fontName, kDefaultFontSize, NULL);
                                    }
                                    [HTMLString removeAttribute:NSFontAttributeName range:range];
                                    [HTMLString addAttribute:NSFontAttributeName value:newFont range:range];
                                }
                            }];
        [HTMLString endEditing];
    }
    
    if (!HTMLString) {
        UIFont *defaultFont = [UIFont fontWithName:kDefaultFontFamily size:kDefaultFontSize];
        //Workaround for iOS 7.0.3 && 7.0.4 font bug
        if (defaultFont == nil && ([UIFontDescriptor class] != nil)) {
            defaultFont = (__bridge_transfer UIFont*)CTFontCreateWithName((__bridge CFStringRef)kDefaultFontFamily, kDefaultFontSize, NULL);
        }
        
        HTMLString = [[NSMutableAttributedString alloc] initWithString:string
                                                            attributes:@{
                                                                         NSFontAttributeName: defaultFont
                                                                         }];
        HTMLStringRange = NSMakeRange(0, [HTMLString.string length]);
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    //Add color and paragraph style
    [HTMLString addAttributes:@{
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: [UIColor whiteColor]
                                }
                        range:HTMLStringRange];
    
    
    
    return HTMLString;
}

@end
