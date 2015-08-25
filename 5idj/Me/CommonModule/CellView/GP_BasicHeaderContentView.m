//
//  GP_BasicTableHeaderView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-26.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicHeaderContentView.h"

//----------------------------------------------------------


@implementation GP_BasicHeaderContentView
{
    CAShapeLayer * _lineLayer;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, 40.f)];
    
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 10.f, 0.f)];
        _titleLabel.textColor = defaultTitleTextColor;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
    
        
        //添加线
        _lineLayer = createLineLayer(CGPointMake(0.f, 10.f), CGPointMake(0.f, 30.f), 5.f, self.tintColor);
        [self.layer addSublayer:_lineLayer];

    }
    
    return self;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    _lineLayer.strokeColor = self.tintColor.CGColor;
}



@end
