//
//  GP_PrivacyPolicyViewController.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-9-15.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "GP_PrivacyPolicyViewController.h"
#import "GP_LoadingIndicateView.h"

//----------------------------------------------------------

@interface GP_PrivacyPolicyViewController ()<
                                              UIWebViewDelegate,
                                              MyLoadingIndicateViewDelegate
                                            >
@end

//----------------------------------------------------------

@implementation GP_PrivacyPolicyViewController
{
    UIWebView * _webView;
    GP_LoadingIndicateView * _loadingIndicateView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = @"隐私政策";
    
    CGRect bounds = self.view.bounds;
    
    _webView = [[UIWebView alloc] initWithFrame:bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webView.backgroundColor  = [UIColor clearColor];
    _webView.delegate         = self;
    _webView.scalesPageToFit  = YES;
    _webView.scrollView.contentInset = UIEdgeInsetsMake(64.f, 0.f, 0.f, 0.f);
    [self.view addSubview:_webView];
    
    _loadingIndicateView = [[GP_LoadingIndicateView alloc] initWithFrame:CGRectMake(0.f, 64.f, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - 64.f)];
    _loadingIndicateView.backgroundColor  = [UIColor clearColor];
    _loadingIndicateView.delegate         = self;
    _loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                            UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_loadingIndicateView];
    
    //加载数据
    [self _loadData];
}

- (void)dealloc
{
    [_webView stopLoading];
}

- (void)_loadData
{
    _webView.hidden = YES;
    
    if ([self currentNetworkStatus:NO] != kNotReachable) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString * urlStr = @"http://119.97.131.73:18080/ExtTest/PrivacyPolicy";
            
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
        });
    }else{
        [_loadingIndicateView showNoNetworkStatus];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //加载提示
    [_loadingIndicateView showLoadingStatusWithTitle:nil detailText:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _webView.hidden = NO;
    
    _webView.alpha = 0.f;
    [UIView animateWithDuration:0.3f animations:^{
        _webView.alpha = 1.f;
    }];
    
    [_loadingIndicateView hiddenView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_loadingIndicateView showLoadingErrorStatusWithTitle:[error localizedDescription]
                                               detailText:@"点击页面重试"];
}

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    [self _loadData];
}

@end
