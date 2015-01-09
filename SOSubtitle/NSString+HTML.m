//
//  NSString+HTML.m
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "NSString+HTML.h"

#import <MMMarkdown/MMMarkdown.h>

@implementation NSString (HTML)

- (NSAttributedString *)HTMLString {
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSString *s = [self copy];
    
    if ([s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch].location != NSNotFound) {
        return [[NSAttributedString alloc] initWithData:[s dataUsingEncoding:NSUTF8StringEncoding]
                                                options:options
                                     documentAttributes:nil
                                                  error:NULL];
    }
    return nil;
}

@end
