//
//  GP_ThemeManager.h
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-30.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "GP_Theme.h"

//----------------------------------------------------------

//主题改变通知
UIKIT_EXTERN NSString * CurrentThemeColorChangeNotification;

//主题图片改变
UIKIT_EXTERN NSString * CurrentThemeImageChangeNotification;

//----------------------------------------------------------

@interface GP_ThemeManager : NSObject

+ (GP_ThemeManager *)shareThemeManager;

//主题数目
@property(nonatomic,readonly) NSUInteger themesCount;

//当前主题索引
@property(nonatomic) NSUInteger currentThemeIndex;

//指定索引上的主题
- (GP_Theme *)themeAtIndex:(NSUInteger)index;

//主题色
@property(nonatomic,strong,readonly) UIColor * currentThemeColor;

//毛玻璃主题背景图片
@property(nonatomic,strong,readonly) UIImage * currentThemeImage;

@end

//----------------------------------------------------------


@interface NSObject (Theme)

- (UIColor *)currentThemeColor;

- (void)setObserveThemeColorChange:(BOOL)observeThemeColorChange;

- (void)didChangeThemeColor;

- (UIImage *)currentThemeImage;

- (void)setObserveThemeImageChange:(BOOL)observeThemeImageChange;

- (void)didChangeThemeImage;

@end