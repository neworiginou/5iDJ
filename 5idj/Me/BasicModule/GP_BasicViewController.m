//
//  GP_BasicViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicViewController.h"
#import "GP_VideoPlayerViewController.h"
#import "GP_LoginViewController.h"
#import "GP_SettingViewController.h"
#import "GP_ThemeSettingViewController.h"
#import "GP_BasicImageAndTitleCell.h"

//----------------------------------------------------------

@interface GP_BasicViewController ()<GP_LoginViewControllerDelegate>

@end

//----------------------------------------------------------

@implementation GP_BasicViewController

+ (GP_MainNavigationController *)navigationController
{
    return [[GP_MainNavigationController alloc] initWithRootViewController:[self viewController]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gestureChangeFullScreenModeEnable = YES;
    
    self.view.backgroundColor = defaultViewBackgrounpColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setObserveThemeColorChange:YES];
    [self setShowThemeBackgroundImage:YES];
}

- (void)didChangeThemeColor
{
    if (_statusBarBackgroundView) {
        _statusBarBackgroundView.backgroundColor = [[self currentThemeColor] colorWithAlphaComponent:0.7f];
    }
}

- (void)viewDidLayoutSubviews
{
    if ([self isSupportFullScreenMode] || _topExtentView) {
        
        if (self.topExtentView.superview != self.view) {
            [self.view addSubview:_topExtentView];
        }
    }
    
    if ([self isSupportFullScreenMode] || _statusBarBackgroundView){
        
        if (self.statusBarBackgroundView.superview != self.view) {
            [self.view addSubview:_statusBarBackgroundView];
        }
    }
    
    if ([self hasNavigationBar] && _navigationBar.superview != self.view) {
        
        //navigationBar
        self.navigationBar.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.bounds), GreaterThanIOS7System ? StatusBarHeight + NavigationBarHeight : NavigationBarHeight);
        self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                              UIViewAutoresizingFlexibleBottomMargin;
        
        [self.view addSubview:_navigationBar];
        
        //设置可见性
        if (self.isNavigationBarHidden) {
            _navigationBarHidden = NO;
            self.navigationBarHidden = YES;
        }
        
        
        [self.navigationBar pushNavigationItem:self.myNavigationItem animated:NO];

    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //取消所有已选择的视图单元
    if (_tableView && self.clearsSelectionOnViewWillAppear) {
        for (NSIndexPath *selectIndexPath in self.tableView.indexPathsForSelectedRows) {
            [self.tableView deselectRowAtIndexPath:selectIndexPath animated:NO];
        }
    }
    
    if (_needUpdateViewWhenViewAppear) {
        _needUpdateViewWhenViewAppear = NO;
        
        [self updateView];
    }
}

- (void)loginViewControllerDidSucceedLoginUser:(GP_LoginViewController *)loginViewController
{
    [self popSubViewControllerAnimated:YES];
    
    [self logInSuccessHandle];
}


- (BOOL)interactiveGestureShouldBeginWithPoint:(CGPoint)point
                                 withDirection:(ChangeTabBarItemDirection)diretion
{
    return !self.isNavigationInteractivePoping;
}

@end

//----------------------------------------------------------

NSString * NavigationBarBackgroundImageChangeNotification = @"NavigationBarBackgroundImageChangeNotification";

//----------------------------------------------------------

@implementation GP_BasicViewController(NavigationBar)


- (BOOL)hasNavigationBar
{
    return YES;
}


- (UINavigationBar *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[UINavigationBar alloc] init];
        _navigationBar.tintColor = [UIColor whiteColor];
        
        _navigationBar.titleTextAttributes = @{
                                               NSFontAttributeName : [UIFont boldSystemFontOfSize:20] ,
                                               NSForegroundColorAttributeName : [UIColor whiteColor]
                                               };
        
        //设置背景
        [_navigationBar setBackgroundImage:[self _navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
        
        //添加通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_navigationBarBackgroundImageChangeNotification:)
                                                     name:NavigationBarBackgroundImageChangeNotification
                                                   object:nil];
    }
    
    return _navigationBar;
}

- (void)_navigationBarBackgroundImageChangeNotification:(NSNotification *)notification
{
    //设置背景
    [self.navigationBar setBackgroundImage:[self _navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
}


- (UIImage *)_navigationBarBackgroundImage
{
    static UIImage * image = nil;
    
    if (!image) {
        
        image = resizableImageWithColor([[[GP_ThemeManager shareThemeManager] currentThemeColor] colorWithAlphaComponent:0.7f]);
        
        [[NSNotificationCenter defaultCenter] addObserverForName:CurrentThemeColorChangeNotification object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * notification){
                                                          
                                                          image = resizableImageWithColor([[[GP_ThemeManager shareThemeManager] currentThemeColor] colorWithAlphaComponent:0.7f]);
                                                          
                                                          //发送通知
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NavigationBarBackgroundImageChangeNotification object:nil];
                                                      }];
    }
    
    return image;
}

- (UINavigationItem *)myNavigationItem
{
    if (!_myNavigationItem) {
        _myNavigationItem = [[UINavigationItem alloc] initWithTitle:@""];
    }
    
    return _myNavigationItem;
}


- (BOOL)isNavigationBarHidden
{
    return [self hasNavigationBar] ? _navigationBarHidden : YES;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if ([self hasNavigationBar]) {
        
        if (_navigationBarHidden != hidden) {
            _navigationBarHidden = hidden;
            
            if (_navigationBar) {
                
                if (animated) {
                    
                    self.navigationBar.hidden = NO;
                    
                    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                                     animations:^{
                                         self.navigationBar.frame = CGRectOffset(self.navigationBar.frame, 0.f,  CGRectGetHeight(self.navigationBar.frame) * (hidden ? -1.f : 1.f));
                                     }
                                     completion:^(BOOL finished){
                        
                                         if (_navigationBarHidden == hidden) {
                                             self.navigationBar.hidden = hidden;
                                         }
                                     }];
                    
                }else{
                    
                    self.navigationBar.frame = CGRectOffset(self.navigationBar.frame, 0.f,  CGRectGetHeight(self.navigationBar.frame) * (hidden ? -1.f : 1.f));
                    self.navigationBar.hidden = hidden;
                }
            }
        }
    }
}


@end

//----------------------------------------------------------

@implementation GP_BasicViewController (UpdateView)

- (void)setNeedUpdateView
{
    if (![self isViewShowing]) {
        _needUpdateViewWhenViewAppear = YES;
    }else{
        [self updateView];
    }
}

- (void)updateView
{
    //do nothing
}

- (void)tryRefreshData
{
    //do noting
}

@end


//----------------------------------------------------------

@implementation GP_BasicViewController (ContentView)

- (void)setContentViewInsetOffset:(UIEdgeInsets)contentViewInsetOffset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentViewInsetOffset, contentViewInsetOffset)) {
        _contentViewInsetOffset = contentViewInsetOffset;
        
        [self _updateContentViewInset];
    }
}

- (UIEdgeInsets)contentViewInsetOffset
{
    return _contentViewInsetOffset;
}

- (void)_updateContentViewInset
{
    if (_tableView || _collectionView) {
        
        UIEdgeInsets contentViewInset = [self getContentViewInset];
        
        _tableView.contentInset = contentViewInset;
        _collectionView.contentInset = contentViewInset;
    }
}

- (UIEdgeInsets)getContentViewInset
{
    UIEdgeInsets contentInset = self.contentViewInsetOffset;
    
    
    if ([self isSupportFullScreenMode] || _topExtentView) {
        contentInset.top += (StatusBarHeight + [self topExtentViewHeight] + ([self isFullScreenMode] ? 0.f :NavigationBarHeight));
    }else{
        contentInset.top += (StatusBarHeight + NavigationBarHeight);
    }
    
    if (!self.gestureHiddenTabBarEnabled && !self.hiddenTabBarWhenViewDidAppear) {
        contentInset.bottom += 49.f;
    }
    
    return contentInset;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        
        //tableView
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:[self tableViewStyle]];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.contentInset = [self getContentViewInset];
    
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor  = defaultLineColor;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    
    return _tableView;
}

- (UITableViewStyle)tableViewStyle
{
    return UITableViewStylePlain;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[self collectionViewLayout]];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.contentInset = [self getContentViewInset];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        
    }
    
    return _collectionView;
}

- (UICollectionViewLayout *)collectionViewLayout
{
    UICollectionViewFlowLayout * collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    collectionViewFlowLayout.itemSize = [GP_BasicImageAndTitleCell cellSize];
//    collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(6.f, 6.f, 6.f, 6.f);
    collectionViewFlowLayout.minimumInteritemSpacing = 6.f;
//    collectionViewFlowLayout.minimumLineSpacing = 0.f;
    
    
    return collectionViewFlowLayout;
    
}

- (BOOL)clearsSelectionOnViewWillAppear
{
    return _clearsSelectionOnViewWillAppear;
}

- (void)setClearsSelectionOnViewWillAppear:(BOOL)clearsSelectionOnViewWillAppear
{
    _clearsSelectionOnViewWillAppear = clearsSelectionOnViewWillAppear;
}

- (MyRefreshControl *)refreshControl
{
    if (!_refreshControl) {
        
        //初始化
        _refreshControl = [[MyRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshHandle) forControlEvents:UIControlEventValueChanged];
        _refreshControl.textColor = defaultTitleTextColor;
        _refreshControl.hidden = self.isFullScreenMode;
        
    }
    
    return _refreshControl;
}

- (void)refreshHandle
{
    // do nothing
//    if (self.refreshControl.isRefreshing) {
//        
//        //3s后结束刷新
//        double delayInSeconds = 3.f;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [self endRefresh:YES];
//        });
//        
//    }
}

- (void)endRefresh:(BOOL)success
{
    [self.refreshControl endRefreshing];
}


- (MyRefreshControl *)loadControl
{
    if (!_loadControl) {
        _loadControl = [[MyRefreshControl alloc] initWithStyle:MyRefreshControlStyleBottom];
        [_loadControl addTarget:self action:@selector(loadHandle) forControlEvents:UIControlEventValueChanged];
        _loadControl.textColor = defaultTitleTextColor;
        _loadControl.alphaChangeWithScroll = NO;
    }
    
    return _loadControl;
}

- (void)loadHandle
{
    // do nothing
    
//    if (self.loadControl.isRefreshing) {
//        
//        //3s后结束
//        double delayInSeconds = 3.f;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [self endload:YES];
//        });
//        
//    }
}

- (void)endload:(BOOL)success
{
    [self.loadControl endRefreshing];
}


#pragma mark - table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - collectionView view datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma mark - super

- (BOOL)hiddenTabBarGestureShouldReceiveTouch:(UITouch *)touch
{
    if (_tableView) {
        for (UIGestureRecognizer * gesture in touch.gestureRecognizers) {
            if (gesture == _tableView.panGestureRecognizer) {
                return YES;
            }
        }
    }
    
    if (_collectionView) {
        for (UIGestureRecognizer * gesture in touch.gestureRecognizers) {
            if (gesture == _collectionView.panGestureRecognizer) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (CGFloat)minMoveValueForHiddenTabBar
{
    if ([_refreshControl isShowing]||
        [_refreshControl isRefreshing]||
        [_loadControl isShowing]||
        [_loadControl isRefreshing])
    {
        return MAXFLOAT;
    }
    
    return [super minMoveValueForHiddenTabBar];
}

@end

//----------------------------------------------------------

@implementation GP_BasicViewController (SubViewController)

- (UIBarButtonItem *)backBarButtonItem
{
    if (!_backBarButtonItem) {
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ImageWithName(@"back_button") style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonHandle)];
    }
    
    return _backBarButtonItem;
}

- (void)backBarButtonHandle
{
    if (![self popSubViewControllerAnimated:YES]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion
{
    if (viewControllerToPresent) {
        
        if (!_transitioningDelegate) {
            _transitioningDelegate = [[MyViewControllerTransitioningDelegate alloc] init];
        }

        [_transitioningDelegate presentViewController:viewControllerToPresent];
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
        
    }else{
        NSLog(@"错误的调用presentViewController");
    }
}


- (void)pushSubViewController:(UIViewController *)subViewController animated:(BOOL)animated
{
    if (self.navigationController && subViewController) {
        [self.navigationController pushViewController:subViewController animated:animated];
    }else{
        NSLog(@"错误的调用pushSubViewController");
    }
}

- (BOOL)popSubViewControllerAnimated:(BOOL)animated
{
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:animated];
        return YES;
    }else{
        return NO;
    }
}
//
//- (void)pushVideoPlayerViewControllerForVideo:(GP_Video *)video
//{
//    [self pushSubViewController:[GP_VideoPlayerViewController videoPlayerViewControllerWithWithVideo:video] animated:YES];
//}

- (void)presentVideoPlayerViewControllerForVideo:(GP_Video *)video
{
    [self presentViewController:[GP_VideoPlayerViewController videoPlayerViewControllerWithNavigationControllerForVideo:video] animated:YES completion:nil];
}


- (void)object:(id)object didSelectVideo:(GP_Video *)Video
{
    [self presentVideoPlayerViewControllerForVideo:Video];
}

- (void)object:(id)object didSelectBasicTitleAndImage:(GP_BasicTitleAndImage *)BasicTitleAndImage
{
    if ([BasicTitleAndImage isKindOfClass:[GP_Video class]]) {
        [self presentVideoPlayerViewControllerForVideo:(GP_Video *)BasicTitleAndImage];
    }
}

- (void)pushLoginViewControllerWithAnimated:(BOOL)animated
{
    GP_LoginViewController * loginViewController = [GP_LoginViewController viewController];
    loginViewController.delegate = self;
    
    [self pushSubViewController:loginViewController animated:animated];
}

- (void)logInSuccessHandle
{
    //登录成功的消息
    //    [self showSucceedMessageWithTitle:[NSString stringWithFormat:@"用户%@登录成功!",[GP_UserManager currentUser].userName] subTitle:nil];
}

- (void)pushSettingViewControllerWithAnimated:(BOOL)animated
{
    [self pushSubViewController:[GP_SettingViewController viewController] animated:animated];
}

- (void)pushSettingThemeViewControllerWithAnimated:(BOOL)animated
{
    [self pushSubViewController:[GP_ThemeSettingViewController viewController] animated:animated];
}

- (void)settingTableController:(MySettingTableController *)settingTableController
               sendSelectEvent:(NSString *)eventKey
{
    if ([eventKey isEqualToString:SE_SCORE]) {
        [GP_AppDelegate openInAppStore];
    }else if ([eventKey isEqualToString:SE_CHECK_UPDATE]){
        if ([self currentNetworkStatus:YES] != kNotReachable) {
            [GP_AppDelegate checkUpdate:YES];
        }
    }
}

- (void)settingTableController:(MySettingTableController *)settingTableController needShowViewController:(UIViewController *)viewController
{
    [self pushSubViewController:viewController animated:YES];
}


@end

//----------------------------------------------------------

@implementation GP_BasicViewController (Message)


- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"知道了"
                                               otherButtonTitles:nil];
    
    [alertView show];
}


- (MBProgressHUD *)progressIndicatorView
{
    if (!_progressIndicatorView) {
        
        MyActivityIndicatorView * activityIndicatorView = [[MyActivityIndicatorView alloc] initWithStyle:MyActivityIndicatorViewStyleIndeterminate];
        activityIndicatorView.twoStepAnimation = NO;
        _progressIndicatorView = [[MBProgressHUD alloc] initWithView:self.view];
        _progressIndicatorView.mode = MBProgressHUDModeCustomView;
        _progressIndicatorView.customView = activityIndicatorView;
        [self.view addSubview:_progressIndicatorView];
    }
    
    return _progressIndicatorView;
}

- (void)showProgressIndicatorView:(NSString *)title
{
    [self hideProgressIndicatorView];
    
    self.progressIndicatorView.labelText = title;
    
    [_progressIndicatorView show:NO];
    [(MyActivityIndicatorView *)_progressIndicatorView.customView startAnimating];
}

- (void)hideProgressIndicatorView
{
    [_progressIndicatorView hide:YES];
}

+ (void)showNotificationViewWithTitle:(NSString *)title automaticHidden:(BOOL)automaticHidden
{
    [MyStatusBarNotification showNotificationViewWithTitle:title automaticHidden:automaticHidden];
}

+ (void)updateNotificationViewWithTitle:(NSString *)title
{
    [MyStatusBarNotification updateNotificationViewWithTitle:title];
}

+ (void)hiddenNotificationView
{
    [MyStatusBarNotification hiddenNotificationView];
}

@end

//----------------------------------------------------------

@implementation GP_BasicViewController (NetStatus)


- (NetworkStatus)currentNetworkStatus:(BOOL)showMSgWhenNoNetwork
{
    NetworkStatus status = [MyNetReachability currentNetReachabilityStatus];
    
    if (showMSgWhenNoNetwork && status == kNotReachable) {
        showErrorMessage(self.view, nil, @"当前无可用网络");
    }
    
    return status;
}


- (BOOL)needObserveNetworkStatusChange
{
    return _needObserveNetworkStatusChange;
}


- (void)setNeedObserveNetworkStatusChange:(BOOL)needObserveNetworkStatusChange
{
    if (_needObserveNetworkStatusChange != needObserveNetworkStatusChange) {
        
        if (_needObserveNetworkStatusChange) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NetReachabilityChangedNotification object:nil];
        }
        
        _needObserveNetworkStatusChange = needObserveNetworkStatusChange;
        
        //添加通知
        if (_needObserveNetworkStatusChange) {
            
            //开始监听
            [MyNetReachability startNotifier];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_networkStatusChangeNotification:) name:NetReachabilityChangedNotification object:nil];
        }
    }
}

- (void)_networkStatusChangeNotification:(NSNotification *)notification
{
    [self networkStatusChangeHandle];
}

- (void)networkStatusChangeHandle
{
    //do noting
}

@end

//----------------------------------------------------------

@implementation GP_BasicViewController (FullScreenMode)

- (BOOL)isSupportFullScreenMode
{
    return NO;
}

- (BOOL)fullScreenModeIncludeTabBar
{
    return YES;
}

- (BOOL)fullScreenModeIncludeTopExtentView
{
    return NO;
}

- (CGFloat)topExtentViewHeight
{
    return 0.f;
}

- (UIView *)statusBarBackgroundView
{
    if (!_statusBarBackgroundView) {
        _statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, StatusBarHeight)];
        _statusBarBackgroundView.hidden = ![self isFullScreenMode];
        _statusBarBackgroundView.backgroundColor = [[self currentThemeColor] colorWithAlphaComponent:0.7f];
    }
    
    return _statusBarBackgroundView;
}

- (UIView *)topExtentView
{
    if (!_topExtentView) {
        
        _topExtentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, [self topExtentViewHeight] + 64.f)];
        
        if ([self isFullScreenMode]) {
            
            self.topExtentView.frame = CGRectMake(0.f, [self fullScreenModeIncludeTopExtentView] ? - NavigationBarHeight - [self topExtentViewHeight] : - NavigationBarHeight , screenSize().width, [self topExtentViewHeight] + NavigationBarHeight + StatusBarHeight);
        }
        
        if ([self isSupportFullScreenMode]) {
            _topExtentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.f, CGRectGetHeight(_topExtentView.bounds) - 3.f, screenSize().width, 3.f)].CGPath;
            _topExtentView.layer.shadowOffset = CGSizeMake(0.f, 1.f);
        }
    }
    
    return _topExtentView;
}

- (BOOL)isGestureChangeFullScreenModeEnable
{
    return _gestureChangeFullScreenModeEnable;
}

- (void)setGestureChangeFullScreenModeEnable:(BOOL)gestureChangeFullScreenModeEnable
{
    _gestureChangeFullScreenModeEnable = gestureChangeFullScreenModeEnable;
}

- (BOOL)isFullScreenMode
{
    return _fullScreenMode;
}

- (void)setFullScreenMode:(BOOL)fullScreenMode
{
    [self setFullScreenMode:fullScreenMode animated:NO animationBlock:nil completeBlock:nil];
}

- (void)setFullScreenMode:(BOOL)fullScreenMode
                 animated:(BOOL)animated
           animationBlock:(void (^)())animationBlock
            completeBlock:(void (^)())completeBlock
{
    
    if ([self isSupportFullScreenMode] && _fullScreenMode != fullScreenMode) {
        _fullScreenMode = fullScreenMode;
        
        _topExtentView.layer.shadowOpacity = _fullScreenMode ? 1.f : 0.f;
        _statusBarBackgroundView.hidden = !_fullScreenMode;
        _refreshControl.hidden = _fullScreenMode;
        
        [self setNavigationBarHidden:_fullScreenMode animated:animated];
        
        if ([self fullScreenModeIncludeTabBar]) {
            
            [self.myTabBarController setTabBarHidden:_fullScreenMode
                                            animated:animated
                                          animations:nil
                                          completion:nil];
        }
        
        if (animated) {
            
            if (_fullScreenMode) {
                _statusBarBackgroundView.frame  = CGRectMake(0.f, 0.f, screenSize().width, StatusBarHeight + NavigationBarHeight);
            }
            
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                             animations:^{
                       
                                 CGFloat yOffset = [self fullScreenModeIncludeTopExtentView] ? NavigationBarHeight + [self topExtentViewHeight] : NavigationBarHeight;
                                 
                                 if (_fullScreenMode){
                                     
                                     yOffset = - yOffset;
                                     
                                     _statusBarBackgroundView.frame = CGRectMake(0.f, 0.f, screenSize().width, StatusBarHeight);
                                 }
                                 
                                 UIEdgeInsets contentInset = UIEdgeInsetsZero;
                                 
                                 if (_tableView) {
                                     contentInset = _tableView.contentInset;
                                     contentInset.top += yOffset;
                                     _tableView.contentInset = contentInset;
                                 }
                                 
                                 if (_collectionView) {
                                     contentInset = _collectionView.contentInset;
                                     contentInset.top += yOffset;
                                     _collectionView.contentInset = contentInset;
                                 }
                                 
                                 
                                 CGPoint center = _topExtentView.center;
                                 center.y += yOffset;
                                 _topExtentView.center = center;
                                 
                                 
                                 if (animationBlock) {
                                     animationBlock();
                                 }
                             }
                             completion:^(BOOL finished){
                                 
                                 if (completeBlock) {
                                     completeBlock();
                                 }

                             }];
            
        }else{
            
            CGFloat yOffset = _fullScreenMode ? - NavigationBarHeight : NavigationBarHeight;
            
            UIEdgeInsets contentInset = _tableView.contentInset;
            contentInset.top += yOffset;
            _tableView.contentInset = contentInset;
            
            contentInset = _collectionView.contentInset;
            contentInset.top += yOffset;
            _collectionView.contentInset = contentInset;
            
            CGPoint center = _topExtentView.center;
            center.y += yOffset;
            _topExtentView.center = center;
            
            if (completeBlock) {
                completeBlock();
            }

        }
    }
}

- (BOOL)willChangeFullScreenMode:(BOOL)fullScreenMode
{
    return YES;
}

- (void)animationForChangeFullScreenMode:(BOOL)fullScreenMode
{
    if ([self fullScreenModeIncludeTabBar]) {
        [self animationWhenTabBarGestureHidden:fullScreenMode];
    }
    
}

- (void)didChangeFullScreenMode
{
    if ([self fullScreenModeIncludeTabBar]) {
        [self tabBarDidGestureHidden:[self isFullScreenMode]];
    }
}

- (BOOL)isHiddenTabBarWhenViewDidAppear
{
    //这种情况下全由全屏模式决定
    if ([self isSupportFullScreenMode] && [self fullScreenModeIncludeTabBar]) {
        return self.fullScreenMode;
    }
    
    return [super isHiddenTabBarWhenViewDidAppear];
}

- (BOOL)isGestureHiddenTabBarEnabled
{
    if ([self isSupportFullScreenMode]) {
        return self.isGestureChangeFullScreenModeEnable ||
                [super isGestureHiddenTabBarEnabled];
    }
    
    return [super isGestureHiddenTabBarEnabled];
}

- (void)gestureWantToHiddenTabBar:(BOOL)hidden
{
    if ([self isSupportFullScreenMode] && [self isGestureChangeFullScreenModeEnable]) {
        
        if ([self willChangeFullScreenMode:hidden]) {
            
            __weak typeof(self) weak_self = self;
            
            [self setFullScreenMode:hidden
                           animated:YES
                     animationBlock:^{
                         
                         [weak_self animationForChangeFullScreenMode:hidden];
                     }
                      completeBlock:^{
                          
                          [weak_self didChangeFullScreenMode];
                      }];
            
        }
    }
}


- (BOOL)tabBarWillGestureHidden:(BOOL)hidden
{
    if([self isSupportFullScreenMode] &&
       [self isGestureChangeFullScreenModeEnable]){
        return [super isGestureHiddenTabBarEnabled] && ![self fullScreenModeIncludeTabBar];;
    }
    
    return [super isGestureHiddenTabBarEnabled];
}

@end

//----------------------------------------------------------

@implementation GP_BasicViewController (Theme)

- (BOOL)showThemeBackgroundImage
{
    return _showThemeBackgroundImage;
}

- (void)setShowThemeBackgroundImage:(BOOL)showThemeBackgroundImage
{
    if (_showThemeBackgroundImage != showThemeBackgroundImage) {
        
        _showThemeBackgroundImage = showThemeBackgroundImage;
        
        //移除
        [_themeBackgroundImageView removeFromSuperview];
        _themeBackgroundImageView = nil;
        
        //观察
        [self setObserveThemeImageChange:_showThemeBackgroundImage];
        
        if (_showThemeBackgroundImage) {
            
            _themeBackgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            _themeBackgroundImageView.contentMode   = UIViewContentModeScaleAspectFill;
            _themeBackgroundImageView.clipsToBounds = YES;
            _themeBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
            UIViewAutoresizingFlexibleWidth;
            
            //设置图片
            _themeBackgroundImageView.image = [self currentThemeImage];
            
            //加入
            [self.view insertSubview:_themeBackgroundImageView atIndex:0];
        }
    }
}

- (void)didChangeThemeImage
{
    if (_themeBackgroundImageView) {
        
        _themeBackgroundImageView.image = [self currentThemeImage];
        
        //需要动画
        if (self.isViewShowing && _themeBackgroundImageView.superview) {
            
            CATransition * animation = [CATransition animation];
            [animation setDuration:1.f];
            [_themeBackgroundImageView.layer addAnimation:animation forKey:@"FadeAnimation"];
        }
    }
}


@end
