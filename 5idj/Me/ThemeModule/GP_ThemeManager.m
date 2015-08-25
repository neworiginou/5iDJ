//
//  GP_ThemeManager.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-30.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ThemeManager.h"
#import "GP_MainTabBarController.h"

//----------------------------------------------------------

#define SettingThemeAlertViewTag 1000

//----------------------------------------------------------

NSString * CurrentThemeColorChangeNotification = @"CurrentThemeColorChangeNotification";
NSString * CurrentThemeImageChangeNotification = @"CurrentThemeImageChangeNotification";

//----------------------------------------------------------

static GP_ThemeManager * shareThemeManager = nil;

//----------------------------------------------------------

@interface GP_ThemeManager ()<UIAlertViewDelegate>

@property(nonatomic,strong,readonly) NSMutableArray * themes;

//显示设置主题警告视图
- (void)_showSettingThemeAlertViewWithTitle:(NSString *)title;

@end

//----------------------------------------------------------

@implementation GP_ThemeManager

@synthesize themes = _themes;

+ (GP_ThemeManager *)shareThemeManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareThemeManager = [[GP_ThemeManager alloc] init];
    });
    
    return shareThemeManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return shareThemeManager ?: [super allocWithZone:zone];
}

- (id)init
{
    if (shareThemeManager) {
        return shareThemeManager;
    }
    
    self = [super init];
    
    if (self) {
        
        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        //存在老版本数据
        if ([standardUserDefaults objectForKey:@"CurrentThemeColorHexKey"] ||
            [standardUserDefaults objectForKey:@"CurrentThemeColorIndexKey"]) {
            
            //显示消息
            [self _showSettingThemeAlertViewWithTitle:@"由于应用版本更新老版本的主题色已失效,对此我们深表歉意!\n现推出主题设置功能,是否立即去体验?"];
            
            [standardUserDefaults removeObjectForKey:@"CurrentThemeColorHexKey"];
            [standardUserDefaults removeObjectForKey:@"CurrentThemeColorIndexKey"];
        }
        
        //获取当期主题ID
        NSNumber * currentThemeID = [standardUserDefaults objectForKey:@"currentThemeIDKey"];
        
        //主题
        NSArray * themeInfos = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GP_Themes" ofType:@"plist"]];
        
        _themes = [NSMutableArray arrayWithCapacity:themeInfos.count];
        
        //当前index
        _currentThemeIndex = 0;
        
        BOOL bRet = NO;
        
        for (NSDictionary * info in themeInfos) {
            GP_Theme * theme = [[GP_Theme alloc] initWithInfoDic:info];
            [_themes addObject:theme];
            
            if (currentThemeID && !bRet) {
                
                if ([currentThemeID integerValue] != theme.ID) {
                    ++ _currentThemeIndex;
                }else{
                    bRet = YES;
                }
            }
        }
        
        if (!currentThemeID || !bRet){
            
            _currentThemeIndex = 0;
            
            //写入
            [standardUserDefaults setInteger:[_themes[_currentThemeIndex] ID] forKey:@"currentThemeIDKey"];
            
            if (currentThemeID) {
                
                [self _showSettingThemeAlertViewWithTitle:@"由于应用版本更新您设置的主题已失效,对此我们深表歉意!\n是否立即去设置其他主题?"];
            }
        }
        
        //当前颜色
        _currentThemeColor = [UIColor colorWithHexStr:[_themes[_currentThemeIndex] themeHexColor]];
        
        //更新图片
        [self _updateThemeImage];
        
    }
    
    return self;
}

- (NSUInteger)themesCount
{
    return _themes.count;
}

- (void)setCurrentThemeIndex:(NSUInteger)currentThemeIndex
{
    if (_currentThemeIndex != currentThemeIndex) {
        
        _currentThemeIndex = currentThemeIndex;
        
        //写入
        [[NSUserDefaults standardUserDefaults] setInteger:[_themes[_currentThemeIndex] ID] forKey:@"currentThemeIDKey"];
        
        //颜色
        _currentThemeColor = [UIColor colorWithHexStr:[_themes[_currentThemeIndex] themeHexColor]];
        
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:CurrentThemeColorChangeNotification object:self];
        
        //更新图片
        [self _updateThemeImage];
    }

}

- (GP_Theme *)themeAtIndex:(NSUInteger)index
{
    return _themes[index];
}

- (void)_updateThemeImage
{
    _currentThemeImage = nil;
    
    NSUInteger tmpCurrentThemeIndex = _currentThemeIndex;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        if (tmpCurrentThemeIndex == _currentThemeIndex) {
            
            NSString * imageName = [_themes[tmpCurrentThemeIndex] themeImageName];
            
            UIImage * tmpImage = !imageName ? nil : [ImageWithName(imageName) applyBlurWithRadius:5.f tintColor:[UIColor colorWithWhite:1.f alpha:0.6f] saturationDeltaFactor:1.8f maskImage:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (tmpCurrentThemeIndex == _currentThemeIndex) {
                    
                    _currentThemeImage = tmpImage;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:CurrentThemeImageChangeNotification object:self];
                }
                
            });
            
        }
        
    });
}


- (void)_showSettingThemeAlertViewWithTitle:(NSString *)title
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:title
                                                        delegate:self
                                               cancelButtonTitle:@"算了"
                                               otherButtonTitles:@"去设置", nil];
    alertView.tag = SettingThemeAlertViewTag;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SettingThemeAlertViewTag) {
        
        if (alertView.cancelButtonIndex != buttonIndex) {
            [[GP_MainTabBarController currentTopViewController] pushSettingThemeViewControllerWithAnimated:YES];
        }
    }
}

@end


//----------------------------------------------------------

@implementation NSObject (ThemeColor)

- (UIColor *)currentThemeColor
{
    return [GP_ThemeManager shareThemeManager].currentThemeColor;
}

- (void)setObserveThemeColorChange:(BOOL)observeThemeColorChange
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CurrentThemeColorChangeNotification object:nil];
    
    if (observeThemeColorChange) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeColorChangeNotification:) name:CurrentThemeColorChangeNotification object:nil];
    }
    
}

- (void)_currentThemeColorChangeNotification:(NSNotification *)notification
{
    if ([NSThread isMainThread]) {
        [self didChangeThemeColor];
    }else{
        [self performSelector:@selector(didChangeThemeColor) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    }
}

- (void)didChangeThemeColor
{
    
}


- (UIImage *)currentThemeImage
{
    return [GP_ThemeManager shareThemeManager].currentThemeImage;
}

- (void)setObserveThemeImageChange:(BOOL)observeThemeImageChange
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CurrentThemeImageChangeNotification object:nil];
    
    if (observeThemeImageChange) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeImageChangeNotification:) name:CurrentThemeImageChangeNotification object:nil];
    }
}

- (void)_currentThemeImageChangeNotification:(NSNotification *)notification
{
    [self didChangeThemeImage];
}

- (void)didChangeThemeImage
{
    //do noting
}

@end

