//
//  GP_UserGuideViewController.m
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-10.
//  Copyright (c) 2013年 hldw航. All rights reserved.
//

//----------------------------------------------------------

#import "GP_UserGuideViewController.h"
#import "GP_PlayHistoryManager.h"
#import "GP_SearchHistoryManager.h"
#import "MobClick.h"

//----------------------------------------------------------

@interface GP_UserGuideViewController ()<UIWebViewDelegate>

//关闭广告
- (void)_closeAdButtonHandle;

@end

//----------------------------------------------------------

@implementation GP_UserGuideViewController
{
    UIWindow    * _window;
    UIWebView   * _adView;
    
    BOOL          _isLoadAdView;
    BOOL          _hadHidden;
}

- (void)loadView
{
    [super loadView];
    
    UIView * view = [[[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:nil options:nil] firstObject];
    
    if ([view isKindOfClass:[UIView class]]) {
        self.view = view;
    }
}

- (void)show
{
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.tintColor = [self currentThemeColor];
    _window.windowLevel = UIWindowLevelStatusBar + 1;
    
    //短暂的循环保留
    [_window setRootViewController:self];
    [_window makeKeyAndVisible];
    
    if ([GP_AppDelegate isFirstLaunchApp]) {
        //第一次启动开始迁移数据
        showHUDWithMyActivityIndicatorView(self.view, nil, @"正在迁移数据中,请稍后...");
        [GP_PlayHistoryManager migrateDataWithCompletedBlock:^(NSError *error1) {
            
            
            [GP_SearchHistoryManager migrateDataWithCompletedBlock:^(NSError *error2) {
               
                if (error1 || error2) {
                    showAlertView(@"提醒",@"迁移数据出错,数据可能丢失");
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                [self _hiddenWithAnimated:@YES];
            }];
        }];
    }else{
        //开始获取广告URL
        [self _startGetAdURL];
    }
}

- (void)_startGetAdURL
{
    //无网络，直接隐藏
    if ([MyNetReachability currentNetReachabilityStatus] == kNotReachable) {
        [self _hiddenWithAnimated:@YES];
        return;
    }
    
    //2秒后强制消失防止获取广告URL时间过长
    [self performSelector:@selector(_hiddenWithAnimated:) withObject:@YES afterDelay:2.f];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString * adURLStr = [MobClick getAdURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (_hadHidden) {
                return;
            }
            
            //取消之前的预约隐藏
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hiddenWithAnimated:) object:@YES];
            
            if (adURLStr.length) { //有广告
                
                _adView = [[UIWebView alloc] initWithFrame:self.view.bounds];
                _adView.delegate = self;
                _adView.hidden = YES;
                
                //添加广告请求
                [_adView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[adURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                
                [self.view addSubview:_adView];
                
                //2秒后强制消失防止加载广告时间过长
                [self performSelector:@selector(_hiddenWithAnimated:) withObject:@YES afterDelay:2.f];
                
            }else{
                [self _hiddenWithAnimated:@YES];
            }
        });
        
    });
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //取消之前的
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hiddenWithAnimated:) object:@YES];
    
    //出现广告
    webView.hidden = NO;
    
    _isLoadAdView = YES;
    
    //关闭按钮
    MyButton * colseAdButton = [[MyButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 80.f, 10.f, 70.f, 40.f)];
    colseAdButton.layer.cornerRadius = 5.f;
    [colseAdButton setTitle:@"关闭" forState:UIControlStateNormal];
    [colseAdButton setBackgroundColor:[[GP_ThemeManager shareThemeManager] currentThemeColor]];
    [colseAdButton setBackgroundColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [colseAdButton addTarget:self action:@selector(_closeAdButtonHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:colseAdButton];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (_isLoadAdView || _hadHidden) {
        return;
    }
    
    //取消之前的
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hiddenWithAnimated:) object:@YES];
    
    //消失
     [self _hiddenWithAnimated:@YES];
}

- (void)_closeAdButtonHandle
{
    [self _hiddenWithAnimated:@NO];
}

- (void)_hiddenWithAnimated:(NSNumber *)animated
{
    if (_hadHidden) {
        return;
    }
    
    _hadHidden = YES;
    
    //停止加载
    [_adView stopLoading];
    
    //通知代理
    [self.delegate userGuideViewControllerWillHidden:self];
    
    if ([animated boolValue]) {
        
        //消失动画
        [UIView animateWithDuration:1.f animations:^{
            
            _window.alpha = 0.f;
            _window.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        } completion:^(BOOL finished){
            [_window setHidden:YES];
            [_window setRootViewController:nil];
        }];

        
    }else{
        
        [_window setHidden:YES];
        [_window setRootViewController:nil];
    }
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
