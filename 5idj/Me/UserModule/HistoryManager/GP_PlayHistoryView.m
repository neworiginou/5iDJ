//
//  GP_historyTableController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-4.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_PlayHistoryView.h"
#import "GP_PlayHistoryManager.h"

//----------------------------------------------------------

@interface _RemoveAllHistoryButton : MyButton

@end

//----------------------------------------------------------

@implementation _RemoveAllHistoryButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, 150.f, 35.f)];
    
    if (self) {
        
        self.layer.cornerRadius = 5.f;
        [self setBackgroundColor:[UIColor redColor]];
        [self setBackgroundColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.2f] forState:UIControlStateDisabled];
        [self setTitle:@"删除所有记录" forState:UIControlStateNormal];
        
        //添加通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_historyRecordesDidChange:)
                                                     name:PlayHistoryManagerDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_historyManagerDidReload:)
                                                     name:PlayHistoryManagerDidReloadNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_historyRecordesDidChange:(NSNotification *)notification
{
    self.enabled = ![[GP_PlayHistoryManager defaultManager] isEmpty];
}

- (void)_historyManagerDidReload:(NSNotification *)notification
{
    self.enabled = ![[GP_PlayHistoryManager defaultManager] isEmpty];
}

@end

//----------------------------------------------------------

#define RemoveAllHistoryAlertViewTag  1000

//----------------------------------------------------------

@interface GP_PlayHistoryView() <
                                  UITableViewDelegate,
                                  UITableViewDataSource,
                                  UIAlertViewDelegate
                                >
@end

//----------------------------------------------------------

@implementation GP_PlayHistoryView
{
    //下端工具栏
    UIToolbar  *_bottomToolbar;
    
    //无历史记录的标记视图
    MyIndicateView * _noHistoryIndicateView;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _noHistoryIndicateView = [[MyIndicateView alloc] initWithFrame:self.bounds];
        _noHistoryIndicateView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                                  UIViewAutoresizingFlexibleHeight;
        _noHistoryIndicateView.titleLabelColor = defaultTitleTextColor;
        _noHistoryIndicateView.detailLabelColor = defaultBodyTextColor;
        [self addSubview:_noHistoryIndicateView];
        
        _noHistoryIndicateView.image = ImageWithName(@"user_no_history");
        _noHistoryIndicateView.style = MyIndicateViewStyleImageView;
        _noHistoryIndicateView.titleLabelText  = @"暂无历史播放记录";
        _noHistoryIndicateView.detailLabelText = @"赶快开始您的观影之旅吧！";
        
        //table视图
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 45.f;
        _tableView.sectionHeaderHeight = 18.f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.separatorColor = defaultLineColor;
        [self addSubview:_tableView];
        
        //更新视图
        [self _updateView];
        
        
        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
        
        //添加通知
        [notificationCenter addObserver:self
                               selector:@selector(_historyManagerWillChangeNotification:)
                                   name:PlayHistoryManagerWillChangeNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(_historyManagerDidChangeNotification:)
                                   name:PlayHistoryManagerDidChangeNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(_historyManagerChangeSectionNotification:)
                                   name:PlayHistoryManagerChangeSectionNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(_historyManagerChangeRecordNotification:)
                                   name:PlayHistoryManagerChangeRecordNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(_historyManagerDidReloadNotification:)
                                   name:PlayHistoryManagerDidReloadNotification
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
    if (![[GP_PlayHistoryManager defaultManager] isEmpty]) {
        _noHistoryIndicateView.hidden = YES;
//        _tableView.hidden = NO;
    }else{
//        _tableView.hidden = YES;
        _noHistoryIndicateView.hidden = NO;
    }
    
    _tableView.userInteractionEnabled = _noHistoryIndicateView.hidden;
}

#pragma mark - remove all bar

- (void)setNeedShowBottomToolBar:(BOOL)needShowBottomToolBar
{
    if (_needShowBottomToolBar != needShowBottomToolBar) {
        
        [_bottomToolbar removeFromSuperview];
        
        _needShowBottomToolBar = needShowBottomToolBar;
        
        if (_needShowBottomToolBar) {
            
            if (!_bottomToolbar) {
                _bottomToolbar = [self createBottomToolBarInstance];
                _bottomToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                                  UIViewAutoresizingFlexibleTopMargin;
            }
            
            _bottomToolbar.frame = CGRectMake(0.f, CGRectGetHeight(self.bounds) - 49.f, CGRectGetWidth(self.bounds), 49.f);
            [self addSubview:_bottomToolbar];
            
            _noHistoryIndicateView.offsetValue = CGPointMake(0.f, -24.5f);
            _tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 49.f, 0.f);
        }else{
            
            _noHistoryIndicateView.offsetValue = CGPointZero;
            _tableView.contentInset = UIEdgeInsetsZero;
        }
    }
}

- (UIToolbar *)createBottomToolBarInstance
{
    UIToolbar * toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, 49.f)];
    
    //设置背景
    [toolBar setBackgroundImage:resizableImageWithColor(defaultWhiteBarColor)
             forToolbarPosition:UIBarPositionAny
                     barMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem * leftFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * rightFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //清除按钮
    _RemoveAllHistoryButton * removeAllButton  = [[_RemoveAllHistoryButton alloc] init];
    [removeAllButton addTarget:self action:@selector(_removeAllHistoryButtonHandle) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * removeAllHistoryBarButton = [[UIBarButtonItem alloc] initWithCustomView:removeAllButton];
    [toolBar setItems:@[leftFlexibleSpace,removeAllHistoryBarButton,rightFlexibleSpace]];
    
    removeAllButton.enabled = ![[GP_PlayHistoryManager defaultManager] isEmpty];
    
    return toolBar;
}

- (void)_removeAllHistoryButtonHandle
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:@"确定删除所有播放记录?"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"确定", nil];
    
    alertView.tag = RemoveAllHistoryAlertViewTag;
    
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == RemoveAllHistoryAlertViewTag) {
        
        if (buttonIndex != alertView.cancelButtonIndex) {
            //删除所有记录
            [[GP_PlayHistoryManager defaultManager] removeAllRecodes];
        }
    }
}

#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[GP_PlayHistoryManager defaultManager] numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[GP_PlayHistoryManager defaultManager] numberOfRecordAtSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(tableView.bounds), tableView.sectionHeaderHeight)];
    headerView.backgroundColor = defaultCellBackgroundColor;
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.separatorInset.left, 0.f, CGRectGetWidth(headerView.frame), tableView.sectionHeaderHeight)];
    titleLabel.textColor = ColorWithNumberRGB(0x333333);
    titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    [headerView addSubview:titleLabel];
    
    titleLabel.text =  [[GP_PlayHistoryManager defaultManager] titleAtSection:section];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString * cellDef = @"cellDef";
    
    MyTintTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:defaultReuseDef];
    
    if (!cell) {
        
        cell = [[MyTintTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:defaultReuseDef];
        cell.backgroundColor   = [UIColor clearColor];
        cell.tintColorAlpha    = 0.7f;
        cell.showSeparatorLine = YES;
        [cell.textLabel setTextColor:defaultTitleTextColor];
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        [cell.detailTextLabel setTextColor:defaultBodyTextColor];
    }
    
    [self _updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)_updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GP_VideoPlayRecord * record = [[GP_PlayHistoryManager defaultManager] recordAtIndexPath:indexPath];
    
    cell.textLabel.text = record.title;
    
    if ([record.playFinish boolValue]) {
        cell.detailTextLabel.text = @"已看完";
    }else if([record.playDuration doubleValue] < 60.f){
        cell.detailTextLabel.text = @"观看至：少于1分钟";
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"观看至：%@",moviePlayDurationFormatterString([record.playDuration doubleValue],YES)];
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        GP_VideoPlayRecord * record = [[GP_PlayHistoryManager defaultManager] recordAtIndexPath:indexPath];
        
        NSError * error = nil;
        if (![[GP_PlayHistoryManager defaultManager] removeRecord:record error:&error]) {
            showErrorMessage(self, error, @"删除播放记录失败");
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GP_VideoPlayRecord * record = [[GP_PlayHistoryManager defaultManager] recordAtIndexPath:indexPath];
    SafeSendSelectVideoMsg(self.selectVideoDelegate, [record toVideo]);
}

#pragma mark - history manager notification

- (void)_historyManagerWillChangeNotification:(NSNotification *)notification
{
    [_tableView beginUpdates];
}

- (void)_historyManagerDidChangeNotification:(NSNotification *)notification
{
    [_tableView endUpdates];
    [self _updateView];
}

- (void)_historyManagerChangeSectionNotification:(NSNotification *)notification
{
    PlayHistoryManagerChangeType type = [notification.userInfo[PlayHistoryManagerChangeTypeInfoKey] integerValue];
    NSUInteger section = [notification.userInfo[PlayHistoryManagerChangeSectionInfoKey] unsignedIntegerValue];
    
    switch (type) {
        case PlayHistoryManagerChangeTypeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:section]
                      withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case PlayHistoryManagerChangeTypeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:section]
                      withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)_historyManagerChangeRecordNotification:(NSNotification *)notification
{
    PlayHistoryManagerChangeType type = [notification.userInfo[PlayHistoryManagerChangeTypeInfoKey] integerValue];
    NSIndexPath * indexPath = notification.userInfo[PlayHistoryManagerChangeIndexPathInfoKey];
    NSIndexPath * newIndexPath = notification.userInfo[PlayHistoryManagerNewIndexPathInfoKey];
    
    switch (type) {
        case PlayHistoryManagerChangeTypeInsert:
            [_tableView insertRowsAtIndexPaths:@[newIndexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case PlayHistoryManagerChangeTypeDelete:
            [_tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case PlayHistoryManagerChangeTypeMove:
            [_tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
            
        case PlayHistoryManagerChangeTypeUpdate:
            [self _updateCell:[_tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}

- (void)_historyManagerDidReloadNotification:(NSNotification *)notification
{
    [_tableView reloadData];
    [self _updateView];
}

@end
