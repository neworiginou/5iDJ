//
//  GP_SubChannelViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ChannelVideosViewController.h"
#import "GP_ChannelSearchViewController.h"

//----------------------------------------------------------

@implementation GP_ChannelVideosViewController
{
    GP_Channel * _channel;
}

- (id)initWithChannel:(GP_Channel *)channel
{
    self = [super init];
    
    if (self) {
        _channel = channel;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = _channel.title;
    
    //搜索按钮
    UIBarButtonItem * searchBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(_searchBarButtonItemHandle)];
    self.myNavigationItem.rightBarButtonItem = searchBarButtonItem;
    
    [self.transitionLayoutView addSubview:self.collectionView];
    
    self.multipleServicePageLoadController.loadHandleName  = @"获取视频";
    [self.multipleServicePageLoadController refreshData];
    
}

- (UIScrollView *)contentView
{
    return self.collectionView;
}
 
- (void)segmentedSelectedIndexChangeHandle
{
    self.collectionView.contentOffset = CGPointMake(0, - self.collectionView.contentInset.top);
   
    [super segmentedSelectedIndexChangeHandle];
}

- (BOOL)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController forPage:(NSUInteger)page
{
    if ([self currentNetworkStatus:YES] != kNotReachable) {
        
        [servicePageLoadController.serviceRequest startGetChannelVideosServiceWithID:_channel.ID sortType:[self currentSortType] currentPage:page pageSize:servicePageLoadController.pageSize];
        
        return YES;
    }else{
        return NO;
    }
}

- (NSArray *)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceSuccessWithData:(id)data totalCount:(NSUInteger *)totalCount
{
    *totalCount = [[data objectForKey:GP_GP_GET_CHANNEL_VIDEOS_TOTALSIZES] integerValue];
    
    if (*totalCount == 0) {
        [self.multipleServicePageLoadController.loadingIndicateView showNothingWiTitle:@"没有获取到任何视频"];
    }
    
    //调用super方法
    [super servicePageLoadControllerStartService:servicePageLoadController serviceSuccessWithData:data totalCount:totalCount];
    
    return data[GP_GP_GET_CHANNEL_VIDEOS_VIDOES];
}

- (void)_searchBarButtonItemHandle
{
    //
    [self presentViewController:[GP_ChannelSearchViewController navigationControllerWithChannel:_channel]
                       animated:YES
                     completion:nil];
}

@end
