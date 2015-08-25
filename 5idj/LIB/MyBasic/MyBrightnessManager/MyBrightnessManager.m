//
//  MyBrightnessManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-7.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "MyBrightnessManager.h"

@implementation MyBrightnessManager

- (void)setBrightness:(float)brightness
{
    [self setBrightness:brightness showAlert:NO];
}

- (float)brightness
{
    return [UIScreen mainScreen].brightness;
}

- (void)setBrightness:(float)brightness showAlert:(BOOL)showAlert
{
    if (showAlert) {
        
        BrightnessSettingsAlertShow();
        
        //取消以前请求
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hiddenSettingsAlert) object:nil];
        
        [self performSelector:@selector(_hiddenSettingsAlert) withObject:nil afterDelay:1.5f];
    }
    
    [UIScreen mainScreen].brightness = brightness;
}

- (void)_hiddenSettingsAlert
{
    BrightnessSettingsAlertHide();
}

@end


@interface _MyBrightnessSettingsAlertView : UIView

+ (void)show;

+ (BOOL)isVisible;

+ (void)hidden;

@end

@interface _MyBrightnessSettingsAlertView ()

+ (_MyBrightnessSettingsAlertView *)_shareAlertView;

//屏幕亮度改变通知
//- (void)_screenBrightnessDidChangeNotification:(NSNotification *)notification;

//状态栏改变通知
//- (void)_statusBarOrientationDidChangeNotification:(NSNotification *)notification;

@end


@implementation _MyBrightnessSettingsAlertView
{
    UIWindow  * _window;
}

+ (_MyBrightnessSettingsAlertView *)_shareAlertView
{
    static _MyBrightnessSettingsAlertView * alertView = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertView = [_MyBrightnessSettingsAlertView new];
    });
    
    return alertView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (void)show
{
    if (![self isVisible]) {
        
    }
}

+ (void)hidden
{
    if ([self isVisible]) {
        
    }
}

+ (BOOL)isVisible
{
    return NO;
}

@end


void BrightnessSettingsAlertShow()
{
    if ([NSThread isMainThread]) {
        [_MyBrightnessSettingsAlertView show];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_MyBrightnessSettingsAlertView show];
        });
    }
}

void BrightnessSettingsAlertHide()
{
    if ([NSThread isMainThread]) {
        [_MyBrightnessSettingsAlertView hidden];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_MyBrightnessSettingsAlertView hidden];
        });
    }
}

BOOL BrightnessSettingsAlertIsVisible()
{
    return [_MyBrightnessSettingsAlertView isVisible];
}
