//
//  GP_RelatedVideosView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-27.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_RelatedVideosView.h"
#import "GP_VideoDetailTableController.h"
#import "GP_ServicePageLoadController.h"

//----------------------------------------------------------

@interface GP_RelatedVideosView() <
                                    SelectVideoProtocol,
                                    GP_ServicePageLoadControllerDelegate
                                  >

@end

//----------------------------------------------------------

@implementation GP_RelatedVideosView
{
    GP_VideoDetailTableController * _videoDetailTableController;
    
    GP_ServicePageLoadController * _relatedVideosPageLoadController;
    
    GP_Video * _video;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //视图详情列表
        _videoDetailTableController = [[GP_VideoDetailTableController alloc] initWithTableViewFrame:self.bounds];
        _videoDetailTableController.selectVideoDelegate = self;
        _videoDetailTableController.tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 44.f, 0.f);
        _videoDetailTableController.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_videoDetailTableController.tableView];
        
        //分页加载
        _relatedVideosPageLoadController = [[GP_ServicePageLoadController alloc] initWithPageSize:20];
        _relatedVideosPageLoadController.loadHandleName = @"获取视频";
        _relatedVideosPageLoadController.delegate = self;
        _relatedVideosPageLoadController.loadingIndicateView.frame = self.bounds;
        _relatedVideosPageLoadController.loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                                                                UIViewAutoresizingFlexibleWidth;
        [self addSubview:_relatedVideosPageLoadController.loadingIndicateView];
    }
    
    return self;
}


- (void)refreshWithVideo:(GP_Video *)video
{
    _video = video;
    
    _videoDetailTableController.tableView.contentOffset = CGPointZero;
    [_relatedVideosPageLoadController refreshData];
}

- (id<GP_PageLoadProtocol>)servicePageLoadControllerNeedPageLoadObject:(GP_ServicePageLoadController *)servicePageLoadController
{
    return _videoDetailTableController;
}

- (BOOL)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController forPage:(NSUInteger)page
{
    if ([MyNetReachability currentNetReachabilityStatus] != kNotReachable) {
        
        [servicePageLoadController.serviceRequest startGetAboutVideosWithVideoID:_video.ID currentPage:page pageSize:servicePageLoadController.pageSize];
        
        return YES;
    }else{
        showErrorMessage(self, nil, @"无可用的网络");
        return NO;
    }
}

- (void)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceFailWithError:(NSError *)error
{
    showErrorMessage(self,error,@"获取视频数据失败");
}

- (NSArray *)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceSuccessWithData:(id)data totalCount:(NSUInteger *)totalCount
{
//    _videoDetailTableController.tableView.alpha = 1.f;
  
//#warning
    
//    NSArray * videos = data[GP_GP_GET_ABOUT_VIDEOS_VIDOES];
    
//    *totalCount = videos.count;
    
    return data[GP_GP_GET_ABOUT_VIDEOS_VIDOES];
}

- (void)object:(id)object didSelectVideo:(GP_Video *)Video
{
    SafeSendSelectVideoMsg(self.selectVideoDelegate, Video);
}

@end
