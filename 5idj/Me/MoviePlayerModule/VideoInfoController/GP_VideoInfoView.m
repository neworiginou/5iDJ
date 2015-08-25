//
//  GP_videoInfoView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoInfoView.h"
#import "GP_VideoDetailView.h"
#import "GP_RelatedVideosView.h"

//----------------------------------------------------------

@interface GP_VideoInfoView()<
                                SelectVideoProtocol,
                                MyScrollPageDataSource,
                                MyScrollPageDelegate
                            >

@property(nonatomic,strong)          GP_Video               * video;

@property(nonatomic,strong,readonly) MySegmentedControl     * segmentedControl;

@property(nonatomic,strong,readonly) MyScrollPage           * scorllPage;

@property(nonatomic,strong,readonly) GP_RelatedVideosView   * relatedVideosView;
@property(nonatomic,strong,readonly) GP_VideoDetailView     * videoDetailView;


- (void)_segmentedControlHandle:(id)sender;

@end

//----------------------------------------------------------

@implementation GP_VideoInfoView


@synthesize segmentedControl      = _segmentedControl;
@synthesize scorllPage            = _scorllPage;
@synthesize relatedVideosView     = _relatedVideosView;
@synthesize videoDetailView       = _videoDetailView;

- (id)initWithFrame:(CGRect)frame
{
     self = [super initWithFrame:frame];
    
    if (self) {
        
        //其他视图
        [self addSubview:self.segmentedControl];
        [self addSubview:self.scorllPage];
        
        //添加直线
        [self.layer addSublayer:createLineLayer(CGPointMake(0, 44.f), CGPointMake(screenSize().width, 44.f), 0.5f, defaultLineColor)];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (CGRectGetHeight(_scorllPage.frame) != CGRectGetHeight(self.bounds) - 44.f) {
        [_scorllPage reloadData];
    }
}


- (MySegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        
        _segmentedControl = [[MySegmentedControl alloc] initWithSectionTitles:@[@"相关视频",@"详细介绍"]];
        _segmentedControl.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), 44.f);
        _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                             UIViewAutoresizingFlexibleBottomMargin;
        _segmentedControl.textColor = defaultTitleTextColor;
        _segmentedControl.textFont  = [UIFont boldSystemFontOfSize:18.f];
        _segmentedControl.showSeparatorLine = NO;
        _segmentedControl.selectedIndicatorLineInsetScale = UIEdgeInsetsMake(0.f, 0.15f, 0.f, 0.15f);
        [_segmentedControl addTarget:self action:@selector(_segmentedControlHandle:) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.selectedSectionIndex = 0.f;
    }
    
    return _segmentedControl;
}

- (MyScrollPage *)scorllPage
{
    if (!_scorllPage) {
        
        _scorllPage = [[MyScrollPage alloc] initWithStyle:MyScrollPageStyleBottom];
        _scorllPage.frame = CGRectMake(0, 44.f,0.f, 0.f);
        _scorllPage.hiddenPageIndicator = YES;
        _scorllPage.dataSource = self;
        _scorllPage.delegate = self;
    }
    
    return _scorllPage;
}

- (GP_RelatedVideosView *)relatedVideosView
{
    if (!_relatedVideosView) {
        _relatedVideosView = [[GP_RelatedVideosView alloc] init];
        _relatedVideosView.selectVideoDelegate = self;
        [_relatedVideosView refreshWithVideo:_video];
    }
    
    return _relatedVideosView;
}


- (GP_VideoDetailView *)videoDetailView
{
    if (!_videoDetailView) {
        _videoDetailView = [[GP_VideoDetailView alloc] init];
        [self.videoDetailView refreshWithVideo:_video];
    }
    
    return _videoDetailView;
}


- (void)_segmentedControlHandle:(id)sender
{
    [UIView animateWithDuration:0.8f
                          delay:0.f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                     
                         [self.scorllPage setCurrentPageIndex:self.segmentedControl.selectedSectionIndex animated:NO];
                         
                     } completion:nil];
}

- (NSUInteger)numberOfPageInScrollPage:(MyScrollPage *)scorllPage
{
    return 2;
}

- (CGSize)pageSizeForScrollPage:(MyScrollPage *)scorllPage
{
    return CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 44.f);
}

- (UIView *)scorllPage:(MyScrollPage *)scorllPage pageViewForIndex:(NSUInteger)index
{
    if (index == 0) {
        return self.relatedVideosView;
    }else{
        return self.videoDetailView;
    }
}

- (void)scorllPage:(MyScrollPage *)scorllPage didChangeToPageAtIndex:(NSUInteger)index
{
    [self.segmentedControl setSelectedSectionIndex:index animated:YES];
    
}

- (void)object:(id)object didSelectVideo:(GP_Video *)Video
{
    SafeSendSelectVideoMsg(self.selectVideoDelegate, Video);
}

- (void)refreshWithVideo:(GP_Video *)video
{
    _video = video;
    
    [_relatedVideosView refreshWithVideo:_video];
    [_videoDetailView refreshWithVideo:_video];
}




@end
