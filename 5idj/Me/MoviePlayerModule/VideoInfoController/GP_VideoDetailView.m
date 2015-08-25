//
//  GP_VideoDetailView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoDetailView.h"
#import "UILabel+AutoAdjustSize.h"
#import "GP_ServiceRequest.h"
#import "GP_LoadingIndicateView.h"

//----------------------------------------------------------

@interface GP_VideoDetailView() <MyLoadingIndicateViewDelegate>

@property(nonatomic,strong,readonly) GP_ServiceRequest  * getVideoDetailService;

@property(nonatomic,strong,readonly) GP_LoadingIndicateView * loadingIndicateView;

@property(nonatomic,strong) MyRefreshControl * refreshControl;

- (void)_refreshHandle;

//更新视图
- (void)_updateView;

//更新数据
- (void)_updateDate;

@end

//----------------------------------------------------------

@implementation GP_VideoDetailView
{
    UIScrollView * _scrollView;
    
    UILabel * _titleLabel;
    UILabel * _typeLabel;
    UILabel * _updateTimeLabel;
    UILabel * _timeLabel;
    UILabel * _playTimesLabel;
    UILabel * _briefIntroLabel;
    
    GP_Video* _video;
}

@synthesize getVideoDetailService = _getVideoDetailService;
@synthesize loadingIndicateView = _loadingIndicateView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
 
    if (self) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 44.f, 0.f);
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        
        CGFloat offset = AspectScaleLenght(12.f);
        CGFloat width  = screenSize().width - 2 * offset;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset, 10.f, width, 22.f)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
        _titleLabel.textColor = defaultTitleTextColor;
        [_scrollView addSubview:_titleLabel];
        
        
#define initLabel(_lableName,Y)                                                        \
{                                                                                      \
    _lableName = [[UILabel alloc] initWithFrame:CGRectMake(offset, Y, width, 16.f)];   \
    _lableName.font = [UIFont systemFontOfSize:13.f];                                  \
    _lableName.textColor = defaultBodyTextColor;                                       \
    [_scrollView addSubview:_lableName];                                               \
}
    
        initLabel(_typeLabel,        52.f);
        initLabel(_updateTimeLabel,  71.f);
        initLabel(_timeLabel,        90.f);
        initLabel(_playTimesLabel,  109.f);
        initLabel(_briefIntroLabel, 145.f);
        _briefIntroLabel.numberOfLines = NSIntegerMax;
        
        //刷新控件
        _refreshControl = [[MyRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(_refreshHandle) forControlEvents:UIControlEventValueChanged];
        _refreshControl.textColor = defaultTitleTextColor;
        [_scrollView addSubview:_refreshControl];

    }
    
    return self;
}

- (void)refreshWithVideo:(GP_Video *)video
{
    _video = video;
    
    if (_video.hadUpdateDeatilInfo) {
        [self _updateView];
    }else{
        
        //开始加载
        _scrollView.hidden = YES;
        [self.loadingIndicateView showLoadingStatusWithTitle:@"获取视频信息中,请稍后..." detailText:nil];
        [self _updateDate];
    }
}

- (void)_updateDate
{
    if ([MyNetReachability currentNetReachabilityStatus] != kNotReachable) {
        //获取数据
        [self.getVideoDetailService startGetVideoDetailServiceWithVideoID:_video.ID];
    }else{
        
        if (!self.loadingIndicateView.isHidden) {
            [self.loadingIndicateView showNoNetworkStatus];
        }else{
            [self.refreshControl endRefreshing];
            showErrorMessage(self, nil, @"当前无可用的网络");
        }
    }
}

- (void)_refreshHandle
{
    [self _updateDate];
}

- (void)_updateView
{
    _titleLabel.text      = _video.title;
    _typeLabel.text       = [NSString stringWithFormat:@"类型：%@",_video.type];
    _updateTimeLabel.text = [NSString stringWithFormat:@"更新：%@",_video.updateTime];
    _playTimesLabel.text  = [NSString stringWithFormat:@"播放：%d",(int)_video.hits];
    _timeLabel.text       = [NSString stringWithFormat:@"时长：%@",
                             moviePlayDurationFormatterString(_video.duration,YES)];
    //简介
   [_briefIntroLabel setTextWithFitSizeFixedWidth:[NSString stringWithFormat:@"简介：%@",_video.description]];

    //设置
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.bounds), CGRectGetMaxY(_briefIntroLabel.frame));
}

- (GP_ServiceRequest *)getVideoDetailService
{
    if (!_getVideoDetailService) {
        _getVideoDetailService = [[GP_ServiceRequest alloc] init];
        
        __weak typeof(self) _weak_self = self;
        
        _getVideoDetailService.successBlock =
        
        ^ (ServiceRequestSerivceType type,id data){
            
            typeof(self) _self = _weak_self;
            
            [_self.refreshControl endRefreshing];
            [_self->_loadingIndicateView hiddenView];
            _self->_scrollView.hidden = NO;
            
            //更新数据
            [_self->_video updateDeatilInfo:data];
            [_self _updateView];
        };
        
        _getVideoDetailService.failBlock =
        
        ^ (ServiceRequestSerivceType type,NSError * error){
            
            typeof(self) _self = _weak_self;
            
            if (!_self.loadingIndicateView.isHidden) {
                [_self.loadingIndicateView showLoadingErrorStatusWithTitle:@"获取视频信息失败" detailText:@"点击页面重试"];
                _self->_scrollView.hidden = YES;
            }else{
                [_self.refreshControl endRefreshing];
            }
            
            showErrorMessage(_self, error, @"获取视频信息失败");
            
        };
    }
    
    return _getVideoDetailService;
}

- (GP_LoadingIndicateView *)loadingIndicateView
{
    if (!_loadingIndicateView) {
        
        _loadingIndicateView = [[GP_LoadingIndicateView alloc] initWithFrame:self.bounds];
        _loadingIndicateView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _loadingIndicateView.delegate = self;
        
        [self addSubview:_loadingIndicateView];
    }
    
    return _loadingIndicateView;
}

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    [self.loadingIndicateView showLoadingStatusWithTitle:@"获取视频信息中,请稍后..." detailText:nil];
    [self _updateDate];
}


@end
