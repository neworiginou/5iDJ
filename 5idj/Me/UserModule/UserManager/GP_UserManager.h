//
//  GP_UserManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-26.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_User.h"

//----------------------------------------------------------

//登录成功
UIKIT_EXTERN NSString *const UserLoginSuccessNotification;

//登录失败
UIKIT_EXTERN NSString *const UserLoginFailNotification;

//注册成功
UIKIT_EXTERN NSString *const UserRegisterSuccessNotification;

//注册失败
UIKIT_EXTERN NSString *const UserRegisterFailNotification;

//用户操作失败的原因的key
UIKIT_EXTERN NSString *const UserHandleFailErrorUserInfoKey;

//当前用户改变通知
UIKIT_EXTERN NSString *const CurrentUserChangeNotification;

//----------------------------------------------------------

@interface GP_UserManager : NSObject


//用户登录，登录结果通过通知返回
+ (void)userLoginWithUserName:(NSString *)userName password:(NSString *)password;

//尝试自动登录
+ (void)tryAutoLogin;

//是否正在自动登录
+ (BOOL)isAutoLogining;

//取消自动登录
+ (void)cancleAutoLogin;

//用户注册
+ (void)userRegisterWithUserName:(NSString *)userName password:(NSString *)password;

//退出当前用户
+ (void)exitCurrentUser;

//获取当前用户
+ (GP_User *)currentUser;

+ (void)clearLoginRecorder;

//最近登录用户的信息
+ (NSDictionary *)recentUserInfo;

@end
