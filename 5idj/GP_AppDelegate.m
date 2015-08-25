//
//  GP_AppDelegate.m
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-8.
//  Copyright (c) 2013年 hldw航. All rights reserved.
//

//----------------------------------------------------------

#import "GP_AppDelegate.h"
#import "GP_MainTabBarController.h"
#import "GP_UserGuideViewController.h"
#import "GP_Channel.h"
#import "GP_Video.h"
#import <AVFoundation/AVFoundation.h>
#import "MobClick.h"

//----------------------------------------------------------

#define AppID       @"900361077"
#define AppUMKey    @"53e10e9dfd98c53194008b84"

#define ScoreAlertViewTag       11611101
#define CheckUpdateAlertViewTag 11611102

//----------------------------------------------------------

@interface GP_AppDelegate() <GP_UserGuideViewControllerDelegate>

@end

//----------------------------------------------------------

@implementation GP_AppDelegate

- (id)init
{
    return [self initWithAppID:AppID appUMKey:AppUMKey];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if([super application:application didFinishLaunchingWithOptions:launchOptions])
    {
        //第一次加载注册设置默认值
        if ([GP_AppDelegate isFirstLaunchApp]) {
            [GP_SettingItemManager registerDefaultValue];
        }
        
        //删除缓存
        [MyDataStoreManager clearCacheFileForName:nil];
        
        //设置音频模式
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback
                 withOptions:AVAudioSessionCategoryOptionDuckOthers | AVAudioSessionCategoryOptionMixWithOthers
                       error:nil];
        
        //显示用户引导界面
        GP_UserGuideViewController * userGuideViewController = [GP_UserGuideViewController viewController];
        userGuideViewController.delegate = self;
        [userGuideViewController show];
        
        
//        [UIImagePNGRepresentation([ImageWithName(@"setting_delete.png") imageWithTintColor:[UIColor colorWithHexStr:@"#6a7789"]]) writeToFile:[[MyPathManager pathManagerWithFileFolder:@"IMAGE"] pathForFile:@"setting_delete@2x.png"] atomically:YES];
        
        return YES;
    }
    
    return NO;
    
}

- (void)userGuideViewControllerWillHidden:(GP_UserGuideViewController *)viewController
{
    //显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    //观察颜色改变
    [self setObserveThemeColorChange:YES];
    
    //显示主界面
    self.window=[[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.window.rootViewController = [[GP_MainTabBarController alloc] init];
    self.window.tintColor = [self currentThemeColor];
    
    [self.window makeKeyAndVisible];
    
    
    //监听网络改变
    self.showNetworkStatusChange = YES;
    
    //手机网络状况下显示提醒
    if ([MyNetReachability currentNetReachabilityStatus] == kReachableViaWWAN) {
        [self showNetworkStatusHandle];
    }
    
    //开始自动登录
    [GP_UserManager tryAutoLogin];
}

- (void)didChangeThemeColor
{
    self.window.tintColor = [self currentThemeColor];
}

- (void)showNetworkStatusHandle
{
    if ([GP_SettingItemManager boolValueForItme:GP_SettingItemShowNetworkStatusChangeNofication]) {
        [super showNetworkStatusHandle];
    }
}

+ (void)sendPlayVideoEvent:(GP_Video *)video duration:(NSTimeInterval)playDuration
{
    NSParameterAssert(video != nil);
    
    //统计类别、年份、播放进度
    NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (video.type) {
        [attributes setObject:video.type forKey:@"video_type"];
    }
    
    if (video.year) {
        [attributes setObject:video.year forKey:@"video_year"];
    }
    
    //播放进度
    CGFloat playProgress = (playDuration / video.duration) * 100;
    [attributes setObject:[NSString stringWithFormat:@"%d",(int)ChangeInMinToMax(playProgress, 0, 100)] forKey:@"__ct__"];
    
    [MobClick event:@"video_play_progress" attributes:attributes];
    
}

+ (void)sendViewChannelEvent:(GP_Channel *)channel
{
    NSParameterAssert(channel != nil);
    
    [MobClick event:@"click_channels" label:channel.title];
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    if ([[url scheme] isEqualToString:@"http"] && ![[url host] isEqualToString:@"5idj"]) {
//        return NO;
//    }
//    
////    NSLog(@"open URL = %@",url);
//    return YES;
//}


@end

