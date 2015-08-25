//
//  NSDate+MyCategory.h
//  5idj
//
//  Created by Xuzhanya on 14-10-14.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MyCategory)

//获取同分钟的最小时间(即忽略秒）
- (NSDate *)dateWithSameMin;

//获取同小时的最小时间(即忽略分秒）
- (NSDate *)dateWithSameHour;

//获取同天的最小时间(即忽略时时分秒）
- (NSDate *)dateWithSameDay;

- (BOOL)isSameMin:(NSDate *)date;
- (BOOL)isSameHour:(NSDate *)date;
- (BOOL)isSameDay:(NSDate *)date;

//是否是当前分钟
- (BOOL)isToMin;

//是否是当前小时
- (BOOL)isToHour;

//判断是否是今天
- (BOOL)isToday;

@end
