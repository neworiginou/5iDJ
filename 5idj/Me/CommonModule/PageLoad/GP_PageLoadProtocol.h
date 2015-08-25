//
//  GP_PageLoadProtocol.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-7.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

@protocol GP_PageLoadDelegate;

//----------------------------------------------------------

//分页加载协议
@protocol GP_PageLoadProtocol < MyDataStoreManagerDelegate >

//分页加载代理
@property(nonatomic,weak) id<GP_PageLoadDelegate> pageLoadDelegate;

//当前数据数目
@property(nonatomic,readonly) NSUInteger currentDataCount;

//开始更新数据
- (void)startRefreshData;

//结束更新数据
- (void)endRefreshDatas:(NSArray *)datas;

//结束更新数据
- (void)endRefreshDataStoreManager:(MyDataStoreManager *)dataStoreManager;

//开始加载数据
- (void)startLoadData;

//结束加载数据
- (void)endLoadDatas:(NSArray *)datas;

//数据操作失败
- (void)failGetData;

//内容视图
@property(nonatomic,strong,readonly) UIView * contentView;

@end

//----------------------------------------------------------

@protocol GP_PageLoadDelegate

@optional

//是否需要刷新控件
- (BOOL)objectNeedTopRefreshControl:(id<GP_PageLoadProtocol>)object;

//是否需要加载控件
- (BOOL)objectNeedBottomLoadControl:(id<GP_PageLoadProtocol>)object;

//触发了刷新数据控件
- (void)objectDidRefreshData:(id<GP_PageLoadProtocol>)object;

//触发了加载数据控件
- (void)objectDidLoadData:(id<GP_PageLoadProtocol>)object;

@required

//数据总数
- (NSUInteger)totalDataSizeForobject:(id<GP_PageLoadProtocol>)object;

@end
