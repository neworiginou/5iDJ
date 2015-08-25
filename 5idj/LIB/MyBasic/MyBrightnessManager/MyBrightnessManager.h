//
//  MyBrightnessManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-7.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyBrightnessManager : NSObject

@property(nonatomic) float brightness;

- (void)setBrightness:(float)brightness showAlert:(BOOL)showAlert;

@end

UIKIT_EXTERN void BrightnessSettingsAlertShow();
UIKIT_EXTERN void BrightnessSettingsAlertHide();
UIKIT_EXTERN BOOL BrightnessSettingsAlertIsVisible();
