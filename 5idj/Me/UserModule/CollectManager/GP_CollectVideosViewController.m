//
//  GP_CollectVideosTableManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_CollectVideosViewController.h"
#import "GP_CollectViewPageLoadController.h"
#import "GP_CollectVideosTableViewController.h"

//----------------------------------------------------------

@interface GP_CollectVideosViewController () <
                                                GP_ServicePageLoadControllerDelegate,
                                                GP_CollectVideosTableViewControllerDelegate,
                                                MyLoadingIndicateViewDelegate,
                                                SelectVideoProtocol
                                            >

- (void)_currentUserChangeNotification:(NSNotification *)notification;

@end

//----------------------------------------------------------


@implementation GP_CollectVideosViewController
{
    //分页加载管理器
    GP_CollectViewPageLoadController    * _collectViewPageLoadController;
    
    GP_CollectVideosTableViewController  * _collectVideosTableViewController;
    
    //指示视图
    GP_LoadingIndicateView * _noVideosIndicateView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    
    if (self) {
        
        _view = [[UIView alloc] initWithFrame:frame];
        
        //背景图片
        _noVideosIndicateView = [[GP_LoadingIndicateView alloc] initWithFrame:frame];
        _noVideosIndicateView.offsetScale = CGPointMake(0.f, -0.1f);
        _noVideosIndicateView.delegate = self;
        _noVideosIndicateView.translatesAutoresizingMaskIntoConstraints = NO;
        [_view addSubview:_noVideosIndicateView];
        setAllEdgeConstraint(_noVideosIndicateView, _view, 0.f);
        
        //设置状态
        [_noVideosIndicateView showNothingWiTitle:@"暂无收藏的视频" detailText:@"点击页面刷新"];
        
        //tableview管理
        _collectVideosTableViewController = [[GP_CollectVideosTableViewController alloc] initWithTableViewFrame:frame];
        _collectVideosTableViewController.selectVideoDelegate = self;
        _collectVideosTableViewController.delegate = self;
        _tableView = _collectVideosTableViewController.tableView;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [_view addSubview:_tableView];
        setAllEdgeConstraint(_tableView, _view, 0);
        
        
        //分页加载管理
        _collectViewPageLoadController = [[GP_CollectViewPageLoadController alloc] initWithPageSize:20];
        _collectViewPageLoadController.delegate = self;
        
        //加载视图
        _collectViewPageLoadController.loadingIndicateView.offsetScale = CGPointMake(0.f, -0.1f);
        _collectViewPageLoadController.loadingIndicateView.translatesAutoresizingMaskIntoConstraints = NO;
        [_view addSubview:_collectViewPageLoadController.loadingIndicateView];
        setAllEdgeConstraint(_collectViewPageLoadController.loadingIndicateView, _view, 0);
        
        //监听用户改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentUserChangeNotification:) name:CurrentUserChangeNotification object:nil];
        
        //更新数据
        [self refresh];
        
    }
    
    return self;
}

- (void)_currentUserChangeNotification:(NSNotification *)notification
{
    [self refresh];
}

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    if (loadingIndicateView.contextTag == NothingContextTag) {
        [self refresh];
    }
}

- (void)refresh
{
    _noVideosIndicateView.hidden = YES;
    
    [_collectViewPageLoadController refreshData];
}

- (void)setRefreshControlHidden:(BOOL)hidden
{
    _collectVideosTableViewController.topRefreshControl.hidden = hidden;
}

- (id<GP_PageLoadProtocol>)servicePageLoadControllerNeedPageLoadObject:(GP_ServicePageLoadController *)servicePageLoadController
{
    return _collectVideosTableViewController;
}

- (BOOL)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController forPage:(NSUInteger)page
{
    if ([MyNetReachability currentNetReachabilityStatus] != kNotReachable) {
        
        //获取数据
        [servicePageLoadController.serviceRequest startGetCollectVideosWithCurrentPage:page pageSize:servicePageLoadController.pageSize];
        return YES;
        
    }else{
        showErrorMessage(_view, nil, @"当前无可用的网络");
        return NO;
    }
}

- (void)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceFailWithError:(NSError *)error
{
    if (servicePageLoadController.loadingIndicateView.isHidden) {
        showErrorMessage(_view, error, @"获取收藏视频失败");
    }
}

- (NSArray *)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceSuccessWithData:(id)data totalCount:(NSUInteger *)totalCount
{
    *totalCount = [[data objectForKey:GP_GP_GET_COLLECT_VIDEOS_TOTALSIZES] integerValue];
    
    //无记录
    if (*totalCount == 0) {
        [servicePageLoadController.loadingIndicateView hiddenView];
        _noVideosIndicateView.hidden = NO;
    }
    
    return data[GP_GP_GET_COLLECT_VIDEOS_VIDOES];
}

- (void)object:(id)object didSelectVideo:(GP_Video *)Video
{
    SafeSendSelectVideoMsg(self.selectVideoDelegate, Video);
}

- (void)collectVideosTableViewControllerDidDeleteVideo:(GP_CollectVideosTableViewController *)collectVideosTableViewController
{
    if (collectVideosTableViewController.dataStoreManager.totalDatasCount == 0) {
        _tableView.hidden = YES;
        _noVideosIndicateView.hidden = NO;
    }
}



@end
