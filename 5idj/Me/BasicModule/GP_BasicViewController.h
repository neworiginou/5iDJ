//
//  GP_BasicViewController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_Video.h"
#import "GP_MainNavigationController.h"

//----------------------------------------------------------

@interface GP_BasicViewController : MyBasicViewController
{
@private
    
    //contentView
    UIEdgeInsets          _contentViewInsetOffset;
    UITableView         * _tableView;
    UICollectionView    * _collectionView;
    BOOL                  _clearsSelectionOnViewWillAppear;
    MyRefreshControl    * _refreshControl;
    MyRefreshControl    * _loadControl;
    
    //NavigationBar
    UINavigationBar     * _navigationBar;
    UINavigationItem    * _myNavigationItem;
    BOOL                  _navigationBarHidden;
    
    
    //UpdateView
    BOOL                  _needUpdateViewWhenViewAppear;
    
    
    //SubViewController
    UIBarButtonItem     * _backBarButtonItem;
    MyViewControllerTransitioningDelegate * _transitioningDelegate;
    
    //Messgae
    MBProgressHUD       * _progressIndicatorView;
    
    
    //NetStatus
    BOOL                  _needObserveNetworkStatusChange;
    
    
    //fullScreenMode
    BOOL                  _fullScreenMode;
    BOOL                  _gestureChangeFullScreenModeEnable;
    UIView              * _statusBarBackgroundView;
    UIView              * _topExtentView;
    
    //theme
    BOOL                  _showThemeBackgroundImage;
    UIImageView         * _themeBackgroundImageView;
}

/*
 *构建导航控制器，该导航控制器的根视图为这个类及其子类
 */
+ (GP_MainNavigationController *)navigationController;

@end

//======================================
/**
 * 导航条
 */
//======================================
@interface GP_BasicViewController(NavigationBar)

//导航视图
@property(nonatomic,strong,readonly) UINavigationBar  * navigationBar;
@property(nonatomic,strong,readonly) UINavigationItem * myNavigationItem;

//默认返回YES
- (BOOL)hasNavigationBar;

//导航栏是否隐藏
@property(nonatomic,getter=isNavigationBarHidden) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;


@end

//======================================
/**
 * 视图更新
 */
//======================================
@interface GP_BasicViewController (UpdateView)

//发起更新视图
- (void)setNeedUpdateView;

//具体更新什么内容
- (void)updateView;

//更新数据
- (void)tryRefreshData;

@end


//======================================
/**
 * 内容视图
 */
//======================================
@interface GP_BasicViewController (ContentView) <
                                                 UITableViewDataSource,
                                                 UITableViewDelegate,
                                                 UICollectionViewDelegate,
                                                 UICollectionViewDataSource
                                                >
/**
 * 内容视图Inset的偏移
 */
@property(nonatomic) UIEdgeInsets contentViewInsetOffset;

/**
 * 获取内容视图的Inset，通过重载获取以达到预期值
 */
- (UIEdgeInsets)getContentViewInset;

/**
 * 表格视图的引用
 */
@property(nonatomic, strong, readonly) UITableView * tableView;

/**
 * 表格视图的风格,从子类覆盖以获得想要的风格，默认为UITableViewStylePlain
 */
- (UITableViewStyle)tableViewStyle;

/**
 * 网格视图的引用
 */
@property(nonatomic, strong, readonly)  UICollectionView * collectionView;

/**
 * 网格视图的布局,从子类覆盖以获得想要的布局，默认为UICollectionViewFlowLayout
 */
- (UICollectionViewLayout *)collectionViewLayout;

/**
 * 是否清空选择的TableView和CollectionView的单元当视图显示的时候，默认为YES
 */
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;


/**
 * 刷新控件的引用，请将其加入UIScrollView或者其子类视图中使用
 */
@property(nonatomic,strong,readonly) MyRefreshControl *refreshControl;

/*
 *刷新处理函数，不要手动调用，请从子类覆盖该函数以完成所需操作
 */
- (void)refreshHandle;

/*
 *结束刷新
 */
- (void)endRefresh:(BOOL)success;


/**
 * 加载控件的引用，请将其加入UIScrollView或者其子类视图中使用
 */
@property(nonatomic,strong,readonly) MyRefreshControl *loadControl;

/**
 * 加载处理函数，不要手动调用，请从子类覆盖该函数以完成所需操作
 */
- (void)loadHandle;

/**
 * 结束加载
 */
- (void)endload:(BOOL)success;


@end


#define SE_CHECK_UPDATE @"SE_CHECK_UPDATE"
#define SE_SCORE        @"SE_SCORE"


//======================================
/**
 * 子视图操作
 */
//======================================

@interface GP_BasicViewController (SubViewController) <
                                                        SelectVideoProtocol,
                                                        SelectBasicTitleAndImageProtocol,
                                                        MySettingTableControllerDelegate,
                                                        MySettingTableControllerDataSource
                                                      >

//返回按钮
@property(nonatomic,strong,readonly) UIBarButtonItem * backBarButtonItem;

//返回按钮的处理函数
- (void)backBarButtonHandle;

//子视图操作
- (void)pushSubViewController:(UIViewController *)subViewController animated:(BOOL)animated;
- (BOOL)popSubViewControllerAnimated:(BOOL)animated;

///*
// *弹入视频播放视图
// */
//- (void)pushVideoPlayerViewControllerForVideo:(GP_Video *)video;

/*
 *呈现视频播放视图
 */
- (void)presentVideoPlayerViewControllerForVideo:(GP_Video *)video;

/*
 *弹入登录视图
 */
- (void)pushLoginViewControllerWithAnimated:(BOOL)animated;

/**
 *  登录成功消息的处理方法
 */
- (void)logInSuccessHandle;

/**
 *  弹出设置页面
 */
- (void)pushSettingViewControllerWithAnimated:(BOOL)animated;

/**
 *  弹出设置主题页面
 */
- (void)pushSettingThemeViewControllerWithAnimated:(BOOL)animated;

@end


//======================================
/**
 * 消息通知
 */
//======================================
@interface GP_BasicViewController (Message)

//显示警告视图
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;

//活动指示器视图
@property(nonatomic,readonly,strong) MBProgressHUD * progressIndicatorView;

//显示进度指示视图
- (void)showProgressIndicatorView:(NSString *)title;

//隐藏进度指示视图
- (void)hideProgressIndicatorView;

////显示消息
//- (void)showMessageWithType:(TSMessageNotificationType)type duration:(NSTimeInterval)duration title:(NSString *)title subTitle:(NSString *)subTitle canBeDismissedByUser:(BOOL)dismissingEnabled;
//
//- (void)showErrorMessageWithTitle:(NSString *)title subTitle:(NSString *)subTitle;
//- (void)showSucceedMessageWithTitle:(NSString *)title subTitle:(NSString *)subTitle;

////隐藏消息
//- (void)hiddenMessage;

//显示状态栏通知视图
+ (void)showNotificationViewWithTitle:(NSString *)title automaticHidden:(BOOL)automaticHidden;

//更新通知视图
+ (void)updateNotificationViewWithTitle:(NSString *)title;

//隐藏通知视图
+ (void)hiddenNotificationView;

@end



//======================================
/**
 * 网络状态
 */
//======================================
@interface GP_BasicViewController (NetStatus)

//是否监听网络改变,默认为NO
@property(nonatomic) BOOL needObserveNetworkStatusChange;

//获取当前网络状况
- (NetworkStatus)currentNetworkStatus:(BOOL)showMSgWhenNoNetwork;

//网络状况改变通知
- (void)networkStatusChangeHandle;

@end


//======================================
/**
 * 全屏模式
 */
//======================================
@interface GP_BasicViewController (FullScreenMode)

//是否支持全屏模式，默认为NO
- (BOOL)isSupportFullScreenMode;

//全屏模式包括tabBar，默认为YES，当支持全屏模式且包括tabbar时不要覆盖tabbar隐藏相关的函数
- (BOOL)fullScreenModeIncludeTabBar;

//全屏模式包括上端的额外视图，默认为NO
- (BOOL)fullScreenModeIncludeTopExtentView;

//上端的额外视图高度
- (CGFloat)topExtentViewHeight;

//状态栏背景视图
@property(nonatomic,strong,readonly) UIView * statusBarBackgroundView;

//上端的额外视图
@property(nonatomic,strong,readonly) UIView * topExtentView;

//是否是全屏模式，默认为NO
@property(nonatomic,getter = isFullScreenMode) BOOL fullScreenMode;

//手势改变全屏模式，默认为NO
@property(nonatomic,getter = isGestureChangeFullScreenModeEnable) BOOL gestureChangeFullScreenModeEnable;

//设置全屏模式
- (void)setFullScreenMode:(BOOL)fullScreenMode
                 animated:(BOOL)animated
           animationBlock:(void(^)())animationBlock
            completeBlock:(void(^)())completeBlock;

//将要手势改变全屏模式
- (BOOL)willChangeFullScreenMode:(BOOL)fullScreenMode;

//手势改变全屏模式的动画
- (void)animationForChangeFullScreenMode:(BOOL)fullScreenMode;;

//已经改变全屏模式
- (void)didChangeFullScreenMode;

@end


//======================================
/**
 * 主题
 */
//======================================
@interface GP_BasicViewController (Theme)

//是否显示主题背景图片，默认为YES
@property(nonatomic) BOOL showThemeBackgroundImage;

@end
