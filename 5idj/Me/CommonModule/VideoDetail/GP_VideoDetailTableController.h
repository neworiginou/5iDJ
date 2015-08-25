//
//  GP_VideoDetailTableController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "GP_Video.h"
#import "GP_PageLoadManager.h"

//----------------------------------------------------------

@interface GP_VideoDetailTableController : GP_PageLoadManager <
                                                                UITableViewDelegate,
                                                                UITableViewDataSource
                                                              >


- (id)initWithTableViewFrame:(CGRect)frame;

@property(nonatomic,readonly) UITableView *tableView;

- (void)removeDataAtIndexPaths:(NSArray *)indexPaths;

@property(nonatomic,weak) id<SelectVideoProtocol> selectVideoDelegate;

@end
