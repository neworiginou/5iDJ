//
//  GP_UserManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-26.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_UserManager.h"
#import "GP_ServiceRequest.h"

//----------------------------------------------------------

#define RecentUserInfoKey @"RecentUserInfoKey"

//----------------------------------------------------------

//登录成功
NSString *const UserLoginSuccessNotification = @"UserLoginSuccessNotification";

//登录失败
NSString *const UserLoginFailNotification = @"UserLoginFailNotification";

//注册成功
NSString *const UserRegisterSuccessNotification = @"UserRegisterSuccessNotification";

//注册失败
NSString *const UserRegisterFailNotification = @"UserRegisterFailNotification";

//用户操作失败的原因的key
NSString *const UserHandleFailErrorUserInfoKey = @"UserHandleFailErrorUserInfoKey";

//当前用户改变通知
NSString *const CurrentUserChangeNotification  = @"currentUserChangeNotification";

//----------------------------------------------------------


@interface GP_UserManager() <GP_ServiceRequestDelegate>

+ (GP_UserManager *)_shareUserManager;

+ (NSUserDefaults *)_userDefaults;

//当前用户
@property(nonatomic,strong) GP_User * currentUser;

//服务请求
@property(nonatomic,strong,readonly) GP_ServiceRequest * serviceRequest;

//用户登录
- (void)_userLoginWithUserName:(NSString *)userName password:(NSString *)password;

//尝试自动登录
- (void)_tryAutoLogin;

//用户注册
- (void)_userRegisterWithUserName:(NSString *)userName password:(NSString *)password;

//网络改变通知
- (void)_currentNetworkChangeNotification:(NSNotification *)notification;

@end

//----------------------------------------------------------

@implementation GP_UserManager
{
    NSDictionary  * _recentTryLoginUserInfo;
    BOOL            _isAutoLogin;
}

@synthesize serviceRequest = _serviceRequest;


+ (GP_UserManager *)_shareUserManager
{
    static GP_UserManager * shareUserManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareUserManager = [GP_UserManager new];
    });
    
    return shareUserManager;
}

+ (void)userLoginWithUserName:(NSString *)userName password:(NSString *)password
{
    [[self _shareUserManager] _userLoginWithUserName:userName password:password];
}

+ (void)tryAutoLogin
{
    [[self _shareUserManager] _tryAutoLogin];
}

+ (BOOL)isAutoLogining
{
    return [self _shareUserManager]->_isAutoLogin;
}

+ (void)cancleAutoLogin
{
    [[self _shareUserManager] _cancleAutoLogin];
}

+ (void)userRegisterWithUserName:(NSString *)userName password:(NSString *)password
{
    [[self _shareUserManager] _userRegisterWithUserName:userName password:password];
}

+ (GP_User *)currentUser
{
    return [[self _shareUserManager] currentUser];
}

+ (void)exitCurrentUser
{
    [[self _shareUserManager] setCurrentUser:nil];
    
    [self clearLoginRecorder];
}

+ (NSDictionary *)recentUserInfo
{
    return [[self _userDefaults] objectForKey:RecentUserInfoKey];
}

+ (void)clearLoginRecorder
{
    [[self _userDefaults] setObject:nil forKey:RecentUserInfoKey];
}

+ (NSUserDefaults *)_userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}



#define PostNotification(_name,_userInfo) \
[[NSNotificationCenter defaultCenter] postNotificationName:_name object:self userInfo:_userInfo]

- (void)_userLoginWithUserName:(NSString *)userName password:(NSString *)password
{
    self.currentUser = nil;
    
    //记录最近尝试登录的用户信息
    _recentTryLoginUserInfo = @{GP_SP_LOGIN_USERNAME : userName , GP_SP_LOGIN_PASSWORD : password};
    
    [self.serviceRequest startUserLoginServiceWithUserName:userName password:password];
    
}

- (void)_tryAutoLogin
{
    if (self.currentUser) {
        return;
    }
    
    NSDictionary * userInfo = [GP_UserManager recentUserInfo];
    
    if (userInfo) {
     
        
        if ([MyNetReachability currentNetReachabilityStatus] != kNotReachable) {
            
            _isAutoLogin = YES;
            
            //开始登录
            [self _userLoginWithUserName:userInfo[GP_SP_LOGIN_USERNAME] password:userInfo[GP_SP_REGISTER_PASSWORD]];
            
            //显示消息
            [MyStatusBarNotification showNotificationViewWithTitle:@"正在自动登录中..." automaticHidden:NO];
        }else{
            
             _isAutoLogin = NO;
            
            //失败
            [MyStatusBarNotification showNotificationViewWithTitle:@"自动登录失败,请检查网络设置。"
                                                   backgrounpColor:[UIColor redColor]
                                                         textColor:[UIColor whiteColor]
                                                   automaticHidden:YES];
            
            //接收网络改变通知
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_currentNetworkChangeNotification:)
                                                         name:NetReachabilityChangedNotification
                                                       object:nil];
        }
    
    }
}

- (void)_currentNetworkChangeNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NetReachabilityChangedNotification object:nil];
    
    [self _tryAutoLogin];
}

- (void)_cancleAutoLogin
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NetReachabilityChangedNotification object:nil];
}


- (void)_userRegisterWithUserName:(NSString *)userName password:(NSString *)password
{
    [self.serviceRequest startUserRegisterServiceWithUserName:userName password:password];
}


- (GP_ServiceRequest *)serviceRequest
{
    if (!_serviceRequest) {
        _serviceRequest = [[GP_ServiceRequest alloc] init];
        _serviceRequest.delegate = self;
    }
    
    return _serviceRequest;
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didFailRequestWithError:(NSError *)error
{
    if (type == ServiceRequestSerivceTypeUserLogin) {
        
        if (_isAutoLogin) {
            
            _isAutoLogin = NO;
            
            [MyStatusBarNotification showNotificationViewWithTitle:@"自动登录失败了!"
                                                   backgrounpColor:[[UIColor redColor] colorWithAlphaComponent:0.9f]
                                                         textColor:[UIColor whiteColor]
                                                   automaticHidden:YES];
            
        }else{
            PostNotification(UserLoginFailNotification,@{UserHandleFailErrorUserInfoKey : error});
        }
    }else{
        PostNotification(UserRegisterFailNotification,@{UserHandleFailErrorUserInfoKey : error});
    }
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didSuccessRequestWithData:(id)data
{
    if (type == ServiceRequestSerivceTypeUserLogin) {
        
        self.currentUser = data;
        
        if (_isAutoLogin) {
            
            _isAutoLogin = NO;
        
            [MyStatusBarNotification showNotificationViewWithTitle:
                                                 [NSString stringWithFormat:@"用户%@自动登录成功!",
                                                                    self.currentUser.userName]
                                                   automaticHidden:YES];
        
        }else{
            PostNotification(UserLoginSuccessNotification, nil);
        }
        
    }else{
        PostNotification(UserRegisterSuccessNotification, nil);
    }
}

- (void)setCurrentUser:(GP_User *)currentUser
{
    if (_currentUser != currentUser) {
        _currentUser = currentUser;

        //记录
        if (_currentUser && [_currentUser.userName isEqualToString:_recentTryLoginUserInfo[GP_SP_LOGIN_USERNAME]]) {
            [[GP_UserManager _userDefaults] setObject:_recentTryLoginUserInfo forKey:RecentUserInfoKey];
        }
        
        //发送通知
        PostNotification(CurrentUserChangeNotification, nil);
    }
}




@end
