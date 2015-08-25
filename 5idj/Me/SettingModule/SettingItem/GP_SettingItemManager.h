//
//  GP_SettingItemManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

typedef NS_ENUM(int, GP_SettingItem){
    /** 自动开始播放视频*/
    GP_SettingItemAutoStartPlay                     = 0,
    /** 保存播放记录*/
    GP_SettingItemSavePlayRecoder                   = 1,
    /** 自动锁定屏幕当切换到全屏状态时*/
    GP_SettingItemAutoLockScreenWhenFullScreen      = 2,
    /** 自动恢复播放当切换到全屏状态时*/
    GP_SettingItemAutoResumeWhenFullScreen          = 3,
    /** 显示2G/3G网络播放视频警告*/
    GP_SettingItemShowAlertWhenPlayViaWWAN          = 4,
    /** 显示网络状态改变通知*/
    GP_SettingItemShowNetworkStatusChangeNofication = 5,
//    /** 拔出耳机时暂停播放*/
//    GP_SettingItemPauseWhenHeadphonesPulled         = 6,
    /** 插入耳机时恢复播放*/
    GP_SettingItemResumeWhenHeadphonesPluggedIn     = 6
};

//----------------------------------------------------------

@interface GP_SettingItemManager : NSObject

+ (id)valueForItme:(GP_SettingItem)item;

+ (BOOL)boolValueForItme:(GP_SettingItem)item;

+ (NSString *)keyForItme:(GP_SettingItem)item;

+ (void)registerDefaultValue;

@end
