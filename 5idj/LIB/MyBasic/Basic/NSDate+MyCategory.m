//
//  NSDate+MyCategory.m
//  5idj
//
//  Created by Xuzhanya on 14-10-14.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "NSDate+MyCategory.h"
#import "MacroDef.h"

@implementation NSDate (MyCategory)

- (NSDate *)dateWithSameMin
{
    NSTimeInterval timeInterval = [self timeIntervalSinceReferenceDate];
    return [NSDate dateWithTimeIntervalSinceReferenceDate:MinForTimeInterVal(timeInterval) * SecPerMin];
}

- (NSDate *)dateWithSameHour
{
    NSTimeInterval timeInterval = [self timeIntervalSinceReferenceDate];
    return [NSDate dateWithTimeIntervalSinceReferenceDate:HourForTimeInterVal(timeInterval) * SecPerHour];
}

- (NSDate *)dateWithSameDay
{
    NSTimeInterval timeInterval = [self timeIntervalSinceReferenceDate];
    return [NSDate dateWithTimeIntervalSinceReferenceDate:DayForTimeInterVal(timeInterval) * SecPerDay];
}

- (BOOL)isSameMin:(NSDate *)date
{
    BOOL bRet = NO;
    
    if (date) {
        bRet = MinForTimeInterVal([self timeIntervalSinceReferenceDate]) == MinForTimeInterVal([date timeIntervalSinceReferenceDate]);
    }
    
    return bRet;
}

- (BOOL)isSameHour:(NSDate *)date
{
    BOOL bRet = NO;
    
    if (date) {
        bRet = HourForTimeInterVal([self timeIntervalSinceReferenceDate]) == HourForTimeInterVal([date timeIntervalSinceReferenceDate]);
    }
    
    return bRet;
}

- (BOOL)isSameDay:(NSDate *)date
{
    BOOL bRet = NO;
    
    if (date) {
        bRet = DayForTimeInterVal([self timeIntervalSinceReferenceDate]) == DayForTimeInterVal([date timeIntervalSinceReferenceDate]);
    }
    
    return bRet;
}

- (BOOL)isToMin
{
    return [self isSameMin:[NSDate date]];
}

- (BOOL)isToHour
{
    return [self isSameHour:[NSDate date]];
}

- (BOOL)isToday
{
    return [self isSameDay:[NSDate date]];
}

@end
