//
//  UILabel+AutoAdjustSize.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "UILabel+AutoAdjustSize.h"
#include "MacroDef.h"

@implementation UILabel (AutoAdjustSize)

- (CGSize)_fitSizeWithSize:(CGSize)size
{
    return MULTILINE_TEXTSIZE(self.text, self.font, size, self.lineBreakMode);
}

- (CGSize)fitSizeFixedWidth
{
    return [self _fitSizeWithSize:CGSizeMake(CGRectGetWidth(self.bounds), MAXFLOAT)];
}

- (CGSize)fitSizeFixedHeight
{
    return [self _fitSizeWithSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(self.bounds))];
}

- (void)setTextWithFitSizeFixedWidth:(NSString *)text
{
    self.text = text;
    
    CGRect tmpFrame = self.frame;
    tmpFrame.size.height = ceilf([self fitSizeFixedWidth].height);
    self.frame = tmpFrame;
}

- (void)setTextWithFitSizeFixedHeight:(NSString *)text
{
    self.text = text;
    
    CGRect tmpFrame = self.frame;
    tmpFrame.size.width = ceilf([self fitSizeFixedHeight].width);
    self.frame = tmpFrame;
}



@end
