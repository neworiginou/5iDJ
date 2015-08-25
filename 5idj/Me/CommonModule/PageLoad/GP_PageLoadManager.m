//
//  GP_PageLoadManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-7.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_PageLoadManager.h"

//----------------------------------------------------------

@implementation GP_PageLoadManager
{
    UIScrollView * _scrollView;
}

@synthesize pageLoadDelegate  = _pageLoadDelegate;
@synthesize topRefreshControl = _topRefreshControl;
@synthesize bottomLoadControl = _bottomLoadControl;
@synthesize dataStoreManager  = _dataStoreManager;

- (id)initWithScrollView:(UIScrollView *)scrollView
{
    assert(scrollView);
    
    if (self = [super init]) {
        _scrollView = scrollView;
    }

    return self;
}

- (void)setPageLoadDelegate:(id<GP_PageLoadDelegate>)pageLoadDelegate
{
    if (_pageLoadDelegate != pageLoadDelegate) {
        
        [_topRefreshControl removeFromSuperview];
        [_bottomLoadControl removeFromSuperview];
        
        _topRefreshControl = nil;
        _bottomLoadControl = nil;
        
        _pageLoadDelegate = pageLoadDelegate;
        
        if (self.topRefreshControl) {
            [_scrollView addSubview:self.topRefreshControl];
        }
    }
}

- (MyRefreshControl *)topRefreshControl
{
    if (!_topRefreshControl) {
        
        id<GP_PageLoadDelegate> pageLoadDelegate = _pageLoadDelegate;
        ifRespondsSelector(pageLoadDelegate, @selector(objectNeedTopRefreshControl:)){
            if ([pageLoadDelegate objectNeedTopRefreshControl:self]) {
                
                _topRefreshControl = [[MyRefreshControl alloc] init];
                _topRefreshControl.textColor = defaultTitleTextColor;
                
                [_topRefreshControl addTarget:self action:@selector(refreshControlHandle) forControlEvents:UIControlEventValueChanged];
            }
        }
    }
    
    return _topRefreshControl;
}

- (MyRefreshControl *)bottomLoadControl
{
    if (!_bottomLoadControl) {
        
        id<GP_PageLoadDelegate> pageLoadDelegate = _pageLoadDelegate;
        ifRespondsSelector(pageLoadDelegate, @selector(objectNeedBottomLoadControl:)){
            if ([pageLoadDelegate objectNeedBottomLoadControl:self]) {
                
                _bottomLoadControl = [[MyRefreshControl alloc] initWithStyle:MyRefreshControlStyleBottom];
                _bottomLoadControl.textColor = defaultTitleTextColor;
                _bottomLoadControl.alphaChangeWithScroll = NO;
                
                [_bottomLoadControl addTarget:self action:@selector(loadControlHandle) forControlEvents:UIControlEventValueChanged];
            }
        }
    }
    
    return _bottomLoadControl;
}


- (void)refreshControlHandle
{
    [_bottomLoadControl setHidden:YES];
    
    id<GP_PageLoadDelegate> __pageLoadDelegate = _pageLoadDelegate;
    ifRespondsSelector(__pageLoadDelegate, @selector(objectDidRefreshData:)){
        [__pageLoadDelegate objectDidRefreshData:self];
    }else{
        [_topRefreshControl endRefreshing];
    }
}

- (void)loadControlHandle
{
    [_topRefreshControl setHidden:YES];
    
    id<GP_PageLoadDelegate> __pageLoadDelegate = _pageLoadDelegate;
    ifRespondsSelector(__pageLoadDelegate, @selector(objectDidLoadData:)){
        [__pageLoadDelegate objectDidLoadData:self];
    }else{
        [_bottomLoadControl endRefreshing];
    }
}

- (void)updateLoadStatus
{
    if (self.bottomLoadControl) {
        
        BOOL bRet = YES;
        
        id<GP_PageLoadDelegate> pageLoadDelegate = _pageLoadDelegate;
        ifRespondsSelector(pageLoadDelegate, @selector(totalDataSizeForobject:)){
            bRet = self.currentDataCount >= [_pageLoadDelegate totalDataSizeForobject:self];
        }
        
//        [_scrollView addSubview:_bottomLoadControl];
//
//        if (bRet) {
//            [_bottomLoadControl setUnEnableWithTitle:@"没有更多了。"];
//        }else{
//            [_bottomLoadControl setEnabled:YES];
//        }
        
//        [_bottomLoadControl set]
        
        
        if (bRet) {
            [self.bottomLoadControl removeFromSuperview];
        }else{
            [_scrollView addSubview:self.bottomLoadControl];
        }
        
//        [_bottomLoadControl setHidden:bRet];
    }
}

- (void)startRefreshData
{
    if (![self.bottomLoadControl isRefreshing]) {
        [self.topRefreshControl beginRefreshing];
        [self.bottomLoadControl setHidden:YES];
    }
}

- (void)endRefreshDataStoreManager:(MyDataStoreManager *)dataStoreManager
{
    [self.topRefreshControl endRefreshing];
    [self.bottomLoadControl setHidden:NO];
    
//    self.dataStoreManager.delegate = nil;
//    _dataStoreManager = nil;
    
    _dataStoreManager = dataStoreManager;
    _dataStoreManager.delegate = self;
    
//    [self reloadData];
    
    
    [self updateLoadStatus];
}

- (void)endRefreshDatas:(NSArray *)datas;
{
    MyDataStoreManager * dataStoreManager = [[MyDataStoreManager alloc] init];
    [dataStoreManager addDatas:datas];

    [self endRefreshDataStoreManager:dataStoreManager];
}

- (void)startLoadData
{
    if (![self.topRefreshControl isRefreshing]) {
        [self.bottomLoadControl beginRefreshing];
        [self.topRefreshControl setHidden:YES];
    }
}

- (void)endLoadDatas:(NSArray *)datas
{
    [self.bottomLoadControl endRefreshing];
    [self.topRefreshControl setHidden:NO];
    
    [self.dataStoreManager addDatas:datas];
    
    [self updateLoadStatus];
}

- (void)failGetData
{
    [self.topRefreshControl endRefreshing];
    [self.bottomLoadControl endRefreshing];
    [self.topRefreshControl setHidden:NO];
    [self.bottomLoadControl setHidden:NO];
}

- (UIView *)contentView
{
    return _scrollView;
}

- (NSUInteger)currentDataCount
{
   return  self.dataStoreManager.totalDatasCount;
}

- (MyDataStoreManager *)dataStoreManager
{
    if (!_dataStoreManager) {
        _dataStoreManager = [[MyDataStoreManager alloc] init];
        _dataStoreManager.delegate = self;
    }
    
    return _dataStoreManager;
}


@end
