//
//  UIImage+Tint.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;

- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;


@end
