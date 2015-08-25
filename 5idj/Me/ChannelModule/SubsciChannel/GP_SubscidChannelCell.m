//
//  GP_SubscidChannelCell.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-12.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SubscidChannelCell.h"
#import "GP_ImageAndTitleContentView.h"
#import "GP_Channel.h"

//----------------------------------------------------------

@implementation GP_SubscidChannelCell
{
    CALayer * _selectedLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        CGRect imageViewFrame = [self.imageAndTitleContentView imageViewFrame];
        
        _selectedLayer = [[CALayer alloc] init];
        _selectedLayer.anchorPoint = CGPointMake(1.f, 1.f);
        _selectedLayer.bounds = CGRectMake(0.f, 0.f, 30.f, 30.f);
        _selectedLayer.position = CGPointMake(CGRectGetMaxX(imageViewFrame), CGRectGetMaxY(imageViewFrame));
        _selectedLayer.contents = (id) ImageWithName(@"channel_unselected").CGImage;
        [self.imageAndTitleContentView.layer addSublayer:_selectedLayer];
        
    }
    return self;
}


- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    if (self.selected) {
        _selectedLayer.contents = (id)[GP_SubscidChannelCell _selectedImage].CGImage;
    }
}

- (void)setSelected:(BOOL)selected
{
    if (self.selected != selected) {
        
        [super setSelected:selected];
        
        _selectedLayer.contents = (id)(selected ? [GP_SubscidChannelCell _selectedImage] : ImageWithName(@"channel_unselected")).CGImage;
    }
}

+ (UIImage *)_selectedImage
{
    static UIImage * s_selectedImage = nil;
    
    if (!s_selectedImage) {
        
        s_selectedImage = [self _createSelectedImage];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:CurrentThemeColorChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * notification){
            s_selectedImage = [self _createSelectedImage];
        }];
    }
    
    return s_selectedImage;
}


+ (UIImage *)_createSelectedImage
{
    
//    return [ImageWithName(@"channel_selected") imageWithTintColor:[[GP_ThemeManager shareThemeManager] currentThemeColor]];
    
    UIImage * tmpImage = ImageWithName(@"channel_selected");
    
    CGSize imageSize = tmpImage.size;
    CGRect imageBounds = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.f);
    
    //获取当前上下文
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //填充
    [[[GP_ThemeManager shareThemeManager] currentThemeColor] setFill];
    UIRectFill(imageBounds);
    
    //绘制
    [tmpImage drawInRect:imageBounds blendMode:kCGBlendModeDestinationIn alpha:1.f];
    
    //获取变色后
    tmpImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //设置白色背景
    [[UIColor whiteColor] setFill];
    
    //填充路径
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, imageSize.width, 0.f);
    CGContextAddLineToPoint(currentContext,imageSize.width, imageSize.height);
    CGContextAddLineToPoint(currentContext,0.f, imageSize.height);
    CGContextFillPath(currentContext);
    
    //绘制图像
    [tmpImage drawInRect:imageBounds];
    
    //获取图片
    tmpImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmpImage;
}







@end
