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

#define FONT_SIZE 24
    
    NSString *string = [self copy];
    NSMutableAttributedString *HTMLString;
    
    if ([string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch].location != NSNotFound) {
        NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
        HTMLString =  [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUTF16StringEncoding]
                                                              options:options
                                                   documentAttributes:nil
                                                                error:NULL];
    }
    
    if (!HTMLString) {
        HTMLString = [[NSMutableAttributedString alloc] initWithString:string];
    }
    
    NSRange HTMLStringRange = NSMakeRange(0, [HTMLString.string length]);
    
    //Edit font size
    [HTMLString beginEditing];
    [HTMLString enumerateAttribute:NSFontAttributeName
                           inRange:HTMLStringRange
                           options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            if (value) {
                                UIFont *oldFont = (UIFont *)value;
                                UIFont *newFont = [oldFont fontWithSize:FONT_SIZE];
                                [HTMLString removeAttribute:NSFontAttributeName range:range];
                                [HTMLString addAttribute:NSFontAttributeName value:newFont range:range];
                            }
                        }];
    [HTMLString endEditing];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = FONT_SIZE/2;
    
    //Add color and paragraph style
    [HTMLString addAttributes:@{
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                }
                        range:HTMLStringRange];
    
    return HTMLString;
}

@end
