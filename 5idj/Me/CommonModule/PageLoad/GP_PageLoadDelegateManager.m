//
//  GP_PageLoadDelegateManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-8.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//


//---------------------------------------------------

#import "GP_PageLoadDelegateManager.h"

//---------------------------------------------------

@implementation GP_PageLoadDelegateManager
{
    //数据总数
    NSUInteger _totalDataCount;
    //当前的页面
    NSUInteger _currentPage;
}

#pragma mark - life circle

- (id)init
{
    return [self initWithPageLoadObject:nil pageSize:0];
}


- (id)initWithPageLoadObject:(id<GP_PageLoadProtocol>)pageLoadObject pageSize:(NSUInteger)pageSize
{
    
    if (pageLoadObject == nil) {
        
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"pageLoadObject不能为nil"
                                     userInfo:nil];
    }
    
    self = [super init];
    
    if (self) {
        
        _pageLoadObject = pageLoadObject;
        _pageLoadObject.pageLoadDelegate = self;
        _pageSize       = pageSize;
        
        _currentGetDataType = GetDataTypeNone;
    }
    
    return self;
}

- (void)refreshData:(BOOL)needRefreshControl
{
    if (_currentGetDataType == GetDataTypeNone) {
        _currentGetDataType = GetDataTypeRefresh;
        
        if (needRefreshControl) {
            [self.pageLoadObject startRefreshData];
        }
        
        [self _startGetDataWithPage:0];
    }
}

- (void)loadData:(BOOL)needLoadControl
{
    if (_currentGetDataType == GetDataTypeNone
        && _totalDataCount > [self.pageLoadObject currentDataCount]) {
        
        _currentGetDataType = GetDataTypeLoad;
        
        if (needLoadControl) {
            [self.pageLoadObject startLoadData];
        }
        
        [self _startGetDataWithPage:_currentPage];
    }
}

- (void)_startGetDataWithPage:(NSUInteger)page
{
    id<GP_PageLoadDelegateManagerDelegate> __delegate = _delegate;
    ifRespondsSelector(__delegate, @selector(pageLoadDelegateManager:needGetDataWithPage:)){
        [__delegate pageLoadDelegateManager:self needGetDataWithPage:page];
    }else{
        [self failGetData];
    }
}

- (void)endGetDataWithData:(NSArray *)datas totalDataCount:(NSUInteger)totalCount
{
    if (_currentGetDataType != GetDataTypeNone) {
        
//        //检测
//        if ([self.pageLoadObject currentDataCount] + datas.count < totalCount) {
//            if (datas.count != _pageSize) {
//                @throw [NSException exceptionWithName:NSInvalidArgumentException
//                                               reason:@"未加载完毕情况下，加载数据应该等于一页数目"
//                                             userInfo:nil];
//            }
//        }
        
        _totalDataCount = totalCount;
        
        if (_currentGetDataType == GetDataTypeRefresh) {
            _currentPage = 1;
            [self.pageLoadObject endRefreshDatas:datas];
        }else{
            ++ _currentPage;
            [self.pageLoadObject endLoadDatas:datas];
        }
        
        _currentGetDataType = GetDataTypeNone;
    }
}

- (void)endRefreshDataWithDataStoreManager:(MyDataStoreManager *)dataStoreManager
                            totalDataCount:(NSUInteger)totalCount
{
    if (_currentGetDataType == GetDataTypeRefresh) {
        
        _totalDataCount = totalCount;
        _currentPage = 1;
        
        [self.pageLoadObject endRefreshDataStoreManager:dataStoreManager];
        _currentGetDataType = GetDataTypeNone;
    }
}

- (void)failGetData
{
    _currentGetDataType = GetDataTypeNone;
    [self.pageLoadObject failGetData];
}


- (void)refreshWithData:(NSArray *)datas totalDataCount:(NSUInteger)totalCount
{
//    //如果在获取数据
//    if (_currentGetDataType != GetDataTypeNone) {
//        [self failGetData];
//    }
//    
//    //不能整除情况下，必等于总数
//    if (datas.count / _pageSize * _pageSize != datas.count) {
//        
//        if (datas.count != totalCount) {
//            
//            @throw [NSException exceptionWithName:NSInvalidArgumentException
//                                           reason:@"数据对页面大小不整除情况下，必等于总数"
//                                         userInfo:nil];
//        }
//    }
//    
//    _totalDataCount = totalCount;
//    _currentPage    = (datas.count + _pageSize - 1) / _pageSize;
//    [self.pageLoadObject endRefreshDatas:datas];
    
    MyDataStoreManager * dataStoreManager = [[MyDataStoreManager alloc] init];
    [dataStoreManager addDatas:datas];
    
    [self refreshWithDataStoreManager:dataStoreManager totalDataCount:totalCount];
    
}

- (void)refreshWithDataStoreManager:(MyDataStoreManager *)dataStoreManager
                     totalDataCount:(NSUInteger)totalCount
{
    //如果在获取数据
    if (_currentGetDataType != GetDataTypeNone) {
        [self failGetData];
    }
    
//    //不能整除情况下，必等于总数
//    if (dataStoreManager.totalDatasCount / _pageSize * _pageSize != dataStoreManager.totalDatasCount) {
//        
//        if (dataStoreManager.totalDatasCount != totalCount) {
//            
//            @throw [NSException exceptionWithName:NSInvalidArgumentException
//                                           reason:@"数据对页面大小不整除情况下，必等于总数"
//                                         userInfo:nil];
//        }
//    }
//    
    _totalDataCount = totalCount;
    _currentPage    = (dataStoreManager.totalDatasCount + _pageSize - 1) / _pageSize;
    [self.pageLoadObject endRefreshDataStoreManager:dataStoreManager];
}

#pragma mark - page load delegate

- (BOOL)objectNeedBottomLoadControl:(id<GP_PageLoadProtocol>)object
{
    return YES;
}

- (BOOL)objectNeedTopRefreshControl:(id<GP_PageLoadProtocol>)object
{
    return YES;
}

- (void)objectDidRefreshData:(id<GP_PageLoadProtocol>)object
{
    [self refreshData:NO];
}

- (void)objectDidLoadData:(id<GP_PageLoadProtocol>)object
{
    [self loadData:NO];
}

- (NSUInteger)totalDataSizeForobject:(id<GP_PageLoadProtocol>)object
{
    return _totalDataCount;
}



@end
