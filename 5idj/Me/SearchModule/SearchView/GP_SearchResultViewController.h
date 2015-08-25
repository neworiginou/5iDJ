//
//  GP_SearchResultViewController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-16.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//#import "GP_VideosSortTypeViewController.h"
#import "GP_BasicSubViewController.h"

@interface GP_SearchResultViewController : GP_BasicSubViewController

- (id)initWithSearchKeyword:(NSString *)keyword filterInfo:(NSDictionary *)filterInfo;

- (id)initWithSearchKeyword:(NSString *)keyword channelID:(NSInteger)channelID;

@end
