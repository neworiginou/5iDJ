//
//  GP_MoreViewController.m
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-10.
//  Copyright (c) 2013年 hldw航. All rights reserved.
//

//----------------------------------------------------------

#import "GP_MoreViewController.h"
#import "GP_CacheManager.h"
#import "GP_SettingTableController.h"

//----------------------------------------------------------

@implementation GP_MoreViewController
{
    GP_SettingTableController * _itemsTableController;
}


+ (GP_MainNavigationController *)navigationController
{
    GP_MainNavigationController *navigationController = [super navigationController];
   
    navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:ImageWithName(@"ti_more") tag:3];
    
    return navigationController;
}

- (UITableViewStyle)tableViewStyle
{
    return UITableViewStyleGrouped;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = @"更多";
    
    _itemsTableController = [[GP_SettingTableController alloc] initWithTableView:self.tableView configurationFileName:@"GP_MoreViewTableItem" bundle:nil];
    _itemsTableController.delegate = self;
    _itemsTableController.dataSource = self;
    
    [self.view addSubview:self.tableView];
}



@end
