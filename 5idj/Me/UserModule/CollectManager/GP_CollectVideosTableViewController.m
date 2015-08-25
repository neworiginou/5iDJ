//
//  GP_CollectVideosTableViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_CollectVideosTableViewController.h"
#import "GP_ServiceRequest.h"

//----------------------------------------------------------

@interface GP_CollectVideosTableViewController () < GP_ServiceRequestDelegate >

@property(nonatomic,strong,readonly) GP_ServiceRequest * serviceRequest;

@end

//----------------------------------------------------------

@implementation GP_CollectVideosTableViewController
{
    GP_Video * _waitDeleteVideo;
    
    NSIndexPath * _waitDeleteVideoIndexPath;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (self.topRefreshControl.refreshing || self.bottomLoadControl.refreshing) {
            showMessage(self.tableView, @"数据正在获取中,请稍后操作", nil);
        }
        
        [self _deleteDataAtIndexPath:indexPath];
    }
}


- (void)_deleteDataAtIndexPath:(NSIndexPath *)indexPath
{
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    showHUDWithMyActivityIndicatorView(self.tableView,self.tableView.tintColor,@"删除中,请稍后...");
    
    _waitDeleteVideoIndexPath = indexPath;
    _waitDeleteVideo = [self.dataStoreManager dataAtIndexPath:indexPath];
    
    //开始请求
    [self.serviceRequest startCollectVideoWithVideoID:_waitDeleteVideo.ID collect:NO];
}


- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didFailRequestWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    
    _waitDeleteVideo = nil;
    _waitDeleteVideoIndexPath = nil;
    showErrorMessage(self.tableView, error, @"删除失败");
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didSuccessRequestWithData:(id)data
{
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    
    if ([_waitDeleteVideo isEqual:[self.dataStoreManager dataAtIndexPath:_waitDeleteVideoIndexPath]]) {
        showSuccessMessage(self.tableView, @"删除成功", nil);
        
        //删除数据
        [self removeDataAtIndexPaths:@[_waitDeleteVideoIndexPath]];
        
        _waitDeleteVideo = nil;
        _waitDeleteVideoIndexPath = nil;
        
        id<GP_CollectVideosTableViewControllerDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(collectVideosTableViewControllerDidDeleteVideo:)){
            [delegate collectVideosTableViewControllerDidDeleteVideo:self];
        }
    }
}


@end
