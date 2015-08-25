//
//  GP_UserinfoView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_UserInfoView.h"

//----------------------------------------------------------

@interface GP_UserInfoView()

//当前用户改变通知
- (void)_currentUserChangeNotification:(NSNotification *)notification;

//更新视图
- (void)_updateView;

@end

//----------------------------------------------------------


@implementation GP_UserInfoView
{
    //用户头像
    UIImageView * _userAvatorImageView;
    
    //用户名
    UILabel     * _userNameLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //用户头像
        _userAvatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.f, (AspectScaleLenght(95.f) - 55.f) * 0.6f, 55.f, 55.f)];
        _userAvatorImageView.clipsToBounds = YES;
        _userAvatorImageView.layer.cornerRadius = 27.5f;
        _userAvatorImageView.layer.borderWidth = 2.f;
        _userAvatorImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:_userAvatorImageView];
        
         [_userAvatorImageView setImage:ImageWithName(@"user_avator_default")];
        
        //名字
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.f, CGRectGetMinY(_userAvatorImageView.frame) + 20.f, 200.f, 22.f)];
        _userNameLabel.font = [UIFont systemFontOfSize:18.f];
        _userNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:_userNameLabel];
    
        
        //更新视图
        [self _updateView];
        
        
        //监听用户改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentUserChangeNotification:) name:CurrentUserChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [_userAvatorImageView cancleLoadURLImage:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_updateView
{
    GP_User * currentUser = [GP_UserManager currentUser];
    
    [_userAvatorImageView cancleLoadURLImage:YES];
    
    if (currentUser) {
        
        _userNameLabel.text = currentUser.userName;
        
//        //设置图像
//        [_userAvatorImageView setImageWithURL:currentUser.avatarURL
//                             placeholderImage:ImageWithName(@"user_avator_default")
//                             progressViewMode:ImageLoadProgressViewModeNone
//                               loadFailPolicy:ImageLoadFailPolicyAllPolicy];
        
        
    }else{
        _userNameLabel.text = @"立即登录";
//        [_userAvatorImageView setImage:ImageWithName(@"user_avator_default")];
    }
}

- (void)_currentUserChangeNotification:(NSNotification *)notification
{
    [self _updateView];
}

@end
