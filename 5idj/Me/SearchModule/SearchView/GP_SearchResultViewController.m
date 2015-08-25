//
//  GP_SearchResultViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-16.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SearchResultViewController.h"
#import "GP_ImageAndTitleCollectionViewManager.h"
#import "GP_ServicePageLoadController.h"
#import "GP_VideoCollectionCell.h"

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, GP_SearchResultViewControllerType) {
    GP_SearchResultViewControllerTypeNormal,
    GP_SearchResultViewControllerTypeInChannel
};

//----------------------------------------------------------

@interface GP_SearchResultViewController () <GP_ServicePageLoadControllerDelegate>

@property(nonatomic,strong) GP_ServicePageLoadController * servicePageLoadController;

@property(nonatomic,strong) UIView * topExtentBackgroundView;

@end

//----------------------------------------------------------


@implementation GP_SearchResultViewController
{
    GP_SearchResultViewControllerType _type;
    
    NSString        * _keyword;
    NSDictionary    * _filterInfo;
    NSInteger         _channelID;
}

- (CGFloat)topExtentViewHeight{
    return 30.f;
}

- (BOOL)isSupportFullScreenMode{
    return YES;
}

- (BOOL)fullScreenModeIncludeTopExtentView{
    return YES;
}


- (id)initWithSearchKeyword:(NSString *)keyword filterInfo:(NSDictionary *)filterInfo
{
    assert(keyword);
    
    self = [super init];
    
    if (self) {
        _type      = GP_SearchResultViewControllerTypeNormal;
        _keyword   = keyword;
        _filterInfo = filterInfo;
    }
    
    return self;
}

- (id)initWithSearchKeyword:(NSString *)keyword channelID:(NSInteger)channelID
{
    assert(keyword);
    
    self = [super init];
    
    if (self) {
        _type      = GP_SearchResultViewControllerTypeInChannel;
        _keyword   = keyword;
        _channelID = channelID;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = @"搜索结果";
    
    self.topExtentBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 64.f, screenSize().width, [self topExtentViewHeight])];
    self.topExtentBackgroundView.backgroundColor = defaultCellBackgroundColor;
    [self.topExtentView addSubview:self.topExtentBackgroundView];
    
    //设置阴影
    self.topExtentBackgroundView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.f, CGRectGetHeight(self.topExtentBackgroundView.bounds) - 3.f, screenSize().width, 3.f)].CGPath;
    self.topExtentBackgroundView.layer.shadowOffset = CGSizeMake(0.f, 3.f);
    self.topExtentBackgroundView.layer.shadowOpacity = 0.6f;
    
    
    UILabel * keywordLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.topExtentBackgroundView.bounds, 10.f, 0.f)];
    keywordLabel.font = [UIFont systemFontOfSize:15.f];
    keywordLabel.textColor = defaultTitleTextColor;
    keywordLabel.text = [NSString stringWithFormat:@"搜索关键字：%@",_keyword];
    [self.topExtentBackgroundView addSubview:keywordLabel];
    
    //添加
    [self.view addSubview:self.collectionView];
    
    self.servicePageLoadController = [[GP_ServicePageLoadController alloc] initWithPageSize:20.f];
    self.servicePageLoadController.loadHandleName = @"搜索视频";
    self.servicePageLoadController.delegate = self;
    
    self.servicePageLoadController.loadingIndicateView.frame = CGRectMake(0.f, [self topExtentViewHeight] + 64.f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - [self topExtentViewHeight] - 64.f);
    self.servicePageLoadController.loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.servicePageLoadController.loadingIndicateView];

    //刷新数据
    [self.servicePageLoadController refreshData];
}


- (id<GP_PageLoadProtocol>)servicePageLoadControllerNeedPageLoadObject:(GP_ServicePageLoadController *)servicePageLoadController
{
    GP_ImageAndTitleCollectionViewManager * imageAndTitleCollectionViewManager = [[GP_ImageAndTitleCollectionViewManager alloc] initWithBasicViewController:self cellClass:[GP_VideoCollectionCell class]];
    
    imageAndTitleCollectionViewManager.delegate = self;
    
    return imageAndTitleCollectionViewManager;
}


- (BOOL)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController forPage:(NSUInteger)page
{
    if ([self currentNetworkStatus:YES] != kNotReachable) {
        
        switch (_type) {
            case GP_SearchResultViewControllerTypeNormal:
                [servicePageLoadController.serviceRequest startSearchVideosServiceWithKeyword:_keyword filterInfo:_filterInfo currentPage:page pageSize:servicePageLoadController.pageSize];
                break;
                
            case GP_SearchResultViewControllerTypeInChannel:
                
                [servicePageLoadController.serviceRequest startSearchVideosInChannelServiceWithKeyword:_keyword channelID:_channelID currentPage:page pageSize:servicePageLoadController.pageSize];
                break;
        }
        
        return YES;
    }else{
        return NO;
    }

}

- (NSArray *)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceSuccessWithData:(id)data totalCount:(NSUInteger *)totalCount
{
    *totalCount = [[data objectForKey:GP_GP_SEARCH_VIDEOS_TOTALSIZES] integerValue];
    
    if (*totalCount == 0) {
        [servicePageLoadController.loadingIndicateView showNothingWiTitle:@"没有找到任何相关的视频"];
    }
    
    
    return data[GP_GP_SEARCH_VIDEOS_VIDOES];
}

- (void)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceFailWithError:(NSError *)error
{
    if (servicePageLoadController.loadingIndicateView.isHidden) {
        showErrorMessage(self.view, error, @"获取视频失败");
    }
}

- (void)setFullScreenMode:(BOOL)fullScreenMode
                 animated:(BOOL)animated
           animationBlock:(void (^)())animationBlock
            completeBlock:(void (^)())completeBlock
{
    typeof(self) __weak weak_self = self;
    
    [super setFullScreenMode:fullScreenMode
                    animated:animated
              animationBlock:animated ? ^{
                  
                  weak_self.topExtentBackgroundView.alpha = fullScreenMode ? 0.f : 1.f;
                  
                  if (animationBlock) {
                      animationBlock();
                  }
                  
              } : nil
               completeBlock:animated ? completeBlock : ^{
                
                   weak_self.topExtentBackgroundView.alpha = fullScreenMode ? 0.f : 1.f;
                   
                   if (completeBlock) {
                       completeBlock();
                   }
               }];
}

@end
