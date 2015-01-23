//
//  NSString+HTML.m
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "NSString+HTML.h"

@implementation NSString (HTML)

- (NSAttributedString *)HTMLString {
    
    static const NSUInteger kDefaultFontSize = 20;
    static NSString * kDefaultFontFamily = @"HelveticaNeue";
    
    NSString *string = [self copy];
    
    if ([[string substringToIndex:1] isEqualToString:@"\n"]) {
        string = [string substringFromIndex:1];
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
                                    [HTMLString removeAttribute:NSFontAttributeName range:range];
                                    [HTMLString addAttribute:NSFontAttributeName value:newFont range:range];
                                }
                            }];
        [HTMLString endEditing];
    }
    
    
    
    if (!HTMLString) {
        HTMLString = [[NSMutableAttributedString alloc] initWithString:string
                                                            attributes:@{
                                                                         NSFontAttributeName: [UIFont fontWithName:kDefaultFontFamily
                                                                                                              size:kDefaultFontSize]
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
