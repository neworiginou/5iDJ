//
//  GP_SearchHistoryTableController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SearchHistoryView.h"
#import "GP_SearchHistoryManager.h"

//----------------------------------------------------------

#define RemoveAllHistorySearchKeywordsAlertViewTag   1234

//----------------------------------------------------------

@interface GP_SearchHistoryView () <
                                     UITableViewDelegate,
                                     UITableViewDataSource,
                                     UIAlertViewDelegate
                                   >

@property(nonatomic,strong,readonly) MyTintTableViewCell * removeAllHistoryKeywordsCell;

@property(nonatomic,strong,readonly) UIImage * highlightedSearchTagImage;
@property(nonatomic,strong,readonly) UIImage * highlightedUpImage;

@end

//----------------------------------------------------------

@implementation GP_SearchHistoryView

@synthesize removeAllHistoryKeywordsCell = _removeAllHistoryKeywordsCell;
@synthesize highlightedSearchTagImage    = _highlightedSearchTagImage;
@synthesize highlightedUpImage           = _highlightedUpImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //tables视图
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0.f, 10.f, 0.f, 0.f);
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_tableView];
      
        
        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
        
        //添加通知
        [notificationCenter addObserver:self
                               selector:@selector(_searchHistoryManagerWillChangeNotification:)
                                   name:SearchHistoryManagerWillChangeNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(_searchHistoryManagerDidChangeNotification:)
                                   name:SearchHistoryManagerDidChangeNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(_searchHistoryManagerChangeSectionNotification:)
                                   name:SearchHistoryManagerChangeSectionNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(_searchHistoryManagerChangeSearchKeywordNotification:)
                                   name:SearchHistoryManagerChangeSearchKeywordNotification
                                 object:nil];
        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)_updateView
{
    if (_removeAllHistoryKeywordsCell) {
        UILabel * label = (UILabel *)[_removeAllHistoryKeywordsCell.contentView viewWithTag:1001];
        label.text = [[GP_SearchHistoryManager shareManager] numberOfSections] ? @"清空搜索历史" : @"无搜索历史";
    }
}

- (UIImage *)highlightedSearchTagImage
{
    if (!_highlightedSearchTagImage) {
        _highlightedSearchTagImage = [ImageWithName(@"search_keyword_tag") imageWithTintColor:[UIColor whiteColor]];
    }
    
    return _highlightedSearchTagImage;
}

- (UIImage *)highlightedUpImage
{
    if (!_highlightedUpImage) {
        _highlightedUpImage = [ImageWithName(@"search_keyword_up") imageWithTintColor:[UIColor whiteColor]];
    }
    
    return _highlightedUpImage;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[GP_SearchHistoryManager shareManager] numberOfSections] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [[GP_SearchHistoryManager shareManager] numberOfSections] ) {
        return [[GP_SearchHistoryManager shareManager] numberOfSearchKeywordsAtSection:section];
    }else{
        return 1;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section < [[GP_SearchHistoryManager shareManager] numberOfSections];
}

- (MyTintTableViewCell *)removeAllHistoryKeywordsCell
{
    if (!_removeAllHistoryKeywordsCell) {
        
        _removeAllHistoryKeywordsCell = [[MyTintTableViewCell alloc] init];
        _removeAllHistoryKeywordsCell.showSeparatorLine  = YES;
        _removeAllHistoryKeywordsCell.separatorInset     = self.tableView.separatorInset;
        _removeAllHistoryKeywordsCell.backgroundColor    = defaultCellBackgroundColor;
        _removeAllHistoryKeywordsCell.separatorLineColor = defaultLineColor;
        
        UILabel * label = [[UILabel alloc] initWithFrame:_removeAllHistoryKeywordsCell.contentView.bounds];
        label.textAlignment        = NSTextAlignmentCenter;
        label.font                 = [UIFont systemFontOfSize:15.f];
        label.textColor            = defaultTitleTextColor;
        label.highlightedTextColor = [UIColor whiteColor];
        label.tag                  = 1001;
        label.autoresizingMask     = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        label.text = [[GP_SearchHistoryManager shareManager] numberOfSections] ? @"清空搜索历史" : @"无搜索历史";
        
        [_removeAllHistoryKeywordsCell.contentView addSubview:label];
        _removeAllHistoryKeywordsCell.highlightedObjects = @[label];
    }
    
    return _removeAllHistoryKeywordsCell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [[GP_SearchHistoryManager shareManager] numberOfSections]) {
        
//        static NSString * cellDef = @"cellDef";
        
        MyTintTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:defaultReuseDef];
        
        if (!cell) {
            
            cell = [[MyTintTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:defaultReuseDef];
            cell.showSeparatorLine  = YES;
            cell.separatorInset     = tableView.separatorInset;
            cell.backgroundColor    = defaultCellBackgroundColor;
            cell.separatorLineColor = defaultLineColor;
            
            cell.textLabel.textColor = defaultTitleTextColor;
            cell.textLabel.font  = [UIFont systemFontOfSize:15.f];
            cell.imageView.image = ImageWithName(@"search_keyword_tag");
            cell.imageView.highlightedImage = self.highlightedSearchTagImage;
            
            UIButton * button  = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
            [button setImage:ImageWithName(@"search_keyword_up") forState:UIControlStateNormal];
            [button setImage:self.highlightedUpImage forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(_accessoryButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
            
            //转换成void指针
            void * prt = (__bridge void *)(cell);
            //记录
            button.tag = (NSInteger)prt;
            
            cell.accessoryView = button;
            
            cell.highlightedObjects = @[cell.textLabel,cell.imageView,button];
        }
        
        cell.textLabel.text = [[GP_SearchHistoryManager shareManager] searchKeywordsAtIndexPath:indexPath].searchKey;
        
        return cell;
        
    }else{
        return self.removeAllHistoryKeywordsCell;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        GP_SearchHistoryManager * searchHistoryManager = [GP_SearchHistoryManager shareManager];
        NSError * error = nil;
        if (![searchHistoryManager removeHistorySearchKeyword:[searchHistoryManager searchKeywordsAtIndexPath:indexPath] error:&error]) {
            showErrorMessage(self, error, @"删除搜索记录失败");
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger sectionsCount = [tableView numberOfSections];
    
    if (indexPath.section == sectionsCount - 1) {//点击了清空
        
        if (sectionsCount > 1) {
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定清空所有的搜索历史？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            alertView.tag = RemoveAllHistorySearchKeywordsAlertViewTag;
            
            [alertView show];
        }
        
    }else{
        
        id<GP_SearchHistoryViewDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(searchHistoryView:didSelectSearchKeyword:)){
            [delegate searchHistoryView:self didSelectSearchKeyword:[[GP_SearchHistoryManager shareManager] searchKeywordsAtIndexPath:indexPath].searchKey];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == RemoveAllHistorySearchKeywordsAlertViewTag) {
        
        if (alertView.cancelButtonIndex != buttonIndex) {
            [[GP_SearchHistoryManager shareManager] removeAllHistorySearchKeywords];
        }
    }
}

- (void)_accessoryButtonHandle:(UIButton *)sender
{
    MyTintTableViewCell * cell = (__bridge MyTintTableViewCell *)(void *)sender.tag;
    
    id<GP_SearchHistoryViewDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(searchHistoryView:didUpSearchKeyword:)){
        [delegate searchHistoryView:self didUpSearchKeyword:cell.textLabel.text];
    }
}

- (CGRect)visbleItemRect
{
    CGRect rect = [self.tableView rectForSection:[self.tableView numberOfSections] - 1];
    
    if(CGRectGetMaxY(rect) <= 0){
        return CGRectZero;
    }else{
        return CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetMaxY(rect));
    }
}

- (void)_searchHistoryManagerWillChangeNotification:(NSNotification *)notification
{
    [self.tableView beginUpdates];
}

- (void)_searchHistoryManagerDidChangeNotification:(NSNotification *)notification
{
    [self.tableView endUpdates];
    [self _updateView];
}


- (void)_searchHistoryManagerChangeSectionNotification:(NSNotification *)notification
{
    SearchHistoryManagerChangeType changeType = [notification.userInfo[SearchHistoryManagerChangeTypeInfoKey] integerValue];
    NSUInteger section = [notification.userInfo[SearchHistoryManagerChangeSectionInfoKey] unsignedIntegerValue];
    
    switch (changeType) {
        case SearchHistoryManagerChangeTypeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case SearchHistoryManagerChangeTypeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
    
}

- (void)_searchHistoryManagerChangeSearchKeywordNotification:(NSNotification *)notification
{
     SearchHistoryManagerChangeType changeType = [notification.userInfo[SearchHistoryManagerChangeTypeInfoKey] integerValue];
    NSIndexPath * indexPath = notification.userInfo[SearchHistoryManagerChangeIndexPathInfoKey];
    NSIndexPath * newIndexPath = notification.userInfo[SearchHistoryManagerNewIndexPathInfoKey];
    
    switch (changeType) {
        case SearchHistoryManagerChangeTypeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case SearchHistoryManagerChangeTypeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
        case SearchHistoryManagerChangeTypeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
            
        case SearchHistoryManagerChangeTypeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}



@end
