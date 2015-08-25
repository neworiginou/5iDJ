//
//  MySettingTableController.h
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-29.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MySettingTableViewCell.h"

//----------------------------------------------------------

@class MySettingTableController;

//----------------------------------------------------------

@protocol MySettingTableControllerDataSource

@optional

- (UITableViewCell *)settingTableController:(MySettingTableController *)settingTableController
                customCellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


//----------------------------------------------------------

@protocol MySettingTableControllerDelegate

@optional

- (void)settingTableController:(MySettingTableController *)settingTableController
        needShowViewController:(UIViewController *)viewController;

- (CGFloat)settingTableController:(MySettingTableController *)settingTableController
    heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)settingTableController:(MySettingTableController *)settingTableController
       didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)settingTableController:(MySettingTableController *)settingTableController
                sendSelectEvent:(NSString *)eventKey;

@end

//----------------------------------------------------------

@interface MySettingTableController : NSObject<
                                                UITableViewDelegate,
                                                UITableViewDataSource,
                                                MySettingTableViewCellDelegate
                                              >

- (id)initWithTableView:(UITableView *)tableView
  configurationFileName:(NSString *)fileName
                 bundle:(NSBundle *)bundleOrNil;

@property(nonatomic,strong,readonly) UITableView * tableView;

@property(nonatomic,strong) NSArray * settingItemsInfo;

@property(nonatomic,weak) id<MySettingTableControllerDataSource> dataSource;
@property(nonatomic,weak) id<MySettingTableControllerDelegate> delegate;


@property(nonatomic,strong) UIColor * tableViewCellBackgroundColor;

@property(nonatomic) CGFloat   tableViewCellTintColorAlpha;

@end
