//
//  GP_LoadingIndicateView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-26.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_LoadingIndicateView.h"

//----------------------------------------------------------

@implementation GP_LoadingIndicateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.titleLabelColor  = defaultTitleTextColor;
        self.detailLabelColor = defaultBodyTextColor;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabelColor  = defaultTitleTextColor;
    self.detailLabelColor = defaultBodyTextColor;
}


- (void)showNoUserWiTitle:(NSString *)title
{
    [self showNoUserWiTitle:title detailText:@"点击页面立即登录"];
}

- (void)showNoUserWiTitle:(NSString *)title detailText:(NSString *)detailText
{
    [self hiddenView];
    
    self.image = ImageWithName(@"error_weep");
    self.style = MyIndicateViewStyleImageView;
    self.titleLabelText = title;
    self.detailLabelText = detailText;
    
    self.supportTapGesture = YES;
    self.contextTag = NoUserContextTag;
    
    self.hidden = NO;
    
}

- (void)showNothingWiTitle:(NSString *)title
{
    [self showNothingWiTitle:title detailText:@"点击页面重试"];
}

- (void)showNothingWiTitle:(NSString *)title detailText:(NSString *)detailText
{
    [self hiddenView];
    
    self.image = ImageWithName(@"error_weep");
    self.style = MyIndicateViewStyleImageView;
    self.titleLabelText = title;
    self.detailLabelText = detailText;
    
    self.supportTapGesture = YES;
    self.contextTag = NothingContextTag;
    
    self.hidden = NO;

}

@end
