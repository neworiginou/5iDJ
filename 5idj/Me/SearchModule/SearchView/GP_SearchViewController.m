//
//  GP_ViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-4.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SearchViewController.h"
#import "GP_SearchHistoryView.h"
#import "GP_SearchHistoryManager.h"
#import "GP_SearchResultViewController.h"
#import "GP_VideoFilterInfoCell.h"
#import "GP_LoadingIndicateView.h"
#import "GP_ServiceRequest.h"

//----------------------------------------------------------

@interface GP_SearchViewController () <
                                        UISearchBarDelegate,
                                        UIGestureRecognizerDelegate,
                                        GP_SearchHistoryViewDelegate,
                                        MyLoadingIndicateViewDelegate,
                                        GP_ServiceRequestDelegate
                                      >

- (void)_searchBecomActive:(BOOL)active animated:(BOOL)animated completeBlock:(void (^)())completeBlock;

//点击手势处理
- (void)_tapGestureHandle;

//键盘大小改变通知
- (void)_keyboardDidChangeFrameNotification:(NSNotification *)notification;

//开始搜索
- (void)_startSearchWithKeyword:(NSString *)keyword;

//服务请求
@property(nonatomic,strong,readonly) GP_ServiceRequest * serviceRequest;

//开始获取
- (void)_startGetVideoFilterInfo;


//搜索历史视图
@property(nonatomic,strong,readonly) GP_SearchHistoryView   * searchHistoryView;

@end

//----------------------------------------------------------


@implementation GP_SearchViewController
{
    UISearchBar * _searchBar;
  
    //毛玻璃图片
//    UIImageView            * _blurredImageView;
    
    UIView                 * _searchHistoryBGView;
    
    //加载视图
    GP_LoadingIndicateView * _loadingIndicateView;
    
    NSArray                * _videoFilterInfos;
    
}

@synthesize serviceRequest = _serviceRequest;
@synthesize searchHistoryView = _searchHistoryView;

- (BOOL)isSupportFullScreenMode{
    return YES;
}

- (CGFloat)topExtentViewHeight{
    return 50.f;
}

- (UITableViewStyle)tableViewStyle{
    return UITableViewStyleGrouped;
}

- (UIEdgeInsets)getContentViewInset{
    return UIEdgeInsetsMake(104.f, 0.f, 0.f, 0.f);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gestureChangeFullScreenModeEnable = NO;
    
    self.myNavigationItem.title = @"搜索";
    self.statusBarBackgroundView.backgroundColor = [UIColor whiteColor];
    
    //搜索控件
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 64.f, screenSize().width, 50.f)];
    _searchBar.searchBarStyle  = UISearchBarStyleMinimal;
    _searchBar.backgroundColor = defaultCellBackgroundColor;
    _searchBar.placeholder     = @"请输入要搜索的内容";
    _searchBar.delegate        = self;
    [self.topExtentView addSubview:_searchBar];
    
    //添加分割线
    CALayer * lineLayer = [[CALayer alloc] init];
    lineLayer.backgroundColor = defaultLineColor.CGColor;
    lineLayer.frame = CGRectMake(0, 49.5f, screenSize().width, PiexlToPoint(1.f));
    [_searchBar.layer addSublayer:lineLayer];
    
    
    //表格视图
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    
    //加载视图
    CGRect bounds = self.view.bounds;
    _loadingIndicateView = [[GP_LoadingIndicateView alloc] initWithFrame:CGRectMake(0.f, 114.f, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - 114.f)];
    _loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _loadingIndicateView.delegate = self;
    [self.view addSubview:_loadingIndicateView];
    
    _searchHistoryBGView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 70.f, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - 70.f)];
    _searchHistoryBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                            UIViewAutoresizingFlexibleHeight;
    _searchHistoryBGView.hidden = YES;
    [self.view addSubview:_searchHistoryBGView];
    
    
    
    //开始获取筛选信息
    [self _startGetVideoFilterInfo];
}

- (void)didChangeThemeColor
{
    // do noting
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardDidChangeFrameNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (GP_SearchHistoryView *)searchHistoryView
{
    if (!_searchHistoryView) {
        
        //搜索记录
        _searchHistoryView = [[GP_SearchHistoryView alloc] init];
        _searchHistoryView.delegate = self;
//        [_blurredImageView addSubview:_searchHistoryView];
        
        [_searchHistoryBGView addSubview:_searchHistoryView];
        
        //点击手势
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureHandle)];
        tapGestureRecognizer.delegate = self;
        [_searchHistoryView addGestureRecognizer:tapGestureRecognizer];
    }
    
    return _searchHistoryView;
}

- (void)_keyboardDidChangeFrameNotification:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardMinY = [self.view convertPoint:keyboardFrame.origin fromView:self.view.window].y;
    self.searchHistoryView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(_searchHistoryBGView.bounds), keyBoardMinY - 70.f);
}

- (void)_searchBecomActive:(BOOL)active animated:(BOOL)animated completeBlock:(void (^)())completeBlock
{
    if (active) {
        [_searchBar becomeFirstResponder];
    }else{
        [_searchBar resignFirstResponder];
    }
    
    _searchBar.showsCancelButton = active;
    self.searchHistoryView.tableView.contentOffset = CGPointZero;
    
    if (active) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        
        typeof(self) __weak weak_self = self;
        [self setFullScreenMode:active
                       animated:animated
                 animationBlock:animated ? ^{
                     typeof(self) _self = weak_self;
                     _self->_searchBar.backgroundColor = [UIColor whiteColor];
                 } : nil
                  completeBlock:^{
                      
                       typeof(self) _self = weak_self;
                      
                      _self->_searchHistoryBGView.layer.contents = (__bridge id)
                            [snapshotView(_self.view) applyBlurWithRadius:15.f
                                                                tintColor:defaultCellBackgroundColor
                                                    saturationDeltaFactor:1.8f
                                                                maskImage:nil].CGImage;
                      
                      CGFloat factor = CGRectGetMinY(_self->_searchHistoryBGView.frame) / CGRectGetHeight(_self.view.bounds);
                      _self->_searchHistoryBGView.layer.contentsRect = CGRectMake(0.f, factor, 1.f, 1 - factor);

                      _self->_searchHistoryBGView.hidden = NO;
                      _self->_searchHistoryBGView.alpha  = 0.f;
                      [UIView animateWithDuration:0.2f animations:^{
                          _self->_searchHistoryBGView.alpha = 1.f;
                      }];
                      
                      _self->_searchBar.backgroundColor = [UIColor whiteColor];
                      
                      if (completeBlock) {
                          completeBlock();
                      }
                 
                 }];
    }else{
        
        _searchHistoryBGView.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        
        typeof(self) __weak weak_self = self;
        
        [self setFullScreenMode:active
                       animated:animated
                 animationBlock: animated ? ^{
        
                     typeof(self) _self = weak_self;
                     _self.tableView.contentOffset = CGPointMake(0.f, - _self.tableView.contentInset.top);
                     _self->_searchBar.backgroundColor = defaultCellBackgroundColor;
                     
                 } : nil
                  completeBlock: animated ? completeBlock :^{
                      
                      typeof(self) _self = weak_self;
                      _self.tableView.contentOffset = CGPointMake(0.f, - _self.tableView.contentInset.top);
                      
                      _self->_searchBar.backgroundColor = defaultCellBackgroundColor;
                      
                      if (completeBlock) {
                          completeBlock();
                      }
                  }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return !CGRectContainsPoint([self.searchHistoryView visbleItemRect], [touch locationInView:self.searchHistoryView]);
}

- (void)_tapGestureHandle
{
    [self _searchBecomActive:NO animated:YES completeBlock:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self _searchBecomActive:NO animated:YES completeBlock:nil];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (!self.isFullScreenMode) {
        [self _searchBecomActive:YES animated:YES completeBlock:nil];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //开始搜索
    [self _startSearchWithKeyword:_searchBar.text];
}

- (void)searchHistoryView:(GP_SearchHistoryView *)searchHistoryView didSelectSearchKeyword:(NSString *)keyword
{
    //开始搜索
    [self _startSearchWithKeyword:keyword];
}

- (void)searchHistoryView:(GP_SearchHistoryView *)searchHistoryView didUpSearchKeyword:(NSString *)keyword
{
    _searchBar.text = keyword;
}

- (void)_startSearchWithKeyword:(NSString *)keyword
{
    typeof(self) __weak weak_self = self;
    
    [self _searchBecomActive:NO animated:YES completeBlock:^{
    
        typeof(self) _self = weak_self;
        
        _self->_searchBar.text = nil;
        
        //添加历史搜索记录
        [[GP_SearchHistoryManager shareManager] addSearchKeyword:keyword];
        
        //生成筛选信息
        NSMutableDictionary * filterInfo = [NSMutableDictionary dictionaryWithCapacity:_self->_videoFilterInfos.count];
        
        for (GP_VideoFilterInfo * info  in _self->_videoFilterInfos) {
            [filterInfo addEntriesFromDictionary:[info selectVideoFilterInfo]];
        }
        
        //弹出搜索
        [_self pushSubViewController:[[GP_SearchResultViewController alloc] initWithSearchKeyword:keyword filterInfo:filterInfo] animated:YES];
    }];
}


- (BOOL)interactivePopGestureShouldReceiveTouch:(UITouch *)touch
{
    return ![_searchBar isFirstResponder];
}

- (GP_ServiceRequest *)serviceRequest
{
    if (!_serviceRequest) {
        _serviceRequest = [[GP_ServiceRequest alloc] init];
        _serviceRequest.delegate = self;
    }
    
    return _serviceRequest;
}

- (void)_startGetVideoFilterInfo
{
    if ([self currentNetworkStatus:NO] != kNotReachable) {
        
        [_loadingIndicateView showLoadingStatusWithTitle:@"正在获取数据中,请稍等..." detailText:nil];
     
        //开始获取筛选信息
        [self.serviceRequest startGetVideoFilterInfo];
    }else{
        
        [_loadingIndicateView showNoNetworkStatus];
    }
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didFailRequestWithError:(NSError *)error
{
    [_loadingIndicateView showLoadingErrorStatusWithTitle:@"获取数据失败" detailText:@"点击重试"];
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didSuccessRequestWithData:(id)data
{
    [_loadingIndicateView removeFromSuperview];
    _loadingIndicateView = nil;
    
    _videoFilterInfos = [NSArray arrayWithArray:data];
    
    [self.tableView reloadData];
}

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    [self _startGetVideoFilterInfo];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _videoFilterInfos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_videoFilterInfos[section] description];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger valueCount = [_videoFilterInfos[indexPath.section] valuesCount];
    
    return ceilf(valueCount / 3.f) * AspectScaleLenght(40.f);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GP_VideoFilterInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:defaultReuseDef];
    
    if (!cell) {
        cell = [[GP_VideoFilterInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultReuseDef];
    }
    
    [cell updateWithVideoFilterInfo:_videoFilterInfos[indexPath.section]];
    
    return cell;
}


@end
