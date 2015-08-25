//
//  GP_VideoPlayerController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-2-27.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoPlayerController.h"
#import "GP_PlayHistoryManager.h"
#import "GP_PlayControllerView.h"
#import "GP_VideoLoadIndicatorView.h"
#import "GP_ServiceRequest.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


//----------------------------------------------------------

#define PlayVideoDebugLog(_format,...)  DebugLog(@"PlayVideoDomain",_format, ##__VA_ARGS__)

//----------------------------------------------------------
@interface _GP_VideoView : UIView

- (id)initWithVideoView:(UIView *)videoView;

@property(nonatomic) CGSize naturalSize;

@property(nonatomic) MyScaleMode scaleMode;

- (void)setScaleMode:(MyScaleMode)scaleMode animated:(BOOL)animated;

@property(nonatomic) float  scaleFactor;

- (void)setScaleFactor:(float)scaleFactor animated:(BOOL)animated;

//重置
- (void)reset;

@end

//----------------------------------------------------------

@implementation _GP_VideoView
{
    UIView * _clipsView;
    
    UIView * _videoView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _scaleMode   = MyScaleModeAspectFit;
        _scaleFactor = 1.f;
        _naturalSize = CGSizeZero;
        
        _clipsView = [[UIView alloc] init];
        _clipsView.clipsToBounds = YES;
        [self addSubview:_clipsView];
        
        self.backgroundColor = [UIColor blackColor];
        self.hidden = YES;
    }
    
    return self;
}

- (id)initWithVideoView:(UIView *)videoView
{
    self = [super init];
    
    if (self) {
        
        _videoView = videoView;
        [_clipsView addSubview:videoView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //更新
    [self _updateVideoViewFrame];
}

- (void)_updateVideoViewFrame
{
     if (_videoView) {
        
         //视图大小
         CGSize boundsSize= self.bounds.size;
         _clipsView.center = CGPointMake(boundsSize.width * 0.5f, boundsSize.height * 0.5f);
         _clipsView.bounds = CGRectMake(0.f, 0.f, boundsSize.width * _scaleFactor, boundsSize.height * _scaleFactor);
         
         boundsSize = _clipsView.bounds.size;
         
         //视频视图大小
         CGSize videoViewSize = sizeWithScaleMode(_naturalSize, boundsSize, _scaleMode);
         
         //设置位置
         _videoView.center = CGPointMake(boundsSize.width * 0.5f, boundsSize.height * 0.5f);
         _videoView.bounds = CGRectMake(0.f, 0.f, videoViewSize.width,videoViewSize.height);
     }
}

- (void)setScaleFactor:(float)scaleFactor
{
    [self setScaleFactor:scaleFactor animated:NO];
}

- (void)setScaleFactor:(float)scaleFactor animated:(BOOL)animated
{
    scaleFactor = MAX(0.f, scaleFactor);
    
    if (_scaleFactor != scaleFactor) {
        _scaleFactor = scaleFactor;
        
        if (animated) {
            [UIView animateWithDuration:0.3f animations:^{
                [self _updateVideoViewFrame];
            }];
        }else{
            [self _updateVideoViewFrame];
        }
    }
}

- (void)setNaturalSize:(CGSize)naturalSize
{
    if (!CGSizeEqualToSize(naturalSize, _naturalSize)) {
        _naturalSize = naturalSize;
        
        [self _updateVideoViewFrame];
    }
}

- (void)setScaleMode:(MyScaleMode)scaleMode
{
    [self setScaleMode:scaleMode animated:NO];
}

- (void)setScaleMode:(MyScaleMode)scaleMode animated:(BOOL)animated
{
    if (_scaleMode != scaleMode) {
        
        _scaleMode = scaleMode;
        
        if (animated) {
            
            [UIView animateWithDuration:0.3f animations:^{
                [self _updateVideoViewFrame];
            }];
            
        }else{
            [self _updateVideoViewFrame];
        }
    }
    
}

- (void)reset
{
    _scaleMode   = MyScaleModeAspectFit;
    _scaleFactor = 1.f;
    
    [self _updateVideoViewFrame];
}

@end


//----------------------------------------------------------
typedef NS_ENUM(NSInteger, VPCPlayStatus) {
    VPCPlayStatusNone,        //没播放
    VPCPlayStatusGetURL,      //正在获取URL
    VPCPlayStatusReadyToPlay, //准备去播放
    VPCPlayStatusPlay         //播放
};

//----------------------------------------------------------

@interface GP_VideoPlayerController () <
                                         PlayControllerViewDelegate,
                                         GP_ServiceRequestDelegate,
                                         GP_VideoLoadIndicatorViewDelegate,
                                         UIAlertViewDelegate
                                       >

//通知
- (void)moviePlayerPlaybackStateDidChange:(NSNotification *)notification;
- (void)moviePlayerLoadStateDidChange:(NSNotification *)notification;
- (void)movieDurationAvailable:(NSNotification *)notification;
- (void)moviePlayerReadyForDisplayDidChange:(NSNotification *)notification;
- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification;
- (void)movieNaturalSizeAvailable:(NSNotification *)notification;

//音乐输出设备改变
- (void)audioRouteChangeNotification:(NSNotification *)notification;


#if DEBUG

- (void)movieMediaTypesAvailable:(NSNotification *)notification;
- (void)movieSourceTypeAvailable:(NSNotification *)notification;
- (void)mediaPlaybackIsPreparedToPlayDidChange:(NSNotification *)notification;
- (void)moviePlayerNowPlayingMovieDidChange:(NSNotification *)notification;

#endif


//开始播放
- (void)_startPlay;

////更新播放进度
- (void)_updatePlayDuration;

//结束播放视频
- (void)_endPlayVideoWithFinish:(BOOL)finish;

//播放错误
- (void)_playErrorWithReason:(NSString *)reason;

//记录播放记录
- (void)_recordPlayHistory:(BOOL)finish;

//暂停播放视频
- (void)_pausePlayVideo;

//恢复播放视频
- (void)_resumePlayVideo;

//服务请求
@property(nonatomic,strong,readonly) GP_ServiceRequest * serviceRequest;

//开始获取视频URL
- (void)_startGetVideoURL;

//更新加载页面
- (void)_updateVideoLoadIndicatorView;

//网络改变通知
- (void)_networkStatusChangeNotification:(NSNotification *)notification;

//检测网络是否允许播放
- (BOOL)_checkNetworkPermitPlay;

//显示通过移动数据播放的警告
- (void)_showPlayViaWWANAlertView;

//隐藏通过移动数据播放的警告
- (void)_hiddenPlayViaWWANAlertView;

//模糊后的视频图像
//@property(nonatomic,strong,readonly) UIImage * brurredVideoImage;

//更新背景视图
- (void)_updateBackgroundImageView;

//应用进入后台通知
- (void)_applicationDidEnterBackgroundNotification:(NSNotification *)notification;

@end

//----------------------------------------------------------

@implementation GP_VideoPlayerController
{
    //视频
    GP_Video      * _video;
    
    //背景图像视图
    UIImageView   * _backgroundImageView;
    
    //模糊图像
    UIImage       * _brurredVideoImage;
    
    //视频视图
    _GP_VideoView * _videoView;
    
    //前景
    UIView * _foregrounpView;
    
    MPMoviePlayerController * _moviePlayerController;
    
    //播放控制器
    GP_PlayControllerView * _playControllerView;
    
    //加载提示视图
    GP_VideoLoadIndicatorView * _videoLoadIndicatorView;
    
    //播放类型
    VPCPlayStatus  _playStatus;
    
    //计时器
    NSTimer * _updatePlayDurationTimer;
    
    //视屏视图缩放因子，初始为1;
    float _videoViewScaleFactor;
    
    //警告视图
    UIAlertView  * _playViaWWANAlertView;
    
    //是否允许使用移动数据网访问
    BOOL           _permitPlayViaWWAN;
    
    //是否是第一次播放视频
    BOOL           _isFirstPlayVideo;

    //忽略playDurationChange改变
    BOOL           _ignorePlayDurationChange;
    
    //网络可用时忽视即不自动开始播放
    BOOL           _ignoreNetworkEnable;
    
    //忽视播放结束通知
    BOOL           _ignorePlayEndNotification;
    
}
@synthesize view           = _view;
@synthesize serviceRequest = _serviceRequest;

- (id)init
{
    self = [super init];
    
    if (self) {
        
        _playStatus           = VPCPlayStatusNone;
        _videoViewScaleFactor = 1.f;
        _isFirstPlayVideo     = YES;
        
        //视图
        _view = [[UIView alloc] init];
        _view.clipsToBounds = YES;
        
        //背景视图
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                                UIViewAutoresizingFlexibleWidth;
        [_view addSubview:_backgroundImageView];
        
        //视频控制器
        _moviePlayerController = [[MPMoviePlayerController alloc] init];
        _moviePlayerController.scalingMode = MPMovieScalingModeFill;
        _moviePlayerController.controlStyle = MPMovieControlStyleNone;
        
        //视频视图
        _videoView =  [[_GP_VideoView alloc] initWithVideoView:_moviePlayerController.view];
        _videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_view addSubview:_videoView];
        
        //前景
        _foregrounpView = [[UIView alloc] init];
        _foregrounpView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight;
        [_view addSubview:_foregrounpView];
        
        //播放控制器视图
        _playControllerView = [[GP_PlayControllerView alloc] init];
        _playControllerView.delegate = self;
        _playControllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                               UIViewAutoresizingFlexibleHeight;
        [_foregrounpView addSubview:_playControllerView];
        
        
        //加载指示器视图初始化
        _videoLoadIndicatorView = [[GP_VideoLoadIndicatorView alloc] init];
        _videoLoadIndicatorView.delegate = self;
        _videoLoadIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                                   UIViewAutoresizingFlexibleHeight;
        [_foregrounpView addSubview:_videoLoadIndicatorView];
      
        //添加通知
        {
            NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
            
            
#define AddObserver(_selectorName, _notificationName)           \
        [defaultCenter addObserver:self                         \
                          selector:@selector(_selectorName:)    \
                              name:_notificationName            \
                            object:_moviePlayerController]
            
            //添加通知
            AddObserver(moviePlayerPlaybackStateDidChange,
                        MPMoviePlayerPlaybackStateDidChangeNotification);
            AddObserver(moviePlayerLoadStateDidChange,
                        MPMoviePlayerLoadStateDidChangeNotification);
            AddObserver(movieDurationAvailable,
                        MPMovieDurationAvailableNotification);
            AddObserver(moviePlayerReadyForDisplayDidChange,
                        MPMoviePlayerReadyForDisplayDidChangeNotification);
            AddObserver(moviePlayerPlaybackDidFinish,
                        MPMoviePlayerPlaybackDidFinishNotification);
            AddObserver(movieNaturalSizeAvailable,
                        MPMovieNaturalSizeAvailableNotification);
#if DEBUG
            
            AddObserver(moviePlayerNowPlayingMovieDidChange,
                        MPMoviePlayerNowPlayingMovieDidChangeNotification);
            AddObserver(movieMediaTypesAvailable,
                        MPMovieMediaTypesAvailableNotification);
            AddObserver(movieSourceTypeAvailable,
                        MPMovieSourceTypeAvailableNotification);
            AddObserver(mediaPlaybackIsPreparedToPlayDidChange,
                        MPMediaPlaybackIsPreparedToPlayDidChangeNotification);
#endif
            
            //监听通知
            [defaultCenter addObserver:self selector:@selector(_networkStatusChangeNotification:) name:NetReachabilityChangedNotification object:nil];
            [defaultCenter addObserver:self selector:@selector(_applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            
            //声音输出路劲改变
            [defaultCenter addObserver:self selector:@selector(audioRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        }
    }
    
    return self;
}



- (void)dealloc
{
    [_backgroundImageView cancleLoadURLImage:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //隐藏
    if (_playViaWWANAlertView) {
        
        _playViaWWANAlertView.delegate = nil;
        [self _hiddenPlayViaWWANAlertView];
    }
}

//--------------------------------------------------

- (void)_updateBackgroundImageView
{
    [_backgroundImageView cancleLoadURLImage:NO];
    
    if (_fullScreen) {
        
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        _backgroundImageView.image = ImageWithName(@"MP_Background");
        
    }else{
        
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        if (_brurredVideoImage) {
            _backgroundImageView.image = _brurredVideoImage;
            
            _backgroundImageView.alpha = 0.f;
            [UIView animateWithDuration:0.3f animations:^{
                _backgroundImageView.alpha = 1.f;
            }];
            
        }else{
            
            typeof(self) __weak weak_self = self;
            
            NSInteger videoId = _video.ID;
            
            [_backgroundImageView setImageWithURL:_video.imageURL
                                 placeholderImage:nil
                                 progressViewMode:ImageLoadProgressViewModeNone
                                   loadFailPolicy:ImageLoadFailPolicyAutoReloadWhenNoNet
                                          success:^(UIImageView * imageView,UIImage * image){
                                              
                                              //设置时会取消原有的请求所以无须判断是否是同一请求
                                              imageView.image = nil;
                                              
                                              //模糊化
                                              [imageView setImageToBlur:image
                                                             blurRadius:50.f
                                                              tintColor:BlackColorWithAlpha(0.2f)
                                                        completionBlock:^{
                                              
                                                            typeof(self) _self = weak_self;
                                                  
                                                            if (_self->_video.ID == videoId) {
                                                                
                                                                _self->_brurredVideoImage = _self->_backgroundImageView.image;
                                                                
                                                                //更新背景图片
                                                                [_self _updateBackgroundImageView];
                                                            }
                                                        }];
                                              
                                          } failure:nil];
        }
    }
    
}

- (void)movieNaturalSizeAvailable:(NSNotification *)notification
{
    PlayVideoDebugLog(@"MovieNaturalSizeAvailable!  Size is %f x %f",_moviePlayerController.naturalSize.width,_moviePlayerController.naturalSize.height);
    
    //大小
    _videoView.naturalSize = _moviePlayerController.naturalSize;
}

#if DEBUG

//--------------------------------------------------
- (void)mediaPlaybackIsPreparedToPlayDidChange:(NSNotification *)notification
{
    PlayVideoDebugLog(@"MediaPlaybackIsPreparedToPlay! PreparedToPlay is %@",_moviePlayerController.isPreparedToPlay ? @"YES":@"NO");
}


- (void)movieSourceTypeAvailable:(NSNotification *)notification
{
    PlayVideoDebugLog(@"MovieSourceTypeAvailable!");
}

- (void)movieMediaTypesAvailable:(NSNotification *)notification
{
    PlayVideoDebugLog(@"MovieMediaTypesAvailable!");
}


- (void)moviePlayerNowPlayingMovieDidChange:(NSNotification *)notification
{
    PlayVideoDebugLog(@"moviePlayerNowPlayingMovieDidChange!");
}


#endif


- (void)movieDurationAvailable:(NSNotification *)notification
{
    [_playControllerView setVideoDuration:_moviePlayerController.duration];
    PlayVideoDebugLog(@"MovieDurationAvailable!  Duration is %f",_moviePlayerController.duration);
}


- (void)moviePlayerReadyForDisplayDidChange:(NSNotification *)notification
{
    PlayVideoDebugLog(@"MoviePlayerReadyForDisplayDidChange! ReadyForDisplay is %@",_moviePlayerController.readyForDisplay ? @"YES":@"NO");
    
    if (_moviePlayerController.readyForDisplay) {
    
        if (_playStatus == VPCPlayStatusReadyToPlay) {

            //设置显示
            _videoView.hidden = NO;
            
            //开始控制
            [_playControllerView startControlPlay];
            
            //设置计时器
            [_updatePlayDurationTimer invalidate];
            _updatePlayDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(_updatePlayDuration) userInfo:nil repeats:YES];
            _ignorePlayDurationChange = NO;
            
            //获取记录
            GP_VideoPlayRecord * record = [[GP_PlayHistoryManager defaultManager] recordForVideo:_video];
            
            //存在记录且未放完,则接着播放
            if (record && ![record.playFinish boolValue]) {
                
                //设置播放时间
                [_moviePlayerController setCurrentPlaybackTime:[record.playDuration doubleValue]];
                _playControllerView.playDuration = [record.playDuration doubleValue];
                
                showMessage(self.view, @"从上次退出时间继续播放", nil);
            }
            
            _playStatus = VPCPlayStatusPlay;
        }
        
    }else{
        
        //停止控制播放
        [_playControllerView endControlPlay];
        
        //定时器无效
        [_updatePlayDurationTimer invalidate];
        _updatePlayDurationTimer = nil;
    }
    
}

- (void)moviePlayerLoadStateDidChange:(NSNotification *)notification
{
    [self _updateVideoLoadIndicatorView];
}

- (void)moviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    switch (_moviePlayerController.playbackState) {
        case MPMoviePlaybackStatePlaying:
            [_playControllerView setPlayButtonStatus:PCVPlayButtonStatusPause];
            break;
            
        case MPMoviePlaybackStatePaused:
            [_playControllerView setPlayButtonStatus:PCVPlayButtonStatusPlay];
            break;
            
        default:
           break;
    }
    
    [self _updateVideoLoadIndicatorView];
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    PlayVideoDebugLog(@"MoviePlayerPlaybackDidFinish!");
    
    _videoView.hidden = YES;
    
  
    MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    
    if ( finishReason != MPMovieFinishReasonPlaybackError ) {
        PlayVideoDebugLog(@"Reason is PlaybackEnded!");
        
        if (!_ignorePlayEndNotification) {
            
            //结束播放
            [self _endPlayVideoWithFinish:_moviePlayerController.playbackState != MPMoviePlaybackStateStopped];
        }
        
    }else {
        
        [self _playErrorWithReason:@"视频播放失败"];
        
        PlayVideoDebugLog(@"Reason is Error");
    }
}

//-----------------------------------------------------

- (void)_updatePlayDuration
{
    if (_ignorePlayDurationChange) {
        _ignorePlayDurationChange = NO;
    }else{
        //更新播放进度
        [_playControllerView setPlayDuration:_moviePlayerController.currentPlaybackTime];
        [_playControllerView setLoadDuration:_moviePlayerController.playableDuration];
    }
    
}

- (void)_updateVideoLoadIndicatorView
{
    MPMovieLoadState loadState = _moviePlayerController.loadState;
    
    if (loadState & MPMovieLoadStateStalled) {
        [_videoLoadIndicatorView showLoadingVideo];
    }else if (loadState & MPMovieLoadStatePlaythroughOK){
        
        MPMoviePlaybackState playbackState = _moviePlayerController.playbackState;
       
        if (playbackState == MPMoviePlaybackStatePaused) {
            [_videoLoadIndicatorView showPlayButtonWithTitle:nil];
        }else{
            [_videoLoadIndicatorView hiddenView];
        }
    }
}

//-----------------------------------------------------

- (void)setFullScreen:(BOOL)fullScreen
{
    if (_fullScreen != fullScreen) {
        _fullScreen = fullScreen;
        
        //更新背景视图
        [self _updateBackgroundImageView];
        
        //设置控件状态
        [_playControllerView setFullScreenShow:fullScreen];
        
        //自动恢复播放
        if (_fullScreen && [GP_SettingItemManager boolValueForItme:GP_SettingItemAutoResumeWhenFullScreen] && !_playViaWWANAlertView) {
            [self resume];
        }
    }
}

- (void)resume
{
    if (_moviePlayerController.playbackState == MPMoviePlaybackStatePaused) {
        [_moviePlayerController play];
    }
}

- (void)pause
{
    [_moviePlayerController pause];
}

- (void)stop
{
    //停止
    [self _endPlayVideoWithFinish:NO];
}

- (void)playWithVideo:(GP_Video *)video
{
    NSParameterAssert(video != nil);
    
    //停止
    [self stop];
    
    //设置video
    _video = video;
    
    //更新背景视图
    _brurredVideoImage = nil;
    [self _updateBackgroundImageView];
    
    //设置标题
    [_playControllerView setTitle:_video.title];
    
    //第一次是否自动播放
    if ([GP_SettingItemManager boolValueForItme:GP_SettingItemAutoStartPlay] || !_isFirstPlayVideo) {
        [self _startPlay];
    }else{
        
        if ([MyNetReachability currentNetReachabilityStatus] == kNotReachable) {
            _ignoreNetworkEnable = YES;
            [_videoLoadIndicatorView showNoNetworkStatus];
        }else{
            [_videoLoadIndicatorView showPlayButtonWithTitle:nil];
        }
    }
    
    //标记为NO
    _isFirstPlayVideo = NO;
}


// -----------------------

- (void)_startPlay
{
    assert(_playStatus == VPCPlayStatusNone);
    
    //画面初始化
    _videoViewScaleFactor = 1.f;
    [_videoView reset];
    
    //开始获取视频URL
    [self _startGetVideoURL];
}

- (void)_startGetVideoURL
{
    if (_video) {
        
        _playStatus = VPCPlayStatusGetURL;
        
        //提示视图
        [_videoLoadIndicatorView showLoadingVideoURL];
        
        if ([self _checkNetworkPermitPlay]) {
            
            //获取视频URL
            [self.serviceRequest startGetVideoURLServiceWithVideoID:_video.ID];
        }
    }
}

- (GP_ServiceRequest *)serviceRequest
{
    if (!_serviceRequest) {
        _serviceRequest = [[GP_ServiceRequest alloc] init];
        _serviceRequest.delegate = self;
    }
    
    return _serviceRequest;
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didFailRequestWithError:(NSError *)error
{
    //播放出错
    _playStatus = VPCPlayStatusNone;
    
    [_videoLoadIndicatorView showPlayErroWithTitle:@"获取视频地址失败" detailText:[error localizedDescription]];
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didSuccessRequestWithData:(id)data
{
    //指示状态
    _playStatus = VPCPlayStatusReadyToPlay;
    
    //设置URL
    _moviePlayerController.contentURL = data;
    
    //开始播放
    [_moviePlayerController play];
    
    //指示开始加载视频
    [_videoLoadIndicatorView showLoadingVideo];
}


- (void)_recordPlayHistory:(BOOL)finish
{
    //需要记录当前播放时间
    if (_playStatus == VPCPlayStatusPlay && [GP_SettingItemManager boolValueForItme:GP_SettingItemSavePlayRecoder]) {
        
        //播放完成或者播放时间不为0
        if (finish || (int)_playControllerView.playDuration != 0 ) {
            
            //添加播放记录
            [[GP_PlayHistoryManager defaultManager] addRecord:_video
                                                 playDuration:_playControllerView.playDuration
                                                   playFinish:finish];
        }
    }
}


- (void)_endPlayVideoWithFinish:(BOOL)finish
{
    
    if (_playStatus == VPCPlayStatusPlay) {
        
        //统计事件
        [GP_AppDelegate sendPlayVideoEvent:_video duration:_playControllerView.playDuration];
        
        //记录播放记录
        [self _recordPlayHistory:finish];

        //停止播放
        _ignorePlayEndNotification = YES;
        _moviePlayerController.contentURL = nil;
        _ignorePlayEndNotification = NO;
        
        //播放完成，退出全屏
        if (finish && self.fullScreen) {
            [self.delegate videoPlayerController:self wantToFullScreenShow:NO];
        }
        
        
    }else if (_playStatus == VPCPlayStatusGetURL){
        
        [self.serviceRequest cancleService];
        
    }else if (_playStatus == VPCPlayStatusReadyToPlay){
        
        //停止播放
        _ignorePlayEndNotification = YES;
        _moviePlayerController.contentURL = nil;
        _ignorePlayEndNotification = NO;
    }
    
    _playStatus = VPCPlayStatusNone;
    
    [_videoLoadIndicatorView showPlayButtonWithTitle:nil];
}

- (void)_playErrorWithReason:(NSString *)reason
{
    //结束播放
    [self stop];
    
    //显示出错信息
    [_videoLoadIndicatorView showPlayErroWithTitle:reason detailText:nil];
}

- (void)_pausePlayVideo
{
    if (_playStatus == VPCPlayStatusPlay) {
        [self pause];
    }else{
        //停止
        [self stop];
    }
}

- (void)_resumePlayVideo
{
    if (_playStatus == VPCPlayStatusPlay) {
        [self resume];
    }else{
        _playStatus = VPCPlayStatusNone;
        [self _startPlay];
    }
}


- (void)_applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    //记录播放记录
    [self _recordPlayHistory:NO];
}

//-----------------------------------------------------

- (void)videoLoadIndicatorViewDidTapPlay:(GP_VideoLoadIndicatorView *)videoLoadIndicatorView
{
    [self _resumePlayVideo];
}

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    if (loadingIndicateView.contextTag == NoNetworkContextTag) {
        
        if (!_ignoreNetworkEnable) {
            [self _resumePlayVideo];
        }else{
            [_videoLoadIndicatorView showPlayButtonWithTitle:nil];
            _ignoreNetworkEnable = NO;
        }
    }
}

//-----------------------------------------------------

//AlertView
//-----------------------------------------------------

- (void)_networkStatusChangeNotification:(NSNotification *)notification
{
  if ([self _checkNetworkPermitPlay] && ![GP_SettingItemManager boolValueForItme:GP_SettingItemShowNetworkStatusChangeNofication]){
      
        showNetworkStatusMessage(nil);
    }
}

- (BOOL)_checkNetworkPermitPlay
{
    if ([GP_SettingItemManager boolValueForItme:GP_SettingItemShowAlertWhenPlayViaWWAN]) {
        
        NetworkStatus status = [MyNetReachability currentNetReachabilityStatus];
        
        if (status == kReachableViaWWAN ) {
            
            if (!_permitPlayViaWWAN) {
                
                if (_playStatus != VPCPlayStatusNone) {
                    
                    //显示警告
                    [self _showPlayViaWWANAlertView];
                    
                    //暂停
                    [self _pausePlayVideo];
                    
                }
                
                return NO;
            }
            
        }else if(status == kNotReachable){
            
            //隐藏警告
            [self _hiddenPlayViaWWANAlertView];
            
            //结束播放
            [self stop];

            //显示无可用网络
            [_videoLoadIndicatorView showNoNetworkStatus];
            
            return NO;
        }else{
            
            //隐藏警告
            [self _hiddenPlayViaWWANAlertView];
            
            return YES;
        }
    }
    
    return YES;
}

- (void)_showPlayViaWWANAlertView
{
    
    if (!_playViaWWANAlertView ) {
        
        _playViaWWANAlertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"当前处于蜂窝移动网络环境,播放视频会耗费大量手机流量。是否继续播放?" delegate:self cancelButtonTitle:@"不看了" otherButtonTitles:@"土豪不怕", nil];
        
        [_playViaWWANAlertView show];
    }
}

- (void)_hiddenPlayViaWWANAlertView
{
    if (_playViaWWANAlertView) {
        
        [_playViaWWANAlertView dismissWithClickedButtonIndex:[_playViaWWANAlertView firstOtherButtonIndex] animated:YES];
        
        _permitPlayViaWWAN = NO;
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == _playViaWWANAlertView) {
        
        if ([alertView cancelButtonIndex] != buttonIndex) {
            
            _permitPlayViaWWAN = YES;
            
            //恢复播放视频
            [self _resumePlayVideo];
            
        }else{
            
            //结束播放
            [self stop];
        }
        
        _playViaWWANAlertView = nil;
        
    }
}

//-----------------------------------------------------

- (void)playControllerViewDidTapBackButton:(GP_PlayControllerView *)playControllerView
{
//    [self.delegate videoPlayerControllerDidTapBack:self];
    
    if (self.fullScreen) {
        [self.delegate videoPlayerController:self wantToFullScreenShow:NO];
    }
//
////    [self playControllerViewDidTapZoomButton:playControllerView];
}

- (void)playControllerViewDidTapPlayButton:(GP_PlayControllerView *)playControllerView
{
    switch (_moviePlayerController.playbackState) {
        case MPMoviePlaybackStatePlaying:
            [_moviePlayerController pause];
            break;
            
        case MPMoviePlaybackStatePaused:
            [_moviePlayerController play];
            break;
            
        default:
            break;
    }
}

- (void)playControllerViewDidTapZoomButton:(GP_PlayControllerView *)playControllerView
{
    [self.delegate videoPlayerController:self wantToFullScreenShow:!self.fullScreen];
}

- (void)playControllerView:(GP_PlayControllerView *)playControllerView willChangePlayDuration:(NSTimeInterval)playDuration
{
    //下一秒短暂忽略改变，以免进度错乱跳跃
    _ignorePlayDurationChange = YES;
    _moviePlayerController.currentPlaybackTime = playDuration;
}

- (void)playControllerViewDidChangeScalingMode:(GP_PlayControllerView *)playControllerView
{
    //更改一个合适的缩放模式
    MyScaleMode scaleMode = (_videoView.scaleMode + 1) % 3;
    
    //更改模式
    [_videoView setScaleMode:scaleMode animated:YES];
}

- (void)playControllerView:(GP_PlayControllerView *)playControllerView changingScaleFactor:(float)scale
{
//    float actualScale      = _videoViewScaleFactor * scale;
//    _videoView.scaleFactor = scale;
    
    if (self.fullScreen) {
        
        if (scale < 1.f) {
            
            if (scale < 0.7f) {
                
                [self.delegate videoPlayerController:self wantToFullScreenShow:NO];
                _videoView.scaleFactor = 1.f;
                
            }else{
                _videoView.scaleFactor = scale;
            }
        }
        
    }else{
        
        if (scale > 1.f) {
            
            if (scale > 1.4f) {
                
                [self.delegate videoPlayerController:self wantToFullScreenShow:YES];
                _videoView.scaleFactor = 1.f;
                
            }else{
                _videoView.scaleFactor = scale;
            }
        }
        
    }
    
//    if (scale < 0.6f && self.fullScreen) {
//        [self.delegate videoPlayerController:self wantToFullScreenShow:NO];
//        _videoView.scaleFactor = 1.f;
//    }else if (scale > 1.4f && !self.fullScreen){
//        [self.delegate videoPlayerController:self wantToFullScreenShow:YES];
//        _videoView.scaleFactor = 1.f;
//    }
    
}

- (void)playControllerView:(GP_PlayControllerView *)playControllerView endChangeScaleFactor:(float)scale
{
//    float endScale = _videoViewScaleFactor * scale;
//    _videoViewScaleFactor = ChangeInMinToMax(endScale, 0.5f, 2.f);
//    [_videoView setScaleFactor:_videoViewScaleFactor animated:(endScale < 0.5f || endScale > 2.f)];
    
    [_videoView setScaleFactor:1.f animated:YES];
}

- (void)playControllerViewCancleChangeScaleFactor:(GP_PlayControllerView *)playControllerView
{
//    //返回初始值
//    [_videoView setScaleFactor:_videoViewScaleFactor animated:YES];
    
    [_videoView setScaleFactor:1.f animated:YES];
}

- (void)audioRouteChangeNotification:(NSNotification *)notification
{
    NSInteger routeChangeReason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    
    
    switch (routeChangeReason) {
            
//        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
//            
////            //暂停播放
////            if ([GP_SettingItemManager boolValueForItme:GP_SettingItemPauseWhenHeadphonesPulled]) {
////                [self pause];
////            }
//            
//            break;
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
     
            //恢复播放
            if ([GP_SettingItemManager boolValueForItme:GP_SettingItemResumeWhenHeadphonesPluggedIn]) {
                [self resume];
            }
            
            break;
            
        default:
            break;
    }
}


@end
