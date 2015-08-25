//
//  MyStatusBarNotification.m
//  Bestone
//
//  Created by Xuzhanya on 14-6-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "MyStatusBarNotification.h"
#import "Basic.h"

@interface MyStatusBarNotificationInfo : NSObject

- (id)initWithTitle:(NSString *)title
    backgrounpColor:(UIColor *)backgrounpColor
          textColor:(UIColor *)textColor
    automaticHidden:(BOOL)automaticHidden;

@property(nonatomic,readonly) BOOL  automaticHidden;

@property(nonatomic,strong,readonly) NSString * title;

@property(nonatomic,strong,readonly) UIColor * backgrounpColor;

@property(nonatomic,strong,readonly) UIColor * textColor;

@end


@implementation MyStatusBarNotificationInfo

- (id)initWithTitle:(NSString *)title
    backgrounpColor:(UIColor *)backgrounpColor
          textColor:(UIColor *)textColor
    automaticHidden:(BOOL)automaticHidden
{
    self = [super init];
    
    if (self) {
        _title = title;
        _automaticHidden = automaticHidden;
        _backgrounpColor = backgrounpColor;
        _textColor       = textColor;
    }
    
    return self;
}

@end


@interface MyStatusBarNotification ()

+ (MyStatusBarNotification *)_defaultStatusBarNotification;

//显示的窗口
@property(nonatomic,strong,readonly) UIWindow * window;

//文字标签
@property(nonatomic,strong,readonly) UILabel  * titleLabel;

//状态栏方向改变通知
- (void)_statusBarOrientationDidChangeNotification:(NSNotification *)notification;

//是否正在显示
- (BOOL)_isShowing;

//显示
- (void)_showNotificationViewWithTitle:(NSString *)title
                      backgrounpColor:(UIColor *)backgrounpColor
                            textColor:(UIColor *)textColor
                      automaticHidden:(BOOL)automaticHidden;

//隐藏
- (void)_hiddenNotificationView;

//更新通知视图
- (void)_updateNotificationViewWithTitle:(NSString *)title;

@end

@implementation MyStatusBarNotification
{
    //是否在进行显示动作
    BOOL    _isShowAnimating;
    
    //是否在进行隐藏动作
    BOOL    _isHiddenAnimating;
    
    NSTimer  * _hiddenTimer;
    
    //显示队列
    MyListQuene * _showTitleQuene;
    
    //隐藏次数
    NSUInteger    _hiddenCount;
    
    UIInterfaceOrientation _interfaceOrientation;
    
}

@synthesize window = _window;
@synthesize titleLabel = _titleLabel;

+ (MyStatusBarNotification *)_defaultStatusBarNotification
{
    static MyStatusBarNotification * defaultStatusBarNotification = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStatusBarNotification = [[MyStatusBarNotification alloc] init];
    });
    
    return defaultStatusBarNotification;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_statusBarOrientationDidChangeNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        _interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        _showTitleQuene = [[MyListQuene alloc] init];
    }
    
    return self;
}

- (UIWindow *)window
{
    if (!_window) {
    
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, screenSize().height)];
        _window.userInteractionEnabled = NO;
        _window.windowLevel = UIWindowLevelStatusBar + 1;
    }
    
    return _window;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, StatusBarHeight)];
        _titleLabel.backgroundColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:13.f];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.window addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (void)_updateView
{
    
    if (UIInterfaceOrientationIsPortrait(_interfaceOrientation)) {
        self.window.bounds = CGRectMake(0.f, 0.f, screenSize().width, screenSize().height);
    }else{
        self.window.bounds = CGRectMake(0.f, 0.f, screenSize().height, screenSize().width);
    }
    
    self.window.transform = rotationAffineTransformForOrientation(_interfaceOrientation);
    
    self.titleLabel.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.window.bounds), StatusBarHeight);
}


- (void)_statusBarOrientationDidChangeNotification:(NSNotification *)notification
{
    if ([self _isShowing]) {
        
        NSTimeInterval animatedTime = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        
        if (UIInterfaceOrientationIsLandscape(_interfaceOrientation) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            animatedTime *= 2;
        }
    
        _interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        [UIView animateWithDuration:animatedTime animations:^{
            [self _updateView];
        }];
        
    }else{
        
        _interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        [self _updateView];
    }
}



- (BOOL)_isShowing
{
    return !self.window.hidden && !_isHiddenAnimating;
}

- (void)_showNotificationViewWithTitle:(NSString *)title
                       backgrounpColor:(UIColor *)backgrounpColor
                             textColor:(UIColor *)textColor
                       automaticHidden:(BOOL)automaticHidden
{
    //隐藏且没有动画
    if (self.window.hidden && !_isHiddenAnimating && !_isShowAnimating) {
        
        
        self.titleLabel.text = title;
        self.titleLabel.textColor = textColor;
        self.titleLabel.backgroundColor = backgrounpColor;
        
        
        //更新视图
        self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, 0.f, -StatusBarHeight);
        self.titleLabel.alpha = 0.f;
        
        self.window.hidden = NO;
        
        
        //开始动作
        [UIView animateWithDuration:0.5f animations:^{
            
            _isShowAnimating = YES;
            
            self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, 0.f, StatusBarHeight);
            self.titleLabel.alpha = 1.f;
            
        } completion:^(BOOL finished){
            
            _isShowAnimating = NO;
            
            if (_hiddenCount) {
                -- _hiddenCount;
                
                [self _hiddenNotificationView];
            }
            
        }];
        
        //计时器无效
        [_hiddenTimer invalidate];
        _hiddenTimer = nil;
        
        if (automaticHidden) {
            
            //计时器
            _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(_hiddenNotificationView) userInfo:nil repeats:NO];
        }
        
    }else{
        //加入显示队列
        [_showTitleQuene pushToTail:[[MyStatusBarNotificationInfo alloc] initWithTitle:title backgrounpColor:backgrounpColor textColor:textColor automaticHidden:automaticHidden]];
        
        //隐藏当前视图
        [self _hiddenNotificationView];
    }
}

- (void)_hiddenNotificationView
{
    
    if ([self _isShowing]) {
        
        if (_isShowAnimating) {
            ++ _hiddenCount;
            return;
        }
        
        //计时器无效
        [_hiddenTimer invalidate];
        _hiddenTimer = nil;
        
        //开始
        [UIView animateWithDuration:0.3f animations:^{
            
            _isHiddenAnimating = YES;
            
            self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, 0.f, -StatusBarHeight);
            self.titleLabel.alpha = 0.f;
            
        }completion:^(BOOL finished){
            
            _isHiddenAnimating = NO;
            
            self.window.hidden = YES;
            
            self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, 0.f, StatusBarHeight);
            self.titleLabel.alpha = 1.f;
            
            if (_showTitleQuene.count) {
                
                MyStatusBarNotificationInfo * info = [_showTitleQuene popFromHead];
                
                [self _showNotificationViewWithTitle:info.title
                                     backgrounpColor:info.backgrounpColor
                                           textColor:info.textColor
                                     automaticHidden:info.automaticHidden];
            }
        }];
        
    }
}

- (void)_updateNotificationViewWithTitle:(NSString *)title
{
    if ([self _isShowing]) {
        self.titleLabel.text = title;
    }
}

+ (void)showNotificationViewWithTitle:(NSString *)title automaticHidden:(BOOL)automaticHidden
{
    [self showNotificationViewWithTitle:title
                        backgrounpColor:[[UIColor blackColor] colorWithAlphaComponent:0.9f]
                              textColor:[UIColor whiteColor]
                        automaticHidden:automaticHidden];
}

+ (void)showNotificationViewWithTitle:(NSString *)title
                      backgrounpColor:(UIColor *)backgrounpColor
                            textColor:(UIColor *)textColor
                      automaticHidden:(BOOL)automaticHidden
{
    MyStatusBarNotification * shareStatusBarNotification = [self _defaultStatusBarNotification];
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [shareStatusBarNotification _showNotificationViewWithTitle:title
                                                       backgrounpColor:backgrounpColor
                                                             textColor:textColor
                                                       automaticHidden:automaticHidden];
        });
    }else{
        
        [shareStatusBarNotification _showNotificationViewWithTitle:title
                                                backgrounpColor:backgrounpColor
                                                         textColor:textColor
                                                   automaticHidden:automaticHidden];

    }

}

+ (void)hiddenNotificationView
{
    MyStatusBarNotification * shareStatusBarNotification = [self _defaultStatusBarNotification];
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [shareStatusBarNotification _hiddenNotificationView];
        });
    }else{
        [shareStatusBarNotification _hiddenNotificationView];
    }
}


+ (void)updateNotificationViewWithTitle:(NSString *)title
{
    MyStatusBarNotification * shareStatusBarNotification = [self _defaultStatusBarNotification];
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [shareStatusBarNotification _updateNotificationViewWithTitle:title];
        });
    }else{
        [shareStatusBarNotification _updateNotificationViewWithTitle:title];
    }
}

+ (BOOL)isShowingNotificationView
{
    return [[self _defaultStatusBarNotification] _isShowing];
}


@end
