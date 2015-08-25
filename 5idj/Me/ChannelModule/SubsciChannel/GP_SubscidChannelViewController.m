//
//  GP_EditChannelViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-12.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//


//----------------------------------------------------------

#import "GP_SubscidChannelViewController.h"
#import "GP_SubscidChannelCollectionViewManager.h"
#import "GP_ServicePageLoadController.h"


//----------------------------------------------------------

@interface GP_SubscidChannelViewController () <
                                                GP_ServicePageLoadControllerDelegate
                                              >

@end


//----------------------------------------------------------

@implementation GP_SubscidChannelViewController
{
    GP_ServicePageLoadController           * _servicePageLoadController;
}

//- (BOOL)isSupportFullScreenMode
//{
//    return YES;
//}

- (UICollectionViewLayout *)collectionViewLayout
{
    UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout *)[super collectionViewLayout];
    flowLayout.itemSize = [GP_SubscidChannelCell cellSize];
    
    return flowLayout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = @"订阅中心";
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    
    _servicePageLoadController = [[GP_ServicePageLoadController alloc] initWithPageSize:20];
    _servicePageLoadController.delegate = self;
    _servicePageLoadController.loadHandleName = @"获取频道";
    
    CGRect bounds = self.view.bounds;
    _servicePageLoadController.loadingIndicateView.frame = CGRectMake(0.f, 64.f, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - 64.f);
    _servicePageLoadController.loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_servicePageLoadController.loadingIndicateView];
    
    //开始获取数据
    [_servicePageLoadController refreshData];
}

- (id<GP_PageLoadProtocol>)servicePageLoadControllerNeedPageLoadObject:(GP_ServicePageLoadController *)servicePageLoadController
{
    return [[GP_SubscidChannelCollectionViewManager alloc] initWithBasicViewController:self];
}

- (BOOL)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController forPage:(NSUInteger)page
{
    if ([self currentNetworkStatus:YES] != kNotReachable) {
        [servicePageLoadController.serviceRequest startGetChannelsServiceWithCurrentPage:page andPageSize:servicePageLoadController.pageSize];
        return YES;
    }else{
        return NO;
    }
}

- (NSArray *)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceSuccessWithData:(id)data totalCount:(NSUInteger *)totalCount
{
    return [data objectForKey:GP_GP_GET_CHANNELS_CHANNELS];
}

- (void)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceFailWithError:(NSError *)error
{
    if (servicePageLoadController.loadingIndicateView.isHidden) {
        
        //显示错误消息
        showErrorMessage(self.view,error,@"获取频道失败");
    }
}


@end
