//
//  GP_ServicePageLoadController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ServicePageLoadController.h"
#import "GP_MainTabBarController.h"
#import "GP_BasicViewController.h"

//----------------------------------------------------------

@implementation GP_ServicePageLoadController


@synthesize loadingIndicateView     = _loadingIndicateView;
@synthesize pageLoadObject          = _pageLoadObject;
@synthesize pageLoadDelegateManager = _pageLoadDelegateManager;
@synthesize serviceRequest          = _serviceRequest;

- (id)init
{
    return [self initWithPageSize:20];
}

- (id)initWithPageSize:(NSUInteger)pageSize
{
    self = [super init];
    
    if (self) {
        _pageSize = pageSize;
        _loadHandleName = @"获取数据";
    }
    
    return self;
}


- (id<GP_PageLoadProtocol>)pageLoadObject
{
    if (!_pageLoadObject) {
        
        id<GP_ServicePageLoadControllerDelegate> __delegate = _delegate;
        
        ifRespondsSelector(__delegate, @selector(servicePageLoadControllerNeedPageLoadObject:)){
            _pageLoadObject = [__delegate servicePageLoadControllerNeedPageLoadObject:self];
        }
        
        assert(_pageLoadObject);
        
    }
    
    return _pageLoadObject;
}

- (GP_PageLoadDelegateManager *)pageLoadDelegateManager
{
    if (!_pageLoadDelegateManager) {
        _pageLoadDelegateManager = [[GP_PageLoadDelegateManager alloc] initWithPageLoadObject:self.pageLoadObject pageSize:_pageSize];
        _pageLoadDelegateManager.delegate = self;
    }
    
    return _pageLoadDelegateManager;
}


- (GP_ServiceRequest *)serviceRequest
{
    if (!_serviceRequest) {
        _serviceRequest = [[GP_ServiceRequest alloc] init];
        _serviceRequest.delegate = self;
    }
    
    return _serviceRequest;
}

- (GP_LoadingIndicateView *)loadingIndicateView
{
    if (!_loadingIndicateView) {
        _loadingIndicateView = [[GP_LoadingIndicateView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, screenSize().height)];
        _loadingIndicateView.delegate = self;
    }
    
    return _loadingIndicateView;
}

- (void)pageLoadDelegateManager:(GP_PageLoadDelegateManager *)pageLoadDelegateManager needGetDataWithPage:(NSUInteger)Page
{
    if (!self.loadingIndicateView.isHidden && [MyNetReachability currentNetReachabilityStatus] == kNotReachable) {
        
        [self dataHandleFail];
        
        [self.loadingIndicateView showNoNetworkStatus];
        
    }else{
    
        BOOL bRet = NO;
        
        id<GP_ServicePageLoadControllerDelegate> __delegate = _delegate;
        ifRespondsSelector(__delegate, @selector(servicePageLoadControllerStartService:forPage:)){
            bRet = [__delegate servicePageLoadControllerStartService:self forPage:Page];
        }
        
        if(!bRet){
            [self dataHandleFail];
        }
    }
}

- (void)refreshData
{
    [self.serviceRequest cancleService];
    [self.pageLoadDelegateManager failGetData];
    
    [self.loadingIndicateView showLoadingStatusWithTitle:[NSString stringWithFormat:@"正在%@中,请稍等...",_loadHandleName] detailText:nil];
    
    //隐藏
    self.pageLoadObject.contentView.hidden = YES;
    
    [self.pageLoadDelegateManager refreshData:NO];
}

- (void)dataHandleFail
{
    [self.pageLoadDelegateManager failGetData];
    
    if (!self.loadingIndicateView.isHidden) {
        
        [self.loadingIndicateView showLoadingErrorStatusWithTitle:[NSString stringWithFormat:@"%@失败",_loadHandleName] detailText:@"点击页面重试"];
        
        //隐藏
        self.pageLoadObject.contentView.hidden = YES;
    }
}


- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didFailRequestWithError:(NSError *)error
{
    id<GP_ServicePageLoadControllerDelegate> __delegate = _delegate;
    ifRespondsSelector(__delegate, @selector(servicePageLoadControllerStartService:serviceFailWithError:)){
        [__delegate servicePageLoadControllerStartService:self serviceFailWithError:error];
    }
    
    [self dataHandleFail];
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didSuccessRequestWithData:(id)data
{
    NSUInteger totalCount = [[data objectForKey:GP_GP_TOTALSIZES] integerValue];
    NSArray    * datas    = nil;
    
    if (totalCount == 0 ) {
        [self.loadingIndicateView showNothingWiTitle:@"没有获取到任何数据"];
        self.pageLoadObject.contentView.hidden = YES;
    }
    
    id<GP_ServicePageLoadControllerDelegate> __delegate = _delegate;
    ifRespondsSelector(__delegate, @selector(servicePageLoadControllerStartService:serviceSuccessWithData:totalCount:)){
        datas = [__delegate servicePageLoadControllerStartService:self serviceSuccessWithData:data totalCount:&totalCount];
    }
    
    if (totalCount) {
        [self.loadingIndicateView hiddenView];
        self.pageLoadObject.contentView.hidden = NO;
    }
    
    [self.pageLoadDelegateManager endGetDataWithData:datas totalDataCount:totalCount];
}

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    switch (loadingIndicateView.contextTag) {
        case NoUserContextTag:
            [[GP_MainTabBarController currentTopViewController] pushLoginViewControllerWithAnimated:YES];
            break;
        
        case NoNetworkContextTag:
        case LoadingErrorContextTag:
        case NothingContextTag:
            [self refreshData];
            break;
            
        default:
            break;
    }
    
}


@end
