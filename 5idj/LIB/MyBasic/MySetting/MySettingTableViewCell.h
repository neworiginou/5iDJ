//
//  MySettingTableViewCell.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyTintTableViewCell.h"

//----------------------------------------------------------

extern NSString * const SettingCellDidChangeSettingInfoNotification;
extern NSString * const SettingInfoKeyUserInfoKey;

//----------------------------------------------------------


@class MySettingTableViewCell;

@protocol MySettingTableViewCellDelegate

- (void)settingTableViewCell:(MySettingTableViewCell *)cell
      needShowViewController:(UIViewController *)viewController;

@end

//----------------------------------------------------------

typedef NS_ENUM(int, MySettingTableViewCellType) {
    MySettingTableViewCellTypeDefault  = 0,
    MySettingTableViewCellTypeNext     = 1,
    MySettingTableViewCellTypeSwitch   = 2,
    MySettingTableViewCellTypeCustom   = 3
    //    ,
    //    MySettingTableViewCellTypeSelected = 4
};

//----------------------------------------------------------

@interface MySettingTableViewCell : MyTintTableViewCell

+ (MySettingTableViewCell *)cellWithInfoDic:(NSDictionary *)info forTableView:(UITableView *)tableView;

@property(nonatomic,weak) id<MySettingTableViewCellDelegate> delegate;

@end

//----------------------------------------------------------

@interface NSDictionary (MySettingTableViewCell)

- (MySettingTableViewCellType)type;

- (UITableViewCellStyle)style;

- (NSString *)title;

- (NSString *)detailTitle;

- (UIImage *)image;

- (UIImage *)highlightedImage;

- (NSString *)targetKey;

- (NSString *)selectEvent;

@end
