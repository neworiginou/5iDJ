//
//  GP_HomeTableHeadView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-14.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_HomeModuleSupplementaryView.h"

//----------------------------------------------------------

//@interface GP_HomeTableHeaderView ()
//
///*
// *更多按钮的响应回调函数
// */
//- (void)didMoreBtn:(id)sender;
//
//@end

//----------------------------------------------------------
//
//@implementation GP_HomeTableHeaderView
//
////- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
////{
////    self = [super initWithReuseIdentifier:reuseIdentifier];
////    
////    if (self) {
////        
////        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
////        moreButton.showsTouchWhenHighlighted = YES;
////        moreButton.frame = CGRectMake(286.f, 0.f, 34.f, 40.f);
////        [moreButton setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
////        [moreButton addTarget:self action:@selector(didMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
////        [self.contentView addSubview:moreButton];
////        
////        
////        CGRect tmpLabelFrame = self.titleLabel.frame;
////        tmpLabelFrame.size.width = 276.f;
////        self.titleLabel.frame = tmpLabelFrame;
////    }
////    
////    return self;
////}
//

@implementation GP_HomeModuleSupplementaryView
{
    GP_BasicHeaderContentView * _tableHeaderView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _tableHeaderView = [[GP_BasicHeaderContentView alloc] init];
        [self addSubview:_tableHeaderView];
    }
    
    return self;
}

- (void)setVideosModule:(GP_HomeVideosModule *)videosModule
{
    //    _videosModule = videosModule;
    _tableHeaderView.titleLabel.text = videosModule.title;
}

@end
