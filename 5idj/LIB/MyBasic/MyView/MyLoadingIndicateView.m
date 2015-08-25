//
//  MyLoadingIndicateView.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-28.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyLoadingIndicateView.h"
#import "MyNetReachability.h"
#import "MacroDef.h"

//----------------------------------------------------------

@interface MyLoadingIndicateView()

- (void)_tapGestureHandle;

- (void)_networkChangeNotification:(NSNotification *)notification;


@end

//----------------------------------------------------------

@implementation MyLoadingIndicateView
{
    UITapGestureRecognizer * _tapGestureRecognizer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _supportTapGesture = NO;
        _contextTag        = DefaultContextTag;
        
        self.hidden = YES;
        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSupportTapGesture:(BOOL)supportTapGesture
{
    if (_supportTapGesture != supportTapGesture) {
        
        if (_supportTapGesture && _tapGestureRecognizer) {
             [self removeGestureRecognizer:_tapGestureRecognizer];
        }
        
        _supportTapGesture = supportTapGesture;
        
        if (_supportTapGesture) {
            
            if (!_tapGestureRecognizer) {
                _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureHandle)];
            }
            
            [self addGestureRecognizer:_tapGestureRecognizer];
        }
    }
}

- (void)_tapGestureHandle
{
    id<MyLoadingIndicateViewDelegate> __delegate = self.delegate;
    
    ifRespondsSelector(__delegate, @selector(loadingIndicateViewDidTap:)){
        [__delegate loadingIndicateViewDidTap:self];
    }
}

- (void)_networkChangeNotification:(NSNotification *)notification
{
     NetworkStatus status = [MyNetReachability currentNetReachabilityStatus];
    
    if (_contextTag == NoNetworkContextTag && status != kNotReachable) {
        [self _tapGestureHandle];
    }else if (_contextTag != NoNetworkContextTag){
         [[NSNotificationCenter defaultCenter] removeObserver:self name:NetReachabilityChangedNotification object:nil];
    }
}


- (void)showLoadingStatusWithTitle:(NSString *)title detailText:(NSString *)detailText
{
    [self hiddenView];
    
    self.style = MyIndicateViewStyleActivityView;
    self.titleLabelText = title;
    self.detailLabelText = detailText;
    
    self.hidden = NO;
}

- (void)showLoadingErrorStatusWithTitle:(NSString *)title detailText:(NSString *)detailText
{
    [self showLoadingErrorStatusWithWithImage:ImageWithName(@"error_reload.png") title:title detailText:detailText];
}

- (void)showLoadingErrorStatusWithWithImage:(UIImage *)image
                                      title:(NSString *)title
                                 detailText:(NSString *)detailText
{
    [self hiddenView];
    
    self.image = image;
    self.style = MyIndicateViewStyleImageView;
    self.titleLabelText = title;
    self.detailLabelText = detailText;
    
    self.supportTapGesture = YES;
    self.contextTag = LoadingErrorContextTag;
    
    self.hidden = NO;
}
- (void)showNoNetworkStatus
{
    [self showNoNetworkStatusWithImage:ImageWithName(@"error_no_network.png")
                                 title:@"网络似乎断开了连接"
                            detailText:@"请检查网络设置"
                 observerNetworkChange:YES];
}

- (void)showNoNetworkStatusWithImage:(UIImage *)image
                               title:(NSString *)title
                          detailText:(NSString *)detailText
               observerNetworkChange:(BOOL)observerNetworkChange
{
    [self hiddenView];
    
    self.image = image;
    self.style = MyIndicateViewStyleImageView;
    
    self.titleLabelText  = title;
    self.detailLabelText = detailText;
    
    self.contextTag = NoNetworkContextTag;
    self.hidden     = NO;
    
    if (observerNetworkChange) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_networkChangeNotification:) name:NetReachabilityChangedNotification object:nil];
    }
}


- (void)showImageStatusWithImage:(UIImage *)image title:(NSString *)title detailText:(NSString *)detailText
{
    [self hiddenView];
    
    self.image = image;
    
    self.style = MyIndicateViewStyleImageView;
    self.titleLabelText = title;
    self.detailLabelText = detailText;

    self.hidden = NO;
}

- (void)showCustomViewStatusWithCustomView:(UIView *)customView
                                     title:(NSString *)title
                                detailText:(NSString *)detailText
{
    [self hiddenView];
    
    self.customView = customView;
    
    self.style = MyIndicateViewStyleCustomView;
    self.titleLabelText = title;
    self.detailLabelText = detailText;
    
    self.hidden = NO;
}


- (void)hiddenView
{
    self.supportTapGesture = NO;
    self.contextTag = DefaultContextTag;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NetReachabilityChangedNotification object:nil];
    
//    [self _reset];
    self.hidden = YES;
}



@end
