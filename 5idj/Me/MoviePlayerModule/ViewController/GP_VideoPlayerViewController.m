//
//  GP_MoviePlayerViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-2-25.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//
//----------------------------------------------------------

#import "GP_VideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GP_VideoInfoView.h"
#import "GP_VideoPlayerController.h"
#import "GP_ServiceRequest.h"
#import "GP_VideoPlayerTransting.h"
#import "GP_MainTabBarController.h"

//UIKIT_EXTERN NSString * const CollectVideosChangeNotification;

//----------------------------------------------------------

@interface GP_VideoPlayerViewController ()<GP_VideoPlayerControllerDelegate,GP_ServiceRequestDelegate>

/*
 *视频对象
 */
@property(nonatomic,strong) GP_Video *video;

//旋转锁定按钮响应函数
- (void)_rotateLockButtonHandler:(id)sender;

//隐藏旋转锁定按钮响应函数
- (void)_timeToHiddenRotateLockButton;

//收藏按钮
- (void)_collectionButtonHandle;

@property(nonatomic,strong,readonly) GP_ServiceRequest * serviceRequest;

//请求改变收藏视频状态
- (void)_requsetChangeCollectVideoStatus;

@end

//----------------------------------------------------------

@implementation GP_VideoPlayerViewController
{
    //视频背景视图
    UIView                    * _videoBGView;
    
    //视频播放器控制器
    GP_VideoPlayerController  * _videoPlayerController;
    
    //视频信息视图的背景视图
    UIView                    * _infoViewBGView;
    
    //视频信息控制器
    GP_VideoInfoView          * _videoInfoView;
    
    //下端工具栏
    UIToolbar                 * _bottomToolBar;
    
    //收藏按钮
    UIButton                  * _collectionButton;
    
    //旋转锁按钮
    UIButton                  * _rotateLockButton;
    
    //忽视设备方向改变，默认为NO
    BOOL _ignoreDeviceOrientationChange;
    BOOL _popWhenRotateEnd;
}

+ (UINavigationController *)videoPlayerViewControllerWithNavigationControllerForVideo:(GP_Video *)video
{
    return [[GP_MainNavigationController alloc] initWithRootViewController:[self videoPlayerViewControllerWithWithVideo:video]];
}

+ (instancetype)videoPlayerViewControllerWithWithVideo:(GP_Video *)video
{
    return [[self alloc] initWithVideo:video];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithVideo:nil];
}

- (id)initWithVideo:(GP_Video *)video
{
    if (video == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"video不能为nil"
                                        userInfo:nil];
    }
    
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _video = video;
        _ignoreDeviceOrientationChange = NO;
        _popWhenRotateEnd = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [_videoPlayerController stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.interactiveDismissEnable = YES;
    self.rotateEnable = YES;
    
    CGFloat viewWidth = screenSize().width;
    CGFloat videoViewHeight = AspectScaleLenght(180.f);
    
    //视频背景视图
    _videoBGView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, viewWidth, videoViewHeight + StatusBarHeight)];
    _videoBGView.clipsToBounds   = YES;
    _videoBGView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_videoBGView];
    
    //视频播放控制器
    _videoPlayerController = [[GP_VideoPlayerController alloc] init];
    _videoPlayerController.view.frame = CGRectMake(0.f, StatusBarHeight, viewWidth, videoViewHeight);
    _videoPlayerController.delegate = self;
    [_videoBGView addSubview:_videoPlayerController.view];
    
    
    //视频信息的背景
    _infoViewBGView = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(_videoBGView.frame), viewWidth, screenSize().height -  CGRectGetMaxY(_videoBGView.frame))];
    [self.view addSubview:_infoViewBGView];
    
    CGRect infoBGViewBounds = _infoViewBGView.bounds;
    
    //视频信息控制器
    _videoInfoView = [[GP_VideoInfoView alloc] init];
    _videoInfoView.frame = infoBGViewBounds;
    _videoInfoView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                      UIViewAutoresizingFlexibleWidth ;
    _videoInfoView.selectVideoDelegate = self;
    [_infoViewBGView addSubview:_videoInfoView];
    
    //工具栏
    _bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, CGRectGetHeight(infoBGViewBounds) - 44.f, CGRectGetWidth(infoBGViewBounds), 44.f)];
    [_bottomToolBar setBackgroundImage:resizableImageWithColor(defaultDarkBarColor)
                    forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    _bottomToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleTopMargin;
    _bottomToolBar.tintColor = [UIColor whiteColor];
    [_infoViewBGView addSubview:_bottomToolBar];
    
    //收藏按钮
    _collectionButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    [_collectionButton setShowsTouchWhenHighlighted:YES];
    [_collectionButton setImage:[ImageWithName(@"video_collection") imageWithGradientTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_collectionButton setImage:[ImageWithName(@"video_collection") imageWithTintColor:[self currentThemeColor]] forState:UIControlStateSelected];
    [_collectionButton addTarget:self action:@selector(_collectionButtonHandle) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * collectionBarButtonItme = [[UIBarButtonItem alloc] initWithCustomView:_collectionButton];
    
    //固定距离
    UIBarButtonItem * rightFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightFixedSpace.width = 10.f;
    
    //设置barItem
    [_bottomToolBar setItems:@[self.backBarButtonItem,
                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],collectionBarButtonItme,rightFixedSpace]];
    
    
    
    
    //旋转锁按钮
    _rotateLockButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 70.f, 70.f)];
    [_rotateLockButton setBackgroundColor:BlackColorWithAlpha(0.6f)];
    [_rotateLockButton setClipsToBounds:YES];
    [_rotateLockButton.layer setCornerRadius:5.f];
    [_rotateLockButton setHidden:YES];
    [_rotateLockButton setShowsTouchWhenHighlighted:YES];
    [_rotateLockButton setAdjustsImageWhenHighlighted:NO];
    [_rotateLockButton setImage:ImageWithName(@"rotate_unlock") forState:UIControlStateNormal];
    [_rotateLockButton addTarget:self action:@selector(_rotateLockButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rotateLockButton];
    
    //开始播放
    [self _playWithVideo:self.video];
}

- (void)didChangeThemeColor
{
    [_collectionButton setImage:[ImageWithName(@"video_collection") imageWithTintColor:[self currentThemeColor]] forState:UIControlStateSelected];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    _rotateLockButton.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    if (UIInterfaceOrientationIsPortrait(self.viewInterfaceOrientation)) {
        CGFloat y = CGRectGetMaxY(_videoBGView.frame);
        _infoViewBGView.frame = CGRectMake(0.f, y, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - y);
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_videoPlayerController pause];
}


- (NSString *)backHelpViewText
{
    return @"亲，从左边缘向右横滑可以返回哟";
}

- (BOOL)hasNavigationBar
{
    return NO;
}

//----------------------------------------------------------

- (void)_rotateLockButtonHandler:(id)sender
{
    if (_ignoreDeviceOrientationChange) {
        
        //解锁
        _ignoreDeviceOrientationChange = NO;
        [_rotateLockButton setImage:ImageWithName(@"rotate_unlock") forState:UIControlStateNormal];
        
        //尝试转动到当前方向
        [self attempRotateToDeviceOrientation];
        
    }else{
        
        //上锁
        _ignoreDeviceOrientationChange = YES;
        [_rotateLockButton setImage:ImageWithName(@"rotate_lock") forState:UIControlStateNormal];
    }
}

#define RegisterHiddenRotateLockButton()                                                              \
do{                                                                                                   \
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeToHiddenRotateLockButton) object:nil];                                                                                \
    [self performSelector:@selector(_timeToHiddenRotateLockButton) withObject:nil afterDelay:2.f];    \
}while(0)

- (void)_timeToHiddenRotateLockButton
{
    if (_rotateLockButton.highlighted) {//选中状态下不立即消失
        //重新注册旋转按钮消失事件
        RegisterHiddenRotateLockButton();
    }else{
        
        [UIView animateWithDuration:0.3f animations:^{
            _rotateLockButton.alpha = 0.1f;
        } completion:^(BOOL finished){
            _rotateLockButton.alpha = 1.f;
            _rotateLockButton.hidden = YES;
        }];
    }
}

//----------------------------------------------------------

- (NSUInteger)supportedOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)willAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(!UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ||
             !UIInterfaceOrientationIsLandscape(self.viewInterfaceOrientation)){
        
        if (!_rotateLockButton.isHidden && _ignoreDeviceOrientationChange) {
            //闪烁一下
            _rotateLockButton.alpha = 0.f;
            [UIView animateWithDuration:0.3f animations:^{
                _rotateLockButton.alpha = 1.0f;
            }];
        }else{
            //显示旋转锁按钮
            _rotateLockButton.hidden = NO;
        }
        
        //注册旋转按钮消失事件
        RegisterHiddenRotateLockButton();
        
        //按钮被选中即锁定旋转
        if(_ignoreDeviceOrientationChange){
            return NO;
        }
    }
    
    return YES;
}


- (BOOL)needAnimationsWhenRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation fromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        return YES;
    }
    
    return NO;
}

- (NSTimeInterval)animationsDurationWhenRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation fromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    return 0.8f;
}

- (void)viewWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [super viewWillRotateToInterfaceOrientation:toInterfaceOrientation];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        if (UIInterfaceOrientationIsPortrait(self.viewInterfaceOrientation)) {
            _infoViewBGView.hidden = YES;
       }
    }else {
        _infoViewBGView.hidden = NO;
   }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    if (GreaterThanIOS8System) {
        [[UIApplication sharedApplication] setStatusBarHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    }
#endif
    
}

- (void)viewDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super viewDidRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (UIInterfaceOrientationIsLandscape(self.viewInterfaceOrientation)){
        if(UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)){
            
            _videoBGView.frame = self.view.bounds;
            _videoPlayerController.view.frame = _videoBGView.bounds;
            
            //旋转结束后需要被POP则无需动作
            if (!_popWhenRotateEnd) {
                
               _videoPlayerController.view.transform = CGAffineTransformMakeScale(0, 0);
                  
                [UIView animateWithDuration:0.8f
                                      delay:0.f
                     usingSpringWithDamping:0.7f
                      initialSpringVelocity:0.f
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     
                                     _videoPlayerController.view.transform = CGAffineTransformIdentity;
                                     
                                 } completion:nil];

            }
        }
        
    }else{
        
        //设置大小
        CGFloat videoViewHeigth = AspectScaleLenght(180.f);
        
        _videoBGView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.bounds), videoViewHeigth + StatusBarHeight);
        _videoPlayerController.view.frame = CGRectMake(0.f, StatusBarHeight, CGRectGetWidth(_videoBGView.bounds), videoViewHeigth);
        
        
        //旋转结束后需要被POP则无需动作
        if (!_popWhenRotateEnd) {
            
            //弹性动画
            CGRect videoInfoViewFrame = _videoInfoView.frame;
            CGRect videoViewFrame     = _videoPlayerController.view.frame;
            
            _videoInfoView.frame = CGRectOffset(videoInfoViewFrame, - CGRectGetWidth(videoViewFrame),0.f);
            _videoPlayerController.view.frame = CGRectOffset(videoViewFrame, 0.f, CGRectGetHeight(videoViewFrame));
            
            [UIView animateWithDuration:0.8f
                                  delay:0.f
                 usingSpringWithDamping:0.7f
                  initialSpringVelocity:0.f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 _videoInfoView.frame = videoInfoViewFrame;
                                 _videoPlayerController.view.frame = videoViewFrame;
            
                             } completion:nil];
            
            //延迟向上移入
            _bottomToolBar.hidden = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _bottomToolBar.hidden = NO;
                playAnimated(_bottomToolBar,MoveAnimtedDirectionUp,0.2f,nil,nil);
            });
            
        }
    }
    
    
    BOOL interfaceOrientationIsLandscape = UIInterfaceOrientationIsLandscape(self.viewInterfaceOrientation);
    
    [self setNavigationInteractivePopEnable:!interfaceOrientationIsLandscape];
    
    //设置全屏
    [_videoPlayerController setFullScreen:interfaceOrientationIsLandscape];
    
    //自动锁定
    if (interfaceOrientationIsLandscape &&
        UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) &&
        !_ignoreDeviceOrientationChange &&
        [GP_SettingItemManager boolValueForItme:GP_SettingItemAutoLockScreenWhenFullScreen]) {
        [self _rotateLockButtonHandler:nil];
    }

    //需要被pop
    if (_popWhenRotateEnd) {
        [self backBarButtonHandle];
    }
}

//----------------------------------------------------------

- (void)object:(id)object didSelectVideo:(GP_Video *)video
{
    [self _playWithVideo:video];
}

- (void)_playWithVideo:(GP_Video *)video
{
    self.video = video;
    
    //取消收藏视频
    [_serviceRequest cancleService];
    _collectionButton.selected = NO;
    
    //更新
    [_videoPlayerController playWithVideo:video];
    [_videoInfoView refreshWithVideo:video];
    
}

//----------------------------------------------------------

- (void)videoPlayerControllerDidTapBack:(GP_VideoPlayerController *)videoPlayerController
{
    _popWhenRotateEnd = YES;
    self.viewInterfaceOrientation = UIInterfaceOrientationPortrait;
}

- (BOOL)videoPlayerController:(GP_VideoPlayerController *)videoPlayerController
         wantToFullScreenShow:(BOOL)fullScreenShow
{
    //调整视图旋转
    [self setViewInterfaceOrientation:fullScreenShow ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait];
    
    return YES;
}

//----------------------------------------------------------

- (void)_collectionButtonHandle
{
    if (![GP_UserManager currentUser]) {
        [[GP_MainTabBarController currentTopViewController] pushLoginViewControllerWithAnimated:YES];
//        [self pushLoginViewControllerWithAnimated:YES];
        showMessage(nil, @"亲,登陆后才能收藏。",nil);
    }else{
        [self _requsetChangeCollectVideoStatus];
    }
}

@synthesize serviceRequest = _serviceRequest;

- (GP_ServiceRequest *)serviceRequest
{
    if (!_serviceRequest) {
        _serviceRequest = [[GP_ServiceRequest alloc] init];
        _serviceRequest.delegate = self;
    }
    
    return _serviceRequest;
}

- (void)_requsetChangeCollectVideoStatus
{
    if (!self.serviceRequest.isRequesting) {
        
        if ([self currentNetworkStatus:YES]!= kNotReachable) {
            [self.serviceRequest startCollectVideoWithVideoID:_video.ID collect:!_collectionButton.isSelected];
        }
    }
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didFailRequestWithError:(NSError *)error
{
    showErrorMessage(self.view, error,_collectionButton.selected ? @"取消收藏视频失败":@"收藏视频失败");
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didSuccessRequestWithData:(id)data
{
    showSuccessMessage(self.view, _collectionButton.selected ? @"已取消收藏视频":@"收藏视频成功", nil);
    
    _collectionButton.selected = !_collectionButton.selected;
    
    //选择时动画
    if (_collectionButton.selected) {
        
        _collectionButton.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:0.4f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _collectionButton.transform = CGAffineTransformIdentity;;
                         } completion:nil];
        
    }
}

//----------------------------------------------------------

- (BOOL)interactiveDismissGestureShouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self.view];
    if (touchPoint.x <= 40.f * screenWidthScaleFactor()) {
        return YES;
    }
    
    return NO;
}

- (BOOL)interactiveDismissGestureShouldBeginWithTranslation:(CGPoint)translation
{
    return translation.x > 0 && fabs(translation.x) > fabs(translation.y);
}

- (float)interactiveDismissCompletePercentForTranslation:(CGPoint)translation
                                          withStartPoint:(CGPoint)startPoint
{
    float completePercent = atan(translation.x / (2 * CGRectGetWidth(self.view.bounds) + CGRectGetHeight(self.view.bounds) - startPoint.y)) / _2_A_TAN_1_4;
    
    return completePercent;
}


- (id<UIViewControllerAnimatedTransitioning>)viewControllerAnimatedTransitioningForPresented
{
    return [[GP_VideoPlayerTransting alloc] initWithType:PresentAnimatedTransitioningTypePresent];
}

- (id<UIViewControllerAnimatedTransitioning>)viewControllerAnimatedTransitioningForDismissed
{
    return [[GP_VideoPlayerTransting alloc] initWithType:PresentAnimatedTransitioningTypeDismiss];
}

//- (BOOL)interactiveDismissGestureShouldBeginWithTranslation:(CGPoint)translation
//{
//    
//}

//-(id<UIViewControllerAnimatedTransitioning>)navigationControllerAnimatedTransitioningForOperation:(UINavigationControllerOperation)operation
//{
//    return [[GP_VideoPlayerTransting alloc] initWithNavigationControllerOperation:operation];
//}

//- (float)navigationInteractivePopCompletePercentForTranslation:(CGPoint)translation  withStartPoint:(CGPoint)startPoint
//{
//    float completePercent = atan(translation.x / (2 * CGRectGetWidth(self.view.bounds) + CGRectGetHeight(self.view.bounds) - startPoint.y)) / _2_A_TAN_1_4;
//    
//    return completePercent;
//}

@end
