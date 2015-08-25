//
//  GP_ServicePageLoadController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "GP_LoadingIndicateView.h"
#import "GP_PageLoadDelegateManager.h"
#import "GP_PageLoadProtocol.h"
#import "GP_ServiceRequest.h"

//----------------------------------------------------------

@protocol GP_ServiceLoadProtocol <
                                    MyLoadingIndicateViewDelegate,
                                    GP_ServiceRequestDelegate
                                 >

@property(nonatomic,strong,readonly) GP_LoadingIndicateView * loadingIndicateView;

@property(nonatomic,strong,readonly) GP_ServiceRequest      * serviceRequest;

- (void)refreshData;

- (void)dataHandleFail;

@end

//----------------------------------------------------------

@protocol GP_ServicePageLoadProtocol <
                                        GP_ServiceLoadProtocol,
                                        GP_PageLoadDelegateManagerDelegate
                                      >

@property(nonatomic,strong,readonly) id<GP_PageLoadProtocol>      pageLoadObject;

@property(nonatomic,strong,readonly) GP_PageLoadDelegateManager * pageLoadDelegateManager;

@end

//----------------------------------------------------------

@protocol GP_ServicePageLoadControllerDelegate;

//----------------------------------------------------------

@interface GP_ServicePageLoadController : NSObject <GP_ServicePageLoadProtocol>

- (id)initWithPageSize:(NSUInteger)pageSize;

@property(nonatomic,readonly) NSUInteger pageSize;


//加载操作的名称，用于加载视图的显示
@property(nonatomic,strong) NSString * loadHandleName;

//代理
@property(nonatomic,weak) id<GP_ServicePageLoadControllerDelegate> delegate;

@end

//----------------------------------------------------------

@protocol GP_ServicePageLoadControllerDelegate

@required

- (id<GP_PageLoadProtocol>)servicePageLoadControllerNeedPageLoadObject:(GP_ServicePageLoadController *)servicePageLoadController;

//需要开始获取page页面的数据,返回YES开始成功，NO则失败
- (BOOL)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController forPage:(NSUInteger)page;

@optional

//获取数据成功,返回装换后的数据
- (NSArray *)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceSuccessWithData:(id)data totalCount:(NSUInteger *)totalCount;

//获取数据失败
- (void)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceFailWithError:(NSError *)error;


@end



