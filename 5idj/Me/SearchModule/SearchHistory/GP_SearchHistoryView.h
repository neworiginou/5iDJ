//
//  GP_SearchHistoryTableController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------
#import <UIKit/UIKit.h>
//----------------------------------------------------------

@class GP_SearchHistoryView;

//----------------------------------------------------------

@protocol GP_SearchHistoryViewDelegate

@optional

- (void)searchHistoryView:(GP_SearchHistoryView *)searchHistoryView didSelectSearchKeyword:(NSString *)keyword;

- (void)searchHistoryView:(GP_SearchHistoryView *)searchHistoryView didUpSearchKeyword:(NSString *)keyword;

@end

//----------------------------------------------------------

@interface GP_SearchHistoryView : UIView

@property(nonatomic,strong,readonly) UITableView * tableView;

@property(nonatomic,weak) id<GP_SearchHistoryViewDelegate> delegate;

//可见项的rect
- (CGRect)visbleItemRect;


@end
