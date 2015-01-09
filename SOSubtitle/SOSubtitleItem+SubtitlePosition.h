//
//  SOSubtitleItem+SubtitlePosition.h
//  SOSubtitle
//
//  Created by so30 on 09/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import "SOSubtitleItem.h"

@interface SOSubtitleItem (SubtitlePosition)

+ (CGRect)convertSubtitlePositionToCGRect:(SOSubtitlePosition)position;

+ (SOSubtitlePosition)convertCGRectToSubtitlePosition:(CGRect)rect;

@end
