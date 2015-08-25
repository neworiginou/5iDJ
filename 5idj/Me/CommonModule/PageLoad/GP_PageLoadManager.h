//
//  GP_PageLoadManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-7.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "GP_PageLoadProtocol.h"

//----------------------------------------------------------

@interface GP_PageLoadManager : NSObject<GP_PageLoadProtocol>

- (id)initWithScrollView:(UIScrollView *)scrollView;

//数据
@property(nonatomic,strong,readonly) MyDataStoreManager * dataStoreManager;

@property(nonatomic,strong,readonly)  MyRefreshControl * topRefreshControl;
@property(nonatomic,strong,readonly)  MyRefreshControl * bottomLoadControl;

- (void)refreshControlHandle;
- (void)loadControlHandle;

- (void)updateLoadStatus;

@end
