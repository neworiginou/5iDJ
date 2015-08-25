//
//  GP_PageLoadDelegateManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-8.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "GP_PageLoadProtocol.h"

//----------------------------------------------------------

@class GP_PageLoadDelegateManager;

//----------------------------------------------------------

@protocol GP_PageLoadDelegateManagerDelegate

- (void)pageLoadDelegateManager:(GP_PageLoadDelegateManager *)pageLoadDelegateManager
            needGetDataWithPage:(NSUInteger)Page;

@end

//----------------------------------------------------------

//数据获取的类型
typedef NS_ENUM(int, GetDataType) {
    GetDataTypeNone,
    GetDataTypeRefresh,
    GetDataTypeLoad
};

//----------------------------------------------------------

@interface GP_PageLoadDelegateManager : NSObject <GP_PageLoadDelegate>

//DESIGNATED_INITIALIZER
- (id)initWithPageLoadObject:(id<GP_PageLoadProtocol>)pageLoadObject
                    pageSize:(NSUInteger)pageSize NS_DESIGNATED_INITIALIZER;

//分页加载对象
@property(nonatomic,strong,readonly) id<GP_PageLoadProtocol> pageLoadObject;

//每一页的数目
@property(nonatomic,readonly) NSUInteger pageSize;

//当前数据获取的类型
@property(nonatomic,readonly) GetDataType currentGetDataType;

//代理
@property(nonatomic,weak) id<GP_PageLoadDelegateManagerDelegate> delegate;

//@property(nonatomic,readonly) BOOL isRefreshData;

- (void)refreshData:(BOOL)needRefreshControl;

- (void)loadData:(BOOL)needLoadControl;

- (void)endGetDataWithData:(NSArray *)datas totalDataCount:(NSUInteger)totalCount;

- (void)endRefreshDataWithDataStoreManager:(MyDataStoreManager *)dataStoreManager
                            totalDataCount:(NSUInteger)totalCount;
- (void)failGetData;

- (void)refreshWithData:(NSArray *)datas totalDataCount:(NSUInteger)totalCount;

- (void)refreshWithDataStoreManager:(MyDataStoreManager *)dataStoreManager
                     totalDataCount:(NSUInteger)totalCount;

@end
