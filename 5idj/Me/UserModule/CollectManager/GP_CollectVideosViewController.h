//
//  GP_CollectVideosTableManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "GP_Video.h"

//----------------------------------------------------------

@interface GP_CollectVideosViewController : NSObject

- (id)initWithFrame:(CGRect)frame;

@property(nonatomic,strong,readonly) UIView         * view;
@property(nonatomic,strong,readonly) UITableView    * tableView;

@property(nonatomic,weak) id<SelectVideoProtocol> selectVideoDelegate;

//更新
- (void)refresh;

//设置刷新控件隐藏
- (void)setRefreshControlHidden:(BOOL)hidden;


@end
