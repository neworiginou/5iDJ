//
//  GP_VideosSortTypeViewController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicSegmentViewController.h"
#import "GP_MultipleServicePageLoadController.h"

//----------------------------------------------------------


@interface GP_VideosSortTypeViewController : GP_BasicSegmentViewController
                                                <
                                                    GP_ServicePageLoadControllerDelegate
                                                >

@property(nonatomic,strong,readonly) GP_MultipleServicePageLoadController * multipleServicePageLoadController;

//当前的排序方式
- (NSInteger)currentSortType;

@end
