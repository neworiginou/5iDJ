//
//  UIImage+Pixel.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-8-15.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "UIImage+Pixel.h"

@implementation UIImage (Pixel)

- (void *)getPixels
{
    CGImageRef imageRef = self.CGImage;
    
    if (imageRef) {
        
        size_t width  = CGImageGetWidth(imageRef);
        size_t height = CGImageGetWidth(imageRef);
        size_t bitsPerComponent = 8;
        size_t bytesPerRow = 4 * width;
        
        UInt32 * data = alloca(width * height * sizeof(UInt32));
        
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGContextRef    contextRef    = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst);
        
        CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
        
        CGColorSpaceRelease(colorSpaceRef);
        CGContextRelease(contextRef);
        
        return data;
        
    }
    
    return NULL;
}

+ (void)releasePixels:(void *)pixels
{
    if (pixels != NULL) {
        free(pixels);
    }
}

@end
