//
//  GP_VideoDetailTableController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoDetailTableController.h"
#import "GP_VideoDetailCell.h"

//----------------------------------------------------------

@implementation GP_VideoDetailTableController

- (id)init
{
    return [self initWithTableViewFrame:CGRectZero];
}

- (id)initWithTableViewFrame:(CGRect)frame
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorColor  = defaultLineColor;
    tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight       = [GP_VideoDetailCell cellHeight];

    self = [super initWithScrollView:tableView];
    
    if (self) {
        _tableView = tableView;
    }
    
    return self;
}


- (void)removeDataAtIndexPaths:(NSArray *)indexPaths
{
    [self.tableView beginUpdates];
    [self.dataStoreManager removeDatasAtIndexPaths:indexPaths];
    [self.tableView endUpdates];
}

- (void)endRefreshDataStoreManager:(MyDataStoreManager *)dataStoreManager
{
    [super endRefreshDataStoreManager:dataStoreManager];
    
    [self.tableView reloadData];
}

- (void)endLoadDatas:(NSArray *)datas
{
    [self.tableView beginUpdates];
    
    [super endLoadDatas:datas];
    
    [self.tableView endUpdates];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    assert(tableView == self.tableView);
    
    return [self.dataStoreManager numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    assert(tableView == self.tableView);
    
    return [self.dataStoreManager numberOfDatasAtSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(tableView == self.tableView);
    
//    static NSString * videoDetailCellDef = @"videoDetailCellDef";
    
    GP_VideoDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:defaultReuseDef];
    
    if (!cell) {
        cell = [[GP_VideoDetailCell alloc] initWithReuseIdentifier:defaultReuseDef];
        cell.separatorLineColor = tableView.separatorColor;
    }
    
    [cell updateWithVideo:[self.dataStoreManager dataAtIndexPath:indexPath]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(tableView == self.tableView);
    
    SafeSendSelectVideoMsg(self.selectVideoDelegate, [self.dataStoreManager dataAtIndexPath:indexPath]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager
        didChangeSection:(NSUInteger)section
              changeType:(MyDataStoreManagerDataChangeType)type
{
    if (dataStoreManager == self.dataStoreManager) {
        
        if (type == MyDataStoreManagerDataChangeTypeAdd) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager
 didChangeDatasAtSection:(NSUInteger)section
             andIndexSet:(NSIndexSet *)indexSet
              changeType:(MyDataStoreManagerDataChangeType)type
{
    if (dataStoreManager == self.dataStoreManager) {
        
        if (type == MyDataStoreManagerDataChangeTypeAdd) {
            [self.tableView insertRowsAtIndexPaths:indexPathsFromIndexSet(section, indexSet) withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [self.tableView deleteRowsAtIndexPaths:indexPathsFromIndexSet(section, indexSet) withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}


@end
