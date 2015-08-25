//
//  MyAppDelegate.m
//  5idj
//
//  Created by Xuzhanya on 14-9-28.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "MyAppDelegate.h"
#import "MobClick.h"
#import "help.h"
#import "MyNetReachability.h"

#define ScoreAlertViewTag       11611101
#define CheckUpdateAlertViewTag 11611102

@implementation MyAppDelegate

@synthesize appVersion = _appVersion;
@synthesize appBuild   = _appBuild;
@synthesize appID      = _appID;
@synthesize appUMKey   = _appUMKey;

#pragma mark - life circle

+ (instancetype)appDelegate
{
    return (id)[UIApplication sharedApplication].delegate;
}

- (id)init
{
    return [self initWithAppID:nil appUMKey:nil];
}

- (id)initWithAppID:(NSString *)appID appUMKey:(NSString *)appUMkey
{
    self = [super init];
    
    if (self) {
        _appID    = appID;
        _appUMKey = appUMkey;
        
        NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        _appBuild   = [infoDictionary objectForKey:@"CFBundleVersion"];
        
        _checkUpdateWhenLaunch = YES;
        _showScoreAlertViewPerClickTimes = 4;
    }
    
    return self;
}

- (void)dealloc
{
}

#pragma mark - app delegate method

- (void)_umengTrack
{
    if (self.appUMKey.length) {
        
#if DEBUG
        
        //开启调试模式
        [MobClick setLogEnabled:YES];
        
#endif
        //开始统计
        [MobClick startWithAppkey:self.appUMKey reportPolicy:SEND_ON_EXIT channelId:nil];
        
        //设置版本
        [MobClick setAppVersion:self.appVersion];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //友盟
    [self _umengTrack];
    
    //加载App
    [self _launchApp];
    
    //检查更新
    if (self.checkUpdateWhenLaunch) {
        [[self class] checkUpdate:NO];
    }
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self _clickApp];
}

- (void)_launchApp
{
    //加载次数加1
    NSUInteger appLaunchTimes = [[self class] appLaunchTimes] + 1;
    
    //设置
    [[NSUserDefaults standardUserDefaults] setObject:@(appLaunchTimes) forKey:@"AppLaunchTimes"];
    
    //点击app
    [self _clickApp];
    
}

- (void)_clickApp
{
    NSUInteger appEnterForegroundTimes = [[self class] appClickTimes] + 1;
    
    //launch次数+1
    [[NSUserDefaults standardUserDefaults] setObject:@(appEnterForegroundTimes) forKey:@"AppEnterForegroundTimes"];
    
    //去评价
    if (self.showScoreAlertViewPerClickTimes && appEnterForegroundTimes % self.showScoreAlertViewPerClickTimes  == 0) {
        [[self class] showScoreAlertView];
    }
}


#pragma mark - app launch time

+ (NSUInteger)appLaunchTimes;
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString * appBuild = [[userDefaults objectForKey:@"AppBuild"] description];
    NSString * currentAppBuild = [(MyAppDelegate *)[self appDelegate] appBuild];
    
    //版本号小于则置为0
    if (![appBuild isEqualToString:currentAppBuild]) {
        [userDefaults setObject:@0 forKey:@"AppLaunchTimes"];
        [userDefaults setObject:currentAppBuild forKey:@"AppBuild"];
        [userDefaults setObject:@0 forKey:@"AppEnterForegroundTimes"];
        [userDefaults setBool:NO forKey:@"HadSorceApp"];
    }
    
    return [[userDefaults objectForKey:@"AppLaunchTimes"] unsignedIntegerValue];
}

+ (NSUInteger)appClickTimes
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppEnterForegroundTimes"] unsignedIntegerValue];
}

+ (BOOL)isFirstLaunchApp
{
    return [self appLaunchTimes] == 1;
}

#pragma mark - check update and app store

+ (void)openInAppStore
{
    NSString * appID = [[self appDelegate] appID];
    
    if (appID.length) {
        gotoAppStore(appID);
    }
}

+ (void)checkUpdate:(BOOL)showNoUpdateMessage
{
    if (showNoUpdateMessage) {
        [MobClick checkUpdateWithDelegate:[self appDelegate] selector:@selector(_appCheckUpdateCompleteShowNoUpdateMessage:)];
    }else{
        [MobClick checkUpdateWithDelegate:[self appDelegate] selector:@selector(_appCheckUpdateComplete:)];
    }
}

- (void)_appCheckUpdateComplete:(NSDictionary *)info
{
    [self _appCheckUpdateComplete:info showNoUpdateMessage:NO];
}

- (void)_appCheckUpdateCompleteShowNoUpdateMessage:(NSDictionary *)info
{
    [self _appCheckUpdateComplete:info showNoUpdateMessage:YES];
}

- (void)_appCheckUpdateComplete:(NSDictionary *)info showNoUpdateMessage:(BOOL)showNoUpdateMessage
{
    BOOL update = [info[@"update"] boolValue];
    
    if (update) {
        
        UIAlertView * alerView = [[UIAlertView alloc] initWithTitle:
                                  [NSString stringWithFormat:@"有可用的更新 V%@",info[@"version"]]
                                                            message:info[@"update_log"]
                                                           delegate:self
                                                  cancelButtonTitle:@"忽略此版本"
                                                  otherButtonTitles:@"立即去更新", nil];
        alerView.tag = CheckUpdateAlertViewTag;
        [alerView show];
        
    }else if(showNoUpdateMessage){
        showSuccessMessage(self.window, @"已经是最新版本", nil);
    }
}

- (NSString *)scoreAlertViewContentText
{
    return _scoreAlertViewContentText ? : @"亲，你觉得怎么样？去评价一下吧。\n我们不完美，但我们会一直努力。\n你的肯定是我们最大的动力。";
}


+ (void)showScoreAlertView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HadSorceApp"]) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"给我们评价"
                                                             message:[[self appDelegate] scoreAlertViewContentText]
                                                            delegate:[self appDelegate]
                                                   cancelButtonTitle:@"残忍拒绝"
                                                   otherButtonTitles:@"立即评价",@"稍后提醒",nil];
        alertView.tag = ScoreAlertViewTag;
        [alertView show];
    }
}

#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ScoreAlertViewTag) {
        
        if (alertView.cancelButtonIndex == buttonIndex) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HadSorceApp"];
        }else if(alertView.firstOtherButtonIndex == buttonIndex){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HadSorceApp"];
            [[self class] openInAppStore];
        }
    }else if (alertView.tag == CheckUpdateAlertViewTag){
        
        if (alertView.cancelButtonIndex != buttonIndex) {
            [[self class] openInAppStore];
        }
    }
}


#pragma mark - net work status

- (void)setShowNetworkStatusChange:(BOOL)showNetworkStatusChange
{
    if (_showNetworkStatusChange != showNetworkStatusChange) {
        
        if (_showNetworkStatusChange) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NetReachabilityChangedNotification
                                                          object:nil];
        }
        
        _showNetworkStatusChange = showNetworkStatusChange;
        
        if (_showNetworkStatusChange) {
            
            [MyNetReachability startNotifier];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_currentNetworkStatusChangeNotification:)
                                                         name:NetReachabilityChangedNotification
                                                       object:nil];
        }
        
    }
}

- (void)_currentNetworkStatusChangeNotification:(NSNotification *)notification;
{
    if ([NSThread isMainThread]) {
        [self showNetworkStatusHandle];
    }else{
        [self performSelectorOnMainThread:@selector(showNetworkStatusHandle)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)showNetworkStatusHandle
{
    showNetworkStatusMessage(self.window);
}


@end
