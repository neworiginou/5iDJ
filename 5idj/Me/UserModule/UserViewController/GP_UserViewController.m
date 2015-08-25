//
//  GP_UserViewController.m
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-10.
//  Copyright (c) 2013年 hldw航. All rights reserved.
//

//----------------------------------------------------------

#import "GP_UserViewController.h"
#import "GP_UserInfoView.h"
#import "GP_PlayHistoryView.h"
#import "GP_CollectVideosViewController.h"

//----------------------------------------------------------
@interface GP_UserViewController()

//全屏显示
@property(nonatomic) BOOL fullScreenShow;

//登录的点击
- (void)_loginTapGestureHandle;


//手势识别
- (void)_fullScreenSwipeGestureHandle:(UISwipeGestureRecognizer *)swipeGestureRecognizer;
- (void)_tableViewPanGestureHandle:(UIPanGestureRecognizer *)panGestureRecognizer;
//
- (void)_segmentedControlHandle:(MySegmentedControl *)segmentedControl;

//显示的页面索引
@property(nonatomic) NSInteger showingContentViewIndex;

//播放记录
@property(nonatomic,strong,readonly) GP_PlayHistoryView * playHistoryView;

//收藏的视频
@property(nonatomic,strong,readonly) GP_CollectVideosViewController * collectVideosViewController;

//获取索引为index的视图
- (UIView *)_bottomContentViewForIndex:(NSUInteger)index;

@end

//----------------------------------------------------------

@implementation GP_UserViewController
{
  //顶端用户界面背景视图
    UIView            * _topBGView;
    
    //上端背景图片视图
    UIImageView       * _topBGImageView;
    
    //用户信息视图
    GP_UserInfoView   * _userInfoView;
    
    //
    MySegmentedControl * _segmentedControl;
    
    //下端背景视图
    UIView            * _bottomBGView;
}

@synthesize playHistoryView  = _playHistoryView;
@synthesize collectVideosViewController = _collectVideosViewController;


+ (GP_MainNavigationController *)navigationController
{
    GP_MainNavigationController *navigationController = [super navigationController];
    
    navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:ImageWithName(@"ti_user") tag:3];
    
    return navigationController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.myNavigationItem.title=@"个人";
    
    self.statusBarBackgroundView.backgroundColor = BlackColorWithAlpha(0.6f);
    
    //-----------top视图---------------
    
    CGFloat viewWidth = screenSize().width;
    CGFloat userInfoViewHeight = AspectScaleLenght(135.f);
    
    //上端背景视图
    _topBGView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, viewWidth,userInfoViewHeight + StatusBarHeight)];
    [self.view addSubview:_topBGView];
    
    //上端背景视图
    _topBGImageView = [[UIImageView alloc] initWithFrame:_topBGView.bounds];
    _topBGImageView.image = [ImageWithName(@"userMouduleBG.png") imageWithGradientTintColor:[self.currentThemeColor colorWithAlphaComponent:.9f]];
    [_topBGView addSubview:_topBGImageView];
    
    //用户信息视图
    _userInfoView = [[GP_UserInfoView alloc] initWithFrame:CGRectMake(0.f, StatusBarHeight, viewWidth, userInfoViewHeight)];
    [_topBGView addSubview:_userInfoView];
    
    //按钮条
    _segmentedControl = [[MySegmentedControl alloc] initWithFrame:CGRectMake(0.f, CGRectGetHeight(_topBGView.frame) - AspectScaleLenght(39.f), viewWidth, AspectScaleLenght(39.f))];
    _segmentedControl.sectionImages = @[ImageWithName(@"user_play_record"),ImageWithName(@"user_favorite")];
    _segmentedControl.sectionSelectedImages = _segmentedControl.sectionImages;
    _segmentedControl.sectionTitles = @[@"播放记录",@"个人收藏"];
    _segmentedControl.textColor = [UIColor whiteColor];
    _segmentedControl.separatorLineColor = [UIColor whiteColor];
    _segmentedControl.selectedTextColor  = [UIColor whiteColor];
    _segmentedControl.selectedIndicatorLineInsetScale = UIEdgeInsetsMake(0.f, 0.15f, 0.f, 0.15f);
    _segmentedControl.backgroundColor = self.statusBarBackgroundView.backgroundColor;
    [_segmentedControl addTarget:self action:@selector(_segmentedControlHandle:) forControlEvents:UIControlEventValueChanged];
    [_topBGView addSubview:_segmentedControl];
    
    //登录点击手势
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_loginTapGestureHandle)];
    [_topBGView addGestureRecognizer:tapGestureRecognizer];
    
    
    //-----------bottom视图---------------
    
    //下端背景视图
    _bottomBGView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topBGView.frame), viewWidth, screenSize().height - CGRectGetHeight(_segmentedControl.bounds) - StatusBarHeight)];
    [self.view addSubview:_bottomBGView];
    
    //显示第一个视图
    _showingContentViewIndex = 0;
    _segmentedControl.selectedSectionIndex = _showingContentViewIndex;
    [_bottomBGView addSubview:[self _bottomContentViewForIndex:_showingContentViewIndex]];
    
    //加入手势识别
    UISwipeGestureRecognizer * upGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_fullScreenSwipeGestureHandle:)];
    upGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [_bottomBGView addGestureRecognizer:upGestureRecognizer];
    UISwipeGestureRecognizer * downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_fullScreenSwipeGestureHandle:)];
    downGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [_bottomBGView addGestureRecognizer:downGestureRecognizer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.fullScreenShow) {
        _bottomBGView.frame = CGRectMake(0.f, CGRectGetHeight(_segmentedControl.bounds) + StatusBarHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_segmentedControl.bounds) -  StatusBarHeight);
    }else{
        _bottomBGView.frame = CGRectMake(0.f,CGRectGetHeight(_topBGView.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) -  CGRectGetHeight(_segmentedControl.bounds) -  StatusBarHeight);
    }
}

- (BOOL)hasNavigationBar
{
    return NO;
}


- (void)didChangeThemeColor
{
    _topBGImageView.image = [ImageWithName(@"userMouduleBG.png") imageWithGradientTintColor:[[self currentThemeColor] colorWithAlphaComponent:.9f]];
}

- (GP_PlayHistoryView *)playHistoryView
{
    if (!_playHistoryView) {
        
        _playHistoryView = [[GP_PlayHistoryView alloc] initWithFrame:_bottomBGView.bounds];
        _playHistoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _playHistoryView.selectVideoDelegate = self;
        _playHistoryView.needShowBottomToolBar = YES;
        
        //监听滑动手势
        [_playHistoryView.tableView.panGestureRecognizer addTarget:self action:@selector(_tableViewPanGestureHandle:)];
        
    }
    
    return _playHistoryView;
}

- (GP_CollectVideosViewController *)collectVideosViewController
{
    if (!_collectVideosViewController) {
        _collectVideosViewController = [[GP_CollectVideosViewController alloc] initWithFrame:_bottomBGView.bounds];
        _collectVideosViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectVideosViewController.selectVideoDelegate = self;
        
        //监听滑动手势
        [_collectVideosViewController.tableView.panGestureRecognizer addTarget:self action:@selector(_tableViewPanGestureHandle:)];
        
        //设置隐藏与否
        [_collectVideosViewController setRefreshControlHidden:self.fullScreenShow];
        
    }
    
    return _collectVideosViewController;
}


- (UIView *)_bottomContentViewForIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            return self.playHistoryView;
            break;
            
        default:
            return self.collectVideosViewController.view;
            break;
    }
}

- (void)_segmentedControlHandle:(MySegmentedControl *)segmentedControl
{
    self.showingContentViewIndex = segmentedControl.selectedSectionIndex;
}

- (void)setShowingContentViewIndex:(NSInteger)showingContentViewIndex
{
    if (_showingContentViewIndex != showingContentViewIndex) {
        
        UIView * fromView = [self _bottomContentViewForIndex:_showingContentViewIndex];
        UIView * toView   = [self _bottomContentViewForIndex:showingContentViewIndex];
        
        CGRect bounds  = _bottomBGView.bounds;
        CGFloat offset = (showingContentViewIndex > _showingContentViewIndex) ? CGRectGetWidth(bounds) : - CGRectGetWidth(bounds);
        
        toView.frame = CGRectOffset(bounds, offset, 0.f);
        [_bottomBGView addSubview:toView];
        
        [UIView animateWithDuration:0.8f
                              delay:0.f
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            
            toView.frame   = bounds;
            fromView.frame = CGRectOffset(bounds, -offset, 0.f);
            
        } completion:^(BOOL finished){
            
            if ([self _bottomContentViewForIndex:_showingContentViewIndex] != fromView) {
                [fromView removeFromSuperview];
            }
        }];
        
        _showingContentViewIndex = showingContentViewIndex;
    }
}


- (void)_loginTapGestureHandle
{
    if (![GP_UserManager currentUser]) {
        
        if ([GP_UserManager isAutoLogining]) {
            [self showAlertViewWithTitle:@"提示" message:@"正在自动登录中，请稍等..."];
        }else{
            [self pushLoginViewControllerWithAnimated:YES];
        }
    }
}

- (void)_tableViewPanGestureHandle:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if ([panGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        
        UIScrollView * scrollView = (UIScrollView *)panGestureRecognizer.view;
        
        CGFloat offsetY = scrollView.contentOffset.y + scrollView.contentInset.top;
        
        if (_fullScreenShow) {
            //非全屏
            if (offsetY < - 60.f){
                self.fullScreenShow = NO;
            }
        }else{
            //全屏
            if (offsetY > 45.f) {
                self.fullScreenShow = YES;
            }else if (offsetY >= 0.f){
                [_collectVideosViewController setRefreshControlHidden:NO];
            }
        }
    }
}

- (void)setFullScreenShow:(BOOL)fullScreenShow
{
    if (_fullScreenShow != fullScreenShow) {
        _fullScreenShow = fullScreenShow;
        
        if (_fullScreenShow) {
            [_collectVideosViewController setRefreshControlHidden:YES];
        }
        
        self.hiddenTabBarWhenViewDidAppear = _fullScreenShow;
        self.statusBarBackgroundView.hidden = YES;
        
        [self.myTabBarController setTabBarHidden:_fullScreenShow animated:YES
                                      animations:^{
                                          
                                          CGFloat offset = CGRectGetHeight(_userInfoView.bounds) - CGRectGetHeight(_segmentedControl.bounds);
                                          
                                          if (_fullScreenShow) {
                                              offset = - offset;
                                              _userInfoView.alpha = 0.f;
                                          }else{
                                              _userInfoView.alpha = 1.f;
                                          }
                                          
                                          _topBGView.frame = CGRectOffset(_topBGView.frame, 0.f, offset);
                                          _bottomBGView.frame = CGRectOffset(_bottomBGView.frame, 0.f, offset);
                                          
                                      } completion:^{
                                          
                                          if (_fullScreenShow) {
                                              
                                              self.statusBarBackgroundView.hidden = NO;
                                              
                                              self.statusBarBackgroundView.alpha = 0.f;
                                              [UIView animateWithDuration:0.2f animations:^{
                                                  self.statusBarBackgroundView.alpha = 1.f;
                                              }];
                                          }
                                          
                                      }];
        
    }
}



- (void)_fullScreenSwipeGestureHandle:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    switch (swipeGestureRecognizer.direction) {
            
        case UISwipeGestureRecognizerDirectionUp:
            self.fullScreenShow = YES;
            break;
            
        case UISwipeGestureRecognizerDirectionDown:
            self.fullScreenShow = NO;
            break;
            
        default:
            break;
    }
    
}


- (BOOL)interactiveGestureShouldBeginWithPoint:(CGPoint)point withDirection:(ChangeTabBarItemDirection)diretion
{
    if ([super interactiveGestureShouldBeginWithPoint:point withDirection:diretion]) {
        
        return !_fullScreenShow;
    }
    
    return NO;
}

////设置页面
//- (void)_settingButtonHandle
//{
//    [self pushSettingViewControllerWithAnimated:YES];
//}


@end
