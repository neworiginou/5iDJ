//
//  GP_SettingViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SettingViewController.h"
#import "MySettingTableViewCell.h"
#import "GP_CacheManager.h"
#import "GP_SettingTableController.h"

//----------------------------------------------------------

#define ExitUserAlertViewTag        1000
#define ClearCacheActionSheetTag    1001

//----------------------------------------------------------

@interface GP_SettingViewController ()<
                                        UIAlertViewDelegate,
                                        UIActionSheetDelegate
                                      >

//清除缓存单元
@property(nonatomic,strong,readonly) UITableViewCell * clearCacheCell;

//更新缓存大小信息
- (void)_updateCacheSizeInfo;

//退出登录按钮
@property(nonatomic,strong,readonly) MyButton *exitLoginButton;
- (void)_exitLoginButtonHandle;

- (void)_currentUserChangeNotification:(NSNotification *)notification;

@end

//----------------------------------------------------------


@implementation GP_SettingViewController
{
    BOOL _isUpdatingCacheSize;
    
    GP_SettingTableController * _settingTableController;
}

@synthesize exitLoginButton = _exitLoginButton;
@synthesize clearCacheCell  = _clearCacheCell;


- (UITableViewStyle)tableViewStyle
{
    return UITableViewStyleGrouped;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = @"设置";
    
    [self.view addSubview:self.tableView];
    
    //设置项目管理
    _settingTableController = [[GP_SettingTableController alloc] initWithTableView:self.tableView configurationFileName:@"GP_SettingViewTableItem" bundle:nil];
    _settingTableController.dataSource = self;
    _settingTableController.delegate   = self;
    
    //脚视图
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, 60.f)];
    [footerView addSubview:self.exitLoginButton];
    self.tableView.tableFooterView = footerView;

    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentUserChangeNotification:) name:CurrentUserChangeNotification object:nil];

    
    [self setNeedUpdateView];
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:CurrentUserChangeNotification object:nil];
//}

- (void)updateView
{
    self.exitLoginButton.enabled = [GP_UserManager currentUser] != nil;
}

- (void)_currentUserChangeNotification:(NSNotification *)notification
{
    [self setNeedUpdateView];
}

- (MyButton *)exitLoginButton
{
    if (!_exitLoginButton) {
        
        _exitLoginButton = [[MyButton alloc] initWithFrame:CGRectMake(20.f, 10.f, screenSize().width - 40.f, 40.f)];
        [_exitLoginButton setBackgroundColor:[UIColor redColor]];
        [_exitLoginButton setBackgroundColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [_exitLoginButton setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.2f] forState:UIControlStateDisabled];
        
        [_exitLoginButton setTitle:@"退出登录" forState:UIControlStateNormal];
        
        _exitLoginButton.layer.cornerRadius = 5.f;
        
        [_exitLoginButton addTarget:self action:@selector(_exitLoginButtonHandle) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _exitLoginButton;
}

- (void)_exitLoginButtonHandle
{
    //提示确认退出
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:@"确认退出当前用户?"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"确认", nil];
    alertView.tag = ExitUserAlertViewTag;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ExitUserAlertViewTag) {
        
        //点击了确认
        if ([alertView cancelButtonIndex] != buttonIndex) {
            
            //退出用户
            [GP_UserManager exitCurrentUser];
            
            showSuccessMessage(self.view, @"用户已成功退出", nil);
        }
    }
}

#pragma mark - cache manager

- (UITableViewCell *)clearCacheCell
{
    if (!_clearCacheCell) {
        
        _clearCacheCell = [[MyTintTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        _clearCacheCell.backgroundColor = defaultCellBackgroundColor;
        _clearCacheCell.textLabel.text = @"清空缓存图片";
        _clearCacheCell.detailTextLabel.text = @"获取中...";
        
        [self _updateCacheSizeInfo];
    }
    
    return _clearCacheCell;
}

- (void)_updateCacheSizeInfo
{
    if (!_clearCacheCell) {
        return;
    }
    
    _clearCacheCell.detailTextLabel.text = @"获取中...";
    
    _isUpdatingCacheSize = YES;
    
    [GP_CacheManager cacheFileSize:^(long long cacheSize){
        
        _isUpdatingCacheSize = NO;
        
        NSString * cacheSizeText = nil;
        
        if (cacheSize < 10240) {
            cacheSizeText = [NSString stringWithFormat:@"%.02fKB",cacheSize/1024.f];
        }else{
            cacheSizeText = [NSString stringWithFormat:@"%.02fMB",cacheSize/(1024 * 1024.f)];
        }
        
        _clearCacheCell.detailTextLabel.text = cacheSizeText;
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ClearCacheActionSheetTag) {
        
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            [self showProgressIndicatorView:@"清理缓存中..."];
            
            [GP_CacheManager clearCacheFile:^{
                [self hideProgressIndicatorView];
                
                showSuccessMessage(self.view, @"缓存清理成功", nil);
                
                //更新缓存信息
                [self _updateCacheSizeInfo];
            }];
        }
    }
}


- (UITableViewCell *)settingTableController:(MySettingTableController *)settingTableController
                customCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.clearCacheCell;
}

- (void)settingTableController:(MySettingTableController *)settingTableController
               sendSelectEvent:(NSString *)eventKey
{
    if ([eventKey isEqualToString:@"SE_CLEAR_CACHE"]) {
    
        if (_isUpdatingCacheSize) {
            
            [self showAlertViewWithTitle:@"提示" message:@"正在计算缓存中,请稍后..."];
            return;
        }
        
        UIActionSheet * actionSheet = [[UIActionSheet alloc]
                                       initWithTitle:nil
                                       delegate:self
                                       cancelButtonTitle:@"取消"
                                       destructiveButtonTitle:@"确认清空缓存图片"
                                       otherButtonTitles: nil];
        
        actionSheet.tag = ClearCacheActionSheetTag;
        [actionSheet showInView:self.view];

    }
}

@end
