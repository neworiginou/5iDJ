//
//  GP_HomeViewController.m
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-9.
//  Copyright (c) 2013年 hldw航. All rights reserved.
//

//----------------------------------------------------------

#import "GP_HomeViewController.h"
#import "GP_HomeHotFocusVideosView.h"
#import "GP_HomeModuleSupplementaryView.h"
#import "GP_VideoCollectionCell.h"
#import "GP_HomeVideosModule.h"
#import "GP_HomeDataManager.h"
#import "GP_LoadingIndicateView.h"

//----------------------------------------------------------

#define HotFoucsVideosDataPath \
    [[[MyPathManager alloc] initWithFileFolder:@"HomeData"] pathForFile:@"hotFoucsVideos.data"]

#define HomeVideoModulesDataPath \
    [[[MyPathManager alloc] initWithFileFolder:@"HomeData"] pathForFile:@"homeVideoModules.data"]

#define VideoCollectionViewDef          @"VideoCollectionViewDef"
#define HomeModuleSupplementaryViewDef  @"HomeModuleSupplementaryViewDef"

//----------------------------------------------------------

@interface GP_HomeViewController () <
                                        GP_HomeDataManagerDelegate,
//                                        SelectHomeVideosModuleProtocol,
                                        MyLoadingIndicateViewDelegate
                                    >


@property(nonatomic,strong,readonly) GP_HomeDataManager * homeDataManager;

@property(nonatomic,strong,readonly) GP_LoadingIndicateView * loadingIndicateView;

//热门视频
@property(nonatomic,strong) NSArray *hotFoucsVideos;

//视频模块
@property(nonatomic,strong) NSArray *homeVideoModules;

//刷新数据
- (void)_refreshData;

//核对模块数据，确保正确数据
- (NSArray *)_checkModuleArray:(NSArray *)moduleArray;

//进入后台通知
- (void)_applicationEnterBackgroundNotification:(NSNotification *)notification;

@end

//----------------------------------------------------------

@implementation GP_HomeViewController
{
    BOOL _needWirteHomeDataToFile;
    
    GP_HomeHotFocusVideosView * _homeHotFocusVideosView;
}

@synthesize homeDataManager     = _homeDataManager;
@synthesize loadingIndicateView = _loadingIndicateView;


+ (GP_MainNavigationController *)navigationController
{
    GP_MainNavigationController *navigationController=[super navigationController];

    navigationController.tabBarItem=[[UITabBarItem alloc] initWithTitle:nil image:ImageWithName(@"ti_home") tag:0];
    
    return navigationController;
}

- (BOOL)isSupportFullScreenMode
{
    return YES;
}

- (UICollectionViewLayout *)collectionViewLayout
{
    UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout *)[super collectionViewLayout];
    flowLayout.sectionInset = UIEdgeInsetsMake(0.f, 6.f, 0.f, 6.f);
    flowLayout.headerReferenceSize = CGSizeMake(screenSize().width, 40.f);
    
    return flowLayout;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = @"焦点视频";
    
    //顶端滚动视图高
    CGFloat scrollViewHeight = AspectScaleLenght(180.f);
    
    //设置偏移
    self.contentViewInsetOffset = UIEdgeInsetsMake(scrollViewHeight, 0.f, 0.f, 0.f);
    
    //添加contionView
    [self.view addSubview:self.collectionView];
    
    //注册单元类
    [self.collectionView registerClass:[GP_VideoCollectionCell class] forCellWithReuseIdentifier:VideoCollectionViewDef];
    [self.collectionView registerClass:[GP_HomeModuleSupplementaryView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HomeModuleSupplementaryViewDef];

    //添加刷新控件
    self.refreshControl.locationOffsetY = scrollViewHeight;
    [self.collectionView addSubview:self.refreshControl];

    //非第一次加载从文件读取数据，否则删除数据重新加载
    if (![GP_AppDelegate isFirstLaunchApp]) {
        _hotFoucsVideos   = [NSKeyedUnarchiver unarchiveObjectWithFile:HotFoucsVideosDataPath];
        _homeVideoModules = [NSKeyedUnarchiver unarchiveObjectWithFile:HomeVideoModulesDataPath];
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:HotFoucsVideosDataPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:HomeVideoModulesDataPath error:nil];
    }
    
    //热门视频视图
    _homeHotFocusVideosView = [[GP_HomeHotFocusVideosView alloc] initWithVideos:_hotFoucsVideos];
    _homeHotFocusVideosView.frame = CGRectMake(0.f, - scrollViewHeight, screenSize().width, scrollViewHeight);
    _homeHotFocusVideosView.videoDelegate = self;
    [self.collectionView addSubview:_homeHotFocusVideosView];
    

    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    //更新数据
    [self tryRefreshData];
    
}


//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    
//    //移除通知
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIApplicationDidEnterBackgroundNotification
//                                                  object:nil];
//}


#pragma mark - data

- (void)tryRefreshData
{
    //没有正在获取数据
    if (![self.homeDataManager isGettingHomeData]) {
        
        //刷新提示
        if (_hotFoucsVideos && _homeVideoModules) {
            [self.refreshControl beginRefreshing];
        }else{
            [self.loadingIndicateView showLoadingStatusWithTitle:@"获取首页数据中..." detailText:nil];
            self.collectionView.hidden = YES;
        }
        
        //更新数据
        [self _refreshData];
    }
}

- (void)_applicationEnterBackgroundNotification:(NSNotification *)notification
{
    if (_needWirteHomeDataToFile) {
        _needWirteHomeDataToFile = NO;
        
        //写入文件
        [NSKeyedArchiver archiveRootObject:_hotFoucsVideos toFile:HotFoucsVideosDataPath];
        [NSKeyedArchiver archiveRootObject:_homeVideoModules toFile:HomeVideoModulesDataPath];
    }
}

- (void)refreshHandle
{
    //更新数据
    [self _refreshData];
}

- (void)_refreshData
{
    if (kNotReachable != [self currentNetworkStatus:!_loadingIndicateView]) {
        [self.homeDataManager startGetHomeData];
    }else if(_loadingIndicateView){
        [_loadingIndicateView showNoNetworkStatus];
    }else{
        [self endRefresh:NO];
    }
}

- (GP_LoadingIndicateView *)loadingIndicateView
{
    if (!_loadingIndicateView) {
        CGRect bounds = self.view.bounds;
        _loadingIndicateView = [[GP_LoadingIndicateView alloc] initWithFrame:CGRectMake(0.f, 64.f, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - 113.f)];
        _loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _loadingIndicateView.delegate = self;
        [self.view addSubview:_loadingIndicateView];
    }
    
    return _loadingIndicateView;
}

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    [_loadingIndicateView showLoadingStatusWithTitle:@"获取首页数据中..." detailText:nil];
    [self _refreshData];
}


- (GP_HomeDataManager *)homeDataManager
{
    if (!_homeDataManager) {
        _homeDataManager = [[GP_HomeDataManager alloc] init];
        _homeDataManager.delegate = self;
    }
    
    return _homeDataManager;
}

- (void)homeDataManager:(GP_HomeDataManager *)manager getHomeDataFailWithError:(NSError *)error
{
    if (_loadingIndicateView) {
        [_loadingIndicateView showLoadingErrorStatusWithTitle:@"获取首页数据失败" detailText:@"点击页面重试"];
    }else{
        
        [self endRefresh:NO];
        
        showErrorMessage(self.view, error, @"获取首页数据失败");
    }
}


- (void)homeDataManager:(GP_HomeDataManager *)manager getHomeDataSuccessWithVideos:(NSArray *)videos andModules:(NSArray *)modules
{
    if (_loadingIndicateView) {
        
        [_loadingIndicateView removeFromSuperview];
        _loadingIndicateView = nil;
        
        self.collectionView.hidden = NO;
        
    }else{
        [self endRefresh:YES];
    }
    
    //标记需要写入文件
    _needWirteHomeDataToFile = YES;
    
    //更新视图和数据
    _hotFoucsVideos = videos;
    _homeVideoModules = [self _checkModuleArray:modules];
    
    [_homeHotFocusVideosView updateWithVideos:videos];
    [self.collectionView reloadData];
    
}

- (NSArray *)_checkModuleArray:(NSArray *)moduleArray
{
    NSMutableArray * resultArray = [NSMutableArray arrayWithCapacity:moduleArray.count];
    
    for (GP_HomeVideosModule * videosModule in moduleArray) {
        assert([videosModule isKindOfClass:[GP_HomeVideosModule class]]);
        
        if (videosModule.videos && videosModule.videos.count != 0) {
            [resultArray addObject:videosModule];
        }
    }
    return resultArray;
}

#pragma mark - Collection View delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _homeVideoModules.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [(GP_HomeVideosModule *)_homeVideoModules[section] videos].count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        static NSString * homeModuleSupplementaryViewDef = HomeModuleSupplementaryViewDef;
        
        GP_HomeModuleSupplementaryView * homeModuleSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:homeModuleSupplementaryViewDef forIndexPath:indexPath];
        
        [homeModuleSupplementaryView setVideosModule:_homeVideoModules[indexPath.section]];
        
        return homeModuleSupplementaryView;
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * videoCollectionViewDef = VideoCollectionViewDef;
    
    GP_VideoCollectionCell * videoCollectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:videoCollectionViewDef forIndexPath:indexPath];
    
    [videoCollectionCell updateWithVideo:[(GP_HomeVideosModule *)_homeVideoModules[indexPath.section] videos][indexPath.item]];
    
    return videoCollectionCell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GP_Video * video = [(GP_HomeVideosModule *)_homeVideoModules[indexPath.section] videos][indexPath.item];
    
    [self object:nil didSelectVideo:video];
    
}


- (BOOL)interactiveGestureShouldBeginWithPoint:(CGPoint)point withDirection:(ChangeTabBarItemDirection)diretion
{
    if ([super interactiveGestureShouldBeginWithPoint:point withDirection:diretion]) {
        
        CGPoint pointInCollectionView =  [self.collectionView convertPoint:point fromView:self.view];
        
        //不在最上方热门区域时响应，避免冲突
        return !CGRectContainsPoint(_homeHotFocusVideosView.frame, pointInCollectionView);
    }
    
    return NO;
}
@end
