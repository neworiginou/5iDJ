//
//  UILabel+AutoAdjustSize.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (AutoAdjustSize)

- (CGSize)fitSizeFixedWidth;

- (CGSize)fitSizeFixedHeight;

- (void)setTextWithFitSizeFixedWidth:(NSString *)text;

- (void)setTextWithFitSizeFixedHeight:(NSString *)text;

@end
