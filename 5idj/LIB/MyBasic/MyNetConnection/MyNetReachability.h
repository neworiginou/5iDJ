//
//  MyNetReachability.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "Reachability.h"

extern NSString *const NetReachabilityChangedNotification;

/**
 * 网络可达性监听
 */
@interface MyNetReachability : NSObject

/**
 * 开始监听
 * @return 已经在监听或成功开始监听返回YES
 */
+ (BOOL)startNotifier;

/**
 * 停止监听
 */
+ (void)stopNotifier;

/**
 * 返回当前网络状态
 */
+ (NetworkStatus)currentNetReachabilityStatus;


@end
