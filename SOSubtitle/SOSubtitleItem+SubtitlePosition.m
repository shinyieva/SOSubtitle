//
//  SOSubtitleItem+SubtitlePosition.m
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "SOSubtitleItem+SubtitlePosition.h"

@implementation SOSubtitleItem (SubtitlePosition)

+ (CGRect)convertSubtitlePositionToCGRect:(SOSubtitlePosition)position {
    CGRect rect = CGRectMake(position.x1,
                             position.y1,
                             (position.x2 - position.x1),
                             (position.y2 - position.y1));
    
    return rect;
}

+ (SOSubtitlePosition)convertCGRectToSubtitlePosition:(CGRect)rect {
    SOSubtitlePosition position;
    
    position.x1 = rect.origin.x;
    position.x2 = rect.origin.x + rect.size.width;
    position.y1 = rect.origin.y;
    position.y2 = rect.origin.y + rect.size.height;
    
    return position;
}

@end
