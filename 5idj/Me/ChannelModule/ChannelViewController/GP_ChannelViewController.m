//
//  GP_ChannelViewController.m
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-10.
//  Copyright (c) 2013年 hldw航. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ChannelViewController.h"
#import "GP_ChannelVideosViewController.h"
#import "GP_ImageAndTitleCollectionViewManager.h"
#import "GP_SearchViewController.h"
#import "GP_ChannelsManager.h"
#import "GP_LoadingIndicateView.h"
#import "GP_SubscidChannelViewController.h"
#import "GP_ChannelCollectionCell.h"

//----------------------------------------------------------

@interface GP_ChannelViewController () <
                                         UISearchBarDelegate,
                                         MyLoadingIndicateViewDelegate
                                        >

@property(nonatomic,strong,readonly) GP_LoadingIndicateView * loadingIndicateView;

@property(nonatomic,strong) UISearchBar *searchBar;

- (void)_didEditChannel;

- (void)_subscidChannelsChange:(NSNotification *)notification;

- (void)_checkChannelsStatusChange:(NSNotification *)notification;

@end

//----------------------------------------------------------

@implementation GP_ChannelViewController
{
    GP_ImageAndTitleCollectionViewManager * _collectionViewManager;
    
    BOOL _needUpdateViewWhenShow;
}

@synthesize loadingIndicateView = _loadingIndicateView;


+ (GP_MainNavigationController *)navigationController
{
    GP_MainNavigationController *navigationController = [super navigationController];
    
    navigationController.tabBarItem=[[UITabBarItem alloc] initWithTitle:nil image:ImageWithName(@"ti_channel") tag:1];
    
    return navigationController;
}


- (UICollectionViewLayout *)collectionViewLayout
{
    UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout *)[super collectionViewLayout];
    flowLayout.itemSize = [GP_ChannelCollectionCell cellSize];
    
    return flowLayout;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.myNavigationItem.title = @"游戏频道";
    
    //编辑按钮
    self.myNavigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"channel_edit"] style:UIBarButtonItemStylePlain target:self action:@selector(_didEditChannel)];
    
    //设置偏移
    self.contentViewInsetOffset = UIEdgeInsetsMake(50.f, 0.f, 0.f, 0.f);
    
   //搜索控件
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, -50.f, screenSize().width , 50.f)];
    _searchBar.searchBarStyle  = UISearchBarStyleMinimal;
    _searchBar.backgroundColor = defaultCellBackgroundColor;
    _searchBar.placeholder     = @"请输入要搜索的内容";
    _searchBar.delegate        = self;
    [self.collectionView addSubview:_searchBar];
    
    
    //设置管理器
    _collectionViewManager = [[GP_ImageAndTitleCollectionViewManager alloc] initWithBasicViewController:self cellClass:[GP_ChannelCollectionCell class]];
    _collectionViewManager.delegate = self;
    
    //添加视图
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    
    
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_subscidChannelsChange:)
                                                 name:SubscibedChannelsChangeNotifcation
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_checkChannelsStatusChange:)
                                                 name:CheckChannelsStatusChangeNotifcation
                                               object:nil];
    
    //更新视图
    [self setNeedUpdateView];
    
}

- (void)updateView
{
    NSArray * channelArray = [[GP_ChannelsManager defaultManager] subscibedChannels];
    
    [_collectionViewManager endRefreshDatas:channelArray];
    
    //无订阅
    if (channelArray.count == 0) {
        [self.loadingIndicateView setHidden:NO];
    }else{
        [_loadingIndicateView hiddenView];
    }
}

- (GP_LoadingIndicateView *)loadingIndicateView
{
    if (!_loadingIndicateView) {
        CGRect bounds = self.view.bounds;
        _loadingIndicateView = [[GP_LoadingIndicateView alloc] initWithFrame:CGRectMake(0.f, 114.f, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - 163.f)];
        _loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _loadingIndicateView.delegate = self;
        _loadingIndicateView.hidden = YES;
        [self.view addSubview:_loadingIndicateView];
        
        [_loadingIndicateView showNothingWiTitle:@"空空如也，没有订阅任何频道" detailText:@"点击立即订阅"];
        
    }
    
    return _loadingIndicateView;
}

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    if (loadingIndicateView.contextTag == NothingContextTag) {
        [self _didEditChannel];
    }
}

- (void)_subscidChannelsChange:(NSNotification *)notification
{
    [self setNeedUpdateView];
}

- (void)_checkChannelsStatusChange:(NSNotification *)notification
{
    CheckChannelsStatus _status = [[notification.userInfo objectForKey:CheckChannelsStatusUserinfoKey] integerValue];
    
    switch (_status) {
        case CheckChannelsStatusChecking:
            [self showProgressIndicatorView:@"正在核对频道信息中..."];
            break;
            
        case CheckChannelsStatusSuccess:
            [self hideProgressIndicatorView];
            showSuccessMessage(self.view, @"频道信息已核对。", nil);
            
            //更新视图
            [self setNeedUpdateView];
            
            break;
            
        case CheckChannelsStatusFail:
            [self hideProgressIndicatorView];
            showErrorMessage(self.view, nil, @"核对频道信息失败。");
            
            break;
    }
    
}

- (void)_didEditChannel
{
    [self pushSubViewController:[[GP_SubscidChannelViewController alloc] init] animated:YES];
}

- (void)object:(id)object didSelectBasicTitleAndImage:(GP_BasicTitleAndImage *)BasicTitleAndImage
{
    if ([BasicTitleAndImage isKindOfClass:[GP_Channel class]]) {
        
        [self pushSubViewController:[[GP_ChannelVideosViewController alloc] initWithChannel:(GP_Channel *)BasicTitleAndImage] animated:YES];
        
        //记录数据
        [GP_AppDelegate sendViewChannelEvent:(GP_Channel *)BasicTitleAndImage];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self pushSubViewController:[GP_SearchViewController viewController] animated:YES];
     
    return NO;
}

@end
