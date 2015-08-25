//
//  MyStatusBarNotification.h
//  Bestone
//
//  Created by Xuzhanya on 14-6-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <UIKit/UIKit.h>

//#warning 修改成显示时设置颜色

@interface MyStatusBarNotification : NSObject

//默认黑色
//+ (void)setNotificationViewBackgroundColor:(UIColor *)backgroundColor;

////默认白色
//+ (void)setNotificationTextColor:(UIColor *)textColor;

//显示通知视图
+ (void)showNotificationViewWithTitle:(NSString *)title automaticHidden:(BOOL)automaticHidden;

//显示通知视图
+ (void)showNotificationViewWithTitle:(NSString *)title
                      backgrounpColor:(UIColor *)backgrounpColor
                            textColor:(UIColor *)textColor
                      automaticHidden:(BOOL)automaticHidden;


//更新通知视图
+ (void)updateNotificationViewWithTitle:(NSString *)title;

//隐藏通知视图
+ (void)hiddenNotificationView;

//是否正在显示通知视图
+ (BOOL)isShowingNotificationView;


@end
