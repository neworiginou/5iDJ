//
//  GP_VideosSortTypeViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideosSortTypeViewController.h"
#import "GP_ImageAndTitleCollectionViewManager.h"
#import "GP_VideoCollectionCell.h"

//----------------------------------------------------------

@implementation GP_VideosSortTypeViewController
{
    //索引到排列方式的映射
    int _indexToSortTypeMap[3];
}

- (id)initWithSemgentedItemArray:(NSArray *)itemArray
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithSemgentedItemArray:@[@"精彩赛事",@"特色节目",@"其他视频"]];
    
    if (self) {
        _indexToSortTypeMap[0] = GP_SP_VIDEOS_SORTTYPE_MATCH;
        _indexToSortTypeMap[1] = GP_SP_VIDEOS_SORTTYPE_PROGRAMME;
        _indexToSortTypeMap[2] = GP_SP_VIDEOS_SORTTYPE_OTHER;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.segmentedControl.selectedSegmentIndex = 0;
    
    _multipleServicePageLoadController = [[GP_MultipleServicePageLoadController alloc] initWithPageSize:20 andPageCount:3];
    _multipleServicePageLoadController.delegate = self;
    _multipleServicePageLoadController.loadingIndicateView.frame = CGRectMake(0.f, [self topExtentViewHeight] + 64.f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.frame) - [self topExtentViewHeight] - 64.f);
    _multipleServicePageLoadController.loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_multipleServicePageLoadController.loadingIndicateView];
    
}

- (NSInteger)currentSortType
{
    return _indexToSortTypeMap[self.segmentedControl.selectedSegmentIndex];
}

- (void)segmentedSelectedIndexChangeHandle
{
    [super segmentedSelectedIndexChangeHandle];
    
    _multipleServicePageLoadController.currentSelectIndex = self.segmentedControl.selectedSegmentIndex;
}

- (id<GP_PageLoadProtocol>)servicePageLoadControllerNeedPageLoadObject:(GP_ServicePageLoadController *)servicePageLoadController
{
    GP_ImageAndTitleCollectionViewManager * imageAndTitleCollectionViewManager = [[GP_ImageAndTitleCollectionViewManager alloc] initWithBasicViewController:self cellClass:[GP_VideoCollectionCell class]];
    
    imageAndTitleCollectionViewManager.delegate = self;
    
    return imageAndTitleCollectionViewManager;
}

- (BOOL)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController forPage:(NSUInteger)page
{
    return NO;
}

- (void)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceFailWithError:(NSError *)error
{
    if (servicePageLoadController.loadingIndicateView.isHidden) {
        showErrorMessage(self.view, error, @"获取视频失败");
    }
}

- (NSArray *)servicePageLoadControllerStartService:(GP_ServicePageLoadController *)servicePageLoadController serviceSuccessWithData:(id)data totalCount:(NSUInteger *)totalCount
{
    if (*totalCount == 0) {
        [self setFullScreenMode:NO];
    }
    
    return nil;
}


@end
