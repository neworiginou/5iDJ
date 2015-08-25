//
//  MySettingTableController.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-29.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MySettingTableController.h"
#import "MacroDef.h"

//----------------------------------------------------------

@implementation MySettingTableController

- (id)init
{
    return [self initWithTableView:nil configurationFileName:nil bundle:nil];
}

- (id)initWithTableView:(UITableView *)tableView
  configurationFileName:(NSString *)fileName
                 bundle:(NSBundle *)bundleOrNil
{
    self = [super init];
    
    if (self) {
        
        if (!tableView) {
            tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        }
        
        _tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        if (fileName) {
            _settingItemsInfo = [NSArray arrayWithContentsOfFile:[bundleOrNil ?: [NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]];
        }
        
        //白色
        _tableViewCellBackgroundColor = [UIColor whiteColor];
        
        _tableViewCellTintColorAlpha = 1.f;
        
    }
    return self;
}

- (void)setSettingItemsInfo:(NSArray *)settingItemsInfo
{
    if (_settingItemsInfo != settingItemsInfo) {
        _settingItemsInfo = settingItemsInfo;
        
        [_tableView reloadData];
    }
}

- (NSDictionary *)_cellInfoAtIndexPath:(NSIndexPath *)indexPath
{
    return [[_settingItemsInfo[indexPath.section] objectForKey:@"rows"]
            objectAtIndex:indexPath.row];
}

- (BOOL)_isCustomRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self _cellInfoAtIndexPath:indexPath] type] == MySettingTableViewCellTypeCustom;
}

- (NSString *)_selectEventAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self _cellInfoAtIndexPath:indexPath] selectEvent];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _settingItemsInfo.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_settingItemsInfo[section] objectForKey:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_settingItemsInfo[section] objectForKey:@"headerTitle"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [_settingItemsInfo[section] objectForKey:@"footerTitle"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id<MySettingTableControllerDelegate> delegate = self.delegate;
    
    ifRespondsSelector(delegate, @selector(settingTableController:heightForRowAtIndexPath:)){
        return [delegate settingTableController:self heightForRowAtIndexPath:indexPath];
    }
    
    
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self _isCustomRowAtIndexPath:indexPath]){
        
        id<MySettingTableControllerDataSource> dataSource = self.dataSource;
        
        ifRespondsSelector(dataSource, @selector(settingTableController:customCellForRowAtIndexPath:)){
            return [dataSource settingTableController:self customCellForRowAtIndexPath:indexPath];
        }
        
    }else{
        
        MySettingTableViewCell * cell = [MySettingTableViewCell cellWithInfoDic:[self _cellInfoAtIndexPath:indexPath] forTableView:tableView];
        cell.backgroundColor = self.tableViewCellBackgroundColor;
        cell.tintColorAlpha  = self.tableViewCellTintColorAlpha;
        cell.delegate = self;
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id<MySettingTableControllerDelegate> delegate = self.delegate;
    
    ifRespondsSelector(delegate, @selector(settingTableController:sendSelectEvent:)){
        
        NSString * selectEvent = [[self _cellInfoAtIndexPath:indexPath] selectEvent];
        if (selectEvent.length > 0) {
            [delegate settingTableController:self sendSelectEvent:selectEvent];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)settingTableViewCell:(MySettingTableViewCell *)cell
      needShowViewController:(UIViewController *)viewController
{
    id<MySettingTableControllerDelegate> delegate = self.delegate;
    
    ifRespondsSelector(delegate, @selector(settingTableController:needShowViewController:)){
        [delegate settingTableController:self needShowViewController:viewController];
    }
}


@end
