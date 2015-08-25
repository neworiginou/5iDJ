//
//  UIImage+Pixel.h
//  5idj_ios
//
//  Created by Xuzhanya on 14-8-15.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(int, UIImagePixelFormat) {
//    UIImagePixelFormatR8G8B8,
//    UIImagePixelFormatR8G8B8A8,
//    UIImagePixelFormatR5G6B5
//};

/**
 * 获取图像像素相关操作
 */
@interface UIImage (Pixel)

/**
 * 获取图像像素
 * @return 返回像素数组，ARGB格式，不使用后需要调用releasePixels:进行释放，否则会造成内存泄露
 */
- (void *)getPixels; //:(UIImagePixelFormat)pixelFormat;

/**
 * 释放像素数组
 */
+ (void)releasePixels:(void *)pixels;

@end
