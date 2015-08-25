//
//  MyAuthCodeView.h
//  5idj
//
//  Created by Xuzhanya on 14-10-12.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@class MyAuthCodeView;

@protocol MyAuthCodeViewDelegate <NSObject>

@optional

- (BOOL)authCodeViewWillChangeAuthCode:(MyAuthCodeView *)authCodeView;

//改变了验证码
- (void)authCodeViewDidChangeAuthCode:(MyAuthCodeView *)authCodeView;

@end

//----------------------------------------------------------

@interface MyAuthCodeView : UIView

//default is 4
@property(nonatomic) NSUInteger authCodeLength;

@property(nonatomic,strong,readonly) NSString * authCode;

@property(nonatomic,weak) id<MyAuthCodeViewDelegate> delegate;

//改变验证码
- (void)changeAuthCode;

@end
