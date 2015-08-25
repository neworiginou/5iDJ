//
//  GP_MultipleServicePageLoadController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_MultipleServicePageLoadController.h"

//----------------------------------------------------------

@implementation GP_MultipleServicePageLoadController
{
    NSMutableArray * _dataArray;
    NSMutableArray * _totalSizeArray;
}

- (id)initWithPageSize:(NSUInteger)pageSize
{
    return [self initWithPageSize:pageSize andPageCount:3];
}

- (id)initWithPageSize:(NSUInteger)pageSize andPageCount:(NSUInteger)pageCount
{
    self = [super initWithPageSize:pageSize];
    
    if (self) {
        
        _dataArray = [NSMutableArray arrayWithCapacity:pageCount];
        _totalSizeArray = [NSMutableArray arrayWithCapacity:pageCount];
        
        for (NSInteger i = 0; i < pageCount; ++ i) {
            [_dataArray addObject:[NSNull null]];
            [_totalSizeArray addObject:@0];
        }
        
        _currentSelectIndex = 0;
    }
    
    return self;
}

- (void)setCurrentSelectIndex:(NSUInteger)currentSelectIndex
{
    if (_currentSelectIndex != currentSelectIndex) {
        _currentSelectIndex = currentSelectIndex;
        
        [self refreshData];
    }
}

- (void)refreshData
{
    id  currentData = _dataArray[_currentSelectIndex];
    
    if (currentData == [NSNull null]) {
        [super refreshData];
    }else{
        
        assert([currentData isKindOfClass:[MyDataStoreManager class]]);
        
        [self.serviceRequest cancleService];
        [self.pageLoadDelegateManager failGetData];
        
        //有数据
        if ([(MyDataStoreManager *)currentData totalDatasCount] != 0) {

            [self.loadingIndicateView hiddenView];
            self.pageLoadObject.contentView.hidden = NO;
            
            [self.pageLoadDelegateManager refreshWithDataStoreManager:currentData totalDataCount:[_totalSizeArray[_currentSelectIndex] integerValue]];
        }else{
            [super refreshData];
        }
    }
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didSuccessRequestWithData:(id)data
{
    NSUInteger totalCount = [[data objectForKey:GP_GP_TOTALSIZES] integerValue];
    NSArray    * datas    = nil;
    
    if (totalCount == 0 ) {
        
        [self.loadingIndicateView showNothingWiTitle:@"没有获取到任何数据"];
        self.pageLoadObject.contentView.hidden = YES;
    }
    
    id<GP_ServicePageLoadControllerDelegate> __delegate = self.delegate;
    ifRespondsSelector(__delegate, @selector(servicePageLoadControllerStartService:serviceSuccessWithData:totalCount:)){
        datas = [__delegate servicePageLoadControllerStartService:self serviceSuccessWithData:data totalCount:&totalCount];
    }
    
    if (totalCount) {
        [self.loadingIndicateView hiddenView];
        self.pageLoadObject.contentView.hidden = NO;
    }
    
    //更新数据
    [_totalSizeArray replaceObjectAtIndex:_currentSelectIndex withObject:[NSNumber numberWithUnsignedInteger:totalCount]];
    
    if (self.pageLoadDelegateManager.currentGetDataType == GetDataTypeRefresh) {
        
        MyDataStoreManager * dataStoreManager = [[MyDataStoreManager alloc] init];
        [dataStoreManager addDatas:datas];
        [_dataArray replaceObjectAtIndex:_currentSelectIndex withObject:dataStoreManager];

        [self.pageLoadDelegateManager endRefreshDataWithDataStoreManager:dataStoreManager totalDataCount:totalCount];
        
    }else{
        [self.pageLoadDelegateManager endGetDataWithData:datas totalDataCount:totalCount];
    }
}


@end
