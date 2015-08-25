//
//  GP_historyTableController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-4.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@protocol SelectVideoProtocol;

//----------------------------------------------------------

@interface GP_PlayHistoryView : UIView

//是否需要底端工具栏
@property(nonatomic) BOOL needShowBottomToolBar;

//创建一个底端工具栏实例用于自立意显示
- (UIToolbar *)createBottomToolBarInstance;

@property(nonatomic,strong,readonly)   UITableView    * tableView;

@property(nonatomic,weak) id<SelectVideoProtocol> selectVideoDelegate;

@end
