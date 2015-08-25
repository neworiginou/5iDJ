//
//  MyAppDelegate.h
//  5idj
//
//  Created by Xuzhanya on 14-9-28.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

+ (instancetype)appDelegate;

- (id)initWithAppID:(NSString *)appID appUMKey:(NSString *)appUMkey;

@property(nonatomic,strong) UIWindow * window;

//版本
@property(nonatomic,strong,readonly) NSString * appVersion;
//build
@property(nonatomic,strong,readonly) NSString * appBuild;
//app store中的key
@property(nonatomic,strong,readonly) NSString * appID;
//app 友盟的key
@property(nonatomic,strong,readonly) NSString * appUMKey;

//程序launch时是否检查更新，默认为YES
@property(nonatomic) BOOL checkUpdateWhenLaunch;

//检查更新
+ (void)checkUpdate:(BOOL)showNoUpdateMessage;
//在appstroe打开
+ (void)openInAppStore;

//app加载的次数
+ (NSUInteger)appLaunchTimes;
//是否为第一次LaunchApp
+ (BOOL)isFirstLaunchApp;
//app进入前台的次数
+ (NSUInteger)appClickTimes;

//每click多少次显示评价页面，默认为4
@property(nonatomic) NSUInteger showScoreAlertViewPerClickTimes;

//评价页面内容文字，默认为nil
@property(nonatomic) NSString * scoreAlertViewContentText;

//显示评价页面,已经评价了不会显示
+ (void)showScoreAlertView;

//是否显示网络状态改变，默认为NO
@property(nonatomic) BOOL showNetworkStatusChange;

//显示网络状态的的处理函数
- (void)showNetworkStatusHandle;

@end
