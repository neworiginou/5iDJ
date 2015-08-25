//
//  GP_BasicHelpView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-13.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicHelpView.h"
#import "GP_AppDelegate.h"

//----------------------------------------------------------

@implementation GP_BasicHelpView
{
    UIWindow    * _window;
    NSString    * _key;
}

+ (NSUserDefaults *)userDefaultsForHelpView
{
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 7000
//    return [[NSUserDefaults alloc] initWithSuiteName:@"userDefaultsForHelpView"];
//#else
//    return [[NSUserDefaults alloc] initWithUser:@"userDefaultsForHelpView"];
//#endif
    
    return [NSUserDefaults standardUserDefaults];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithKey:nil];
}

- (id)initWithKey:(NSString *)key
{
    if (![[GP_BasicHelpView userDefaultsForHelpView] boolForKey:key]) {
        
        self = [super initWithFrame:CGRectZero];
        
        if (self) {
            _key = key;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_aplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
            
        }
        
        return self;
    }
    
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_aplicationWillEnterForegroundNotification:(NSNotification *)notification
{
    [self startAnimation];
}

- (void)show
{
    [self hidden];
    
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.windowLevel = UIWindowLevelStatusBar;
    _window.backgroundColor = BlackColorWithAlpha(0.6f);
    self.frame = _window.bounds;
    
    //显示时建立引用循环
    [_window addSubview:self];
    [_window setHidden:NO];
    
    //开始动画
    [self startAnimation];
    
}

- (void)hidden
{
    if (_window) {
        
        [UIView animateWithDuration:0.3f animations:^{
        
            _window.alpha = 0.f;
            _window = nil;
            
        } completion:^(BOOL finished){
            [_window setHidden:YES];
            [self removeFromSuperview];
        }];
        
        //写入
        [[GP_BasicHelpView userDefaultsForHelpView] setBool:YES forKey:_key];
        
    }
}

- (void)startAnimation
{
    //do nothing
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidden];
}


@end
