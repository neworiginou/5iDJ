//
//  GP_SettingItemManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SettingItemManager.h"

//----------------------------------------------------------

@implementation GP_SettingItemManager

+ (id)valueForItme:(GP_SettingItem)item
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self keyForItme:item]];
}

+ (BOOL)boolValueForItme:(GP_SettingItem)item
{
    return [[self valueForItme:item] boolValue];
}

+ (NSString *)keyForItme:(GP_SettingItem)item
{
    static NSArray * itemToKeyMap = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        itemToKeyMap = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SettingItemToKeyMap" ofType:@"plist"]];
    });
    
    return itemToKeyMap[item];
}

+ (void)registerDefaultValue
{
    //注册默认值
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary * defaultSettingItem = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultSettingItem" ofType:@"plist"]];
    
    for (NSString * key in defaultSettingItem.allKeys) {
     
        //不存在则加入
        if (![userDefaults objectForKey:key]) {
            [userDefaults setObject:defaultSettingItem[key] forKey:key];
        }
    }
    
    [userDefaults synchronize];
}

@end
