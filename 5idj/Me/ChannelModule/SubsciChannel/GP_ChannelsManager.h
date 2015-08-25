//
//  GP_ChannelsManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-12.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "GP_Channel.h"

//----------------------------------------------------------

//订阅的视频改变
extern NSString * const SubscibedChannelsChangeNotifcation;
extern NSString * const ChangedChannelsUserinfoKey;

//核对订阅视频的状态改变
extern NSString * const CheckChannelsStatusChangeNotifcation;
extern NSString * const CheckChannelsStatusUserinfoKey;

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, CheckChannelsStatus) {
    CheckChannelsStatusChecking,    //正在核对
    CheckChannelsStatusSuccess,     //核对成功
    CheckChannelsStatusFail         //核对失败
};

//----------------------------------------------------------

@interface GP_ChannelsManager : NSObject

+ (GP_ChannelsManager *)defaultManager;

//返回订阅的频道
- (NSArray *)subscibedChannels;

//订阅频道
- (void)subscibeChannels:(NSArray *)channels;

//取消订阅频道
- (void)cancleSubscibeChannels:(NSArray *)channels;

//判断是否为订阅过的频道
- (BOOL)isSubscibedChannel:(GP_Channel *)channel;

@end
