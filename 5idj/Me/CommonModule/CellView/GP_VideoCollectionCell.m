//
//  GP_VideoCollectionCell.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-5.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoCollectionCell.h"

//----------------------------------------------------------

@implementation GP_VideoCollectionCell
{
    UILabel * _hitsLabel;
    
    CAShapeLayer * _hitsBackgroundLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        CGRect imageViewFrame = [self.imageAndTitleContentView imageViewFrame];
        
        //缩放比例
        CGFloat scale = [GP_ImageAndTitleContentView scaleFactor];
        
        UIView * hitsView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(imageViewFrame), CGRectGetMinY(imageViewFrame) + scale * 10.f, scale * 40.f, scale * 15.f)];
        [self.imageAndTitleContentView addSubview:hitsView];
        
        //背景
        _hitsBackgroundLayer = [[CAShapeLayer alloc] init];
        _hitsBackgroundLayer.actions     = @{@"fillColor" : [NSNull null]};
        _hitsBackgroundLayer.strokeColor = [UIColor blackColor].CGColor;
        _hitsBackgroundLayer.fillColor   = [self.tintColor colorWithAlphaComponent:0.7f].CGColor;
        _hitsBackgroundLayer.lineWidth   = 0.2f;
        
        
        CGRect  hitsViewBounds = hitsView.bounds;
        CGFloat hitsViewHeight = CGRectGetHeight(hitsViewBounds);
        
        //绘制圆角背景
        CGFloat riadius = hitsViewHeight *.2f;
        _hitsBackgroundLayer.path =
            [[UIBezierPath bezierPathWithRoundedRect:hitsView.bounds
                                   byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                         cornerRadii:CGSizeMake(riadius, riadius)] CGPath];
        
        [hitsView.layer addSublayer:_hitsBackgroundLayer];
        
        
        //播放标记视图
        UIImageView * playHitsIndictor = [[UIImageView alloc] initWithImage:ImageWithName(@"play_hits")];
        CGFloat centerHeight = hitsViewHeight * 0.5f;
        playHitsIndictor.center = CGPointMake(centerHeight, centerHeight);
        [hitsView addSubview:playHitsIndictor];
        
        //标签
        _hitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitsViewHeight, 0.f, CGRectGetWidth(hitsViewBounds) - hitsViewHeight, hitsViewHeight)];
        _hitsLabel.font = [UIFont systemFontOfSize:8.f * scale];
        [hitsView addSubview:_hitsLabel];
    }
    
    return self;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    _hitsBackgroundLayer.fillColor = [self.tintColor colorWithAlphaComponent:0.7f].CGColor;
}

- (void)updateWithVideo:(GP_Video *)video
{
    [self updateWithBasicTitleAndImage:video];
}

- (void)updateWithBasicTitleAndImage:(GP_BasicTitleAndImage *)basicTitleAndImage
{
    assert([basicTitleAndImage isKindOfClass:[GP_Video class]]);
    
    [super updateWithBasicTitleAndImage:basicTitleAndImage];
    
    _hitsLabel.text = [(GP_Video *)basicTitleAndImage hitsString];
}

@end
