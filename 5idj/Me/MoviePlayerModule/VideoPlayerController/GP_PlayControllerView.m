//
//  GP_PlayControllerView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-18.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_PlayControllerView.h"
#import <MediaPlayer/MediaPlayer.h>

//----------------------------------------------------------

//滑动事件类型
typedef NS_ENUM(NSUInteger, PCVPanGestureType) {
    PCVPanGestureTypeNone = 0,
    PCVPanGestureTypeChangeVolum,       //改变声音大小
    PCVPanGestureTypeChangeBrightness,  //亮度调节
    PCVPanGestureTypeChangePlayDuration //改变播放时间
    
};

//手势改变播放进度的方向
typedef NS_ENUM(NSUInteger, PCVChangePlayDurationDirection) {
    PCVChangePlayDurationDirectionPrev,
    PCVChangePlayDurationDirectionNext
};

//----------------------------------------------------------

@interface GP_PlayControllerView() <
                                    UIGestureRecognizerDelegate
                                   >

//----------------------------------------------------------
- (void)_backButtonHandle:(id)sender;

- (void)_playProgressBarValueChange:(id)sender;

- (void)_playButtonHandle:(id)sender;

- (void)_zoomButtonHandle:(id)sender;

//----------------------------------------------------------


@property(nonatomic) BOOL contentHidden;

- (void)_setContentHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)_timeToHiddenContent;


//手势相关
//----------------------------------------------------------

//点击手势识别
- (void)_tapGestureHandle:(UITapGestureRecognizer *)sender;

//滑动手势识别
- (void)_panGestureHandle:(UIPanGestureRecognizer *)sender;

//缩放手势识别
- (void)_pinchGestureHandle:(UIPinchGestureRecognizer *)sender;

@property(nonatomic) BOOL playDurationViewHidden;

- (void)_setPlayDurationViewHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)_setGesturePlayDuration:(NSTimeInterval)gestureplayDuration;

- (void)_setChangePlayDurationDirection:(PCVChangePlayDurationDirection)direction;

- (void)_cancelPanGestureEvent;

//UI更新相关
//----------------------------------------------------------

//更新进度的UI，隐藏时不更新
- (void)_updateDurationUI;

@end

//----------------------------------------------------------

@implementation GP_PlayControllerView
{
    
//视图
//----------------------------------------------------------

    //内容视图
    UIView * _contentView;
    
    //控制元素视图
    UIView * _controlItemView;
    
    //标题视图
    UIView * _titleView;
    
    //下部控制栏视图
    UIView * _bottomControllerBarView;
    
    //返回按钮
    UIButton * _backButton;
    
    //标题标签
    UILabel * _titleLabel;
    
    //播放进度栏
    MyMediaProgressBar * _playProgressBar;
    
    //播放按钮
    UIButton  * _playButton;
    
    //缩放按钮
    UIButton  * _zoomButton;
    
    //播放时间标签
    UILabel   * _playDurationLabel;
    
    //总时长标签
    UILabel   * _videoTimeLabel;
    
    //底部的进度条
    UIProgressView * _bottomProgressBar;
    

//逻辑相关
//----------------------------------------------------------
 
    //是否在控制播放
    BOOL    _isControlPlay;
    
    //是否锁定播放时间标签，锁定后将不会更新其文字
    BOOL    _lockPlayTimeLabel;
    
    
//手势相关
//----------------------------------------------------------
    
    //滑动手势的类型
    PCVPanGestureType _panGestureType;
    
    //手势调节播放进度显示视图
    UIView * _gesturePlayDurationView;
    
    //手势调节播放进度标签
    UILabel * _gesturePlayDurationLabel;
    
    //方向视图
    UIImageView * _gestureDirectionImageView;
    
    //进度视图
    UIProgressView * _gestureProgressView;
    
    NSTimeInterval _gesturePlayDuration;
    
    PCVChangePlayDurationDirection _changePlayDurationDirection;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //内容视图
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentView];
        
        //控制元素视图
        _controlItemView = [[UIView alloc] initWithFrame:_contentView.bounds];
        _controlItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                            UIViewAutoresizingFlexibleHeight;
        _controlItemView.hidden = YES;
        [_contentView addSubview:_controlItemView];
        

        //标题视图
//-------------------------------------------
        
        //标题视图
        
        _titleView = [[UIView alloc] init];
        [_controlItemView addSubview:_titleView];

        if (GreaterThanIOS8System) {
            
            UIVisualEffectView * blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blurView.frame = _titleView.bounds;
            blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_titleView addSubview:blurView];
            
        }else{
            _titleView.backgroundColor = defaultBackIndicateColor;
        }
        
        //返回按钮
        _backButton = [[UIButton alloc] init];
        _backButton.hidden = YES;
        [_backButton setImage:ImageWithName(@"back_button") forState:UIControlStateNormal];
        [_backButton setShowsTouchWhenHighlighted:YES];
        [_backButton setAdjustsImageWhenHighlighted:NO];
        [_backButton addTarget:self action:@selector(_backButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_backButton];
        
        //标题标签
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17.f];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleView addSubview:_titleLabel];
        
        
        //下端控制视图
//-------------------------------------------
        
        _bottomControllerBarView = [[UIView alloc] init];
        [_controlItemView addSubview:_bottomControllerBarView];
        
        if (GreaterThanIOS8System) {
            
            UIVisualEffectView * blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blurView.frame = _bottomControllerBarView.bounds;
            blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_bottomControllerBarView addSubview:blurView];
        }else{
            _bottomControllerBarView.backgroundColor = defaultBackIndicateColor;
        }
        
        //播放按钮
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 45.f, 45.f)];
        [_playButton setShowsTouchWhenHighlighted:YES];
        [_playButton setAdjustsImageWhenHighlighted:NO];
        [_playButton addTarget:self action:@selector(_playButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomControllerBarView addSubview:_playButton];
        [self setPlayButtonStatus:PCVPlayButtonStatusPlay];
        
        //播放时间标签
        _playDurationLabel = [[UILabel alloc] init];
        _playDurationLabel.font = [UIFont systemFontOfSize:11.f];
        _playDurationLabel.textColor = [UIColor whiteColor];
        _playDurationLabel.textAlignment = NSTextAlignmentRight;
        _playDurationLabel.text = @"00:00:00";
        [_bottomControllerBarView addSubview:_playDurationLabel];
        
        
        //播放进度条
        _playProgressBar = [[MyMediaProgressBar alloc] init];
        [_playProgressBar setStepValueInternal:1];
        [_playProgressBar addTarget:self action:@selector(_playProgressBarValueChange:) forControlEvents:UIControlEventValueChanged];
        [_playProgressBar setGlowTrackColor:self.tintColor];
        [_bottomControllerBarView addSubview:_playProgressBar];
        
        
        //总时间标签
        _videoTimeLabel = [[UILabel alloc] init];
        _videoTimeLabel.font = [UIFont systemFontOfSize:11.f];
        _videoTimeLabel.textColor = [UIColor whiteColor];
        _videoTimeLabel.text = @"00:00:00";
        [_bottomControllerBarView addSubview:_videoTimeLabel];
        
        
        //缩放按钮
        _zoomButton = [[UIButton alloc] init];
        [_zoomButton setImage:ImageWithName(@"zoomout_icon") forState:UIControlStateNormal];
        _zoomButton.showsTouchWhenHighlighted = YES;
        _zoomButton.adjustsImageWhenHighlighted = NO;
        [_zoomButton addTarget:self action:@selector(_zoomButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_zoomButton];

        //下端进度条
//-------------------------------------------
        
        _bottomProgressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _bottomProgressBar.hidden = YES;
        _bottomProgressBar.trackTintColor = _playProgressBar.trackBGColor;
        _bottomProgressBar.progressTintColor = self.tintColor;
        [self addSubview:_bottomProgressBar];
        
      
        //手势控制视图
//-------------------------------------------
        
        _gesturePlayDurationView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 130.f, 70.f)];
        _gesturePlayDurationView.alpha = 0.f;
        _gesturePlayDurationView.backgroundColor = BlackColorWithAlpha(0.7f);
        _gesturePlayDurationView.clipsToBounds = YES;
        _gesturePlayDurationView.layer.borderColor = [UIColor whiteColor].CGColor;
        _gesturePlayDurationView.layer.borderWidth = 1.f;
        _gesturePlayDurationView.layer.cornerRadius = 10.f;
        [self addSubview:_gesturePlayDurationView];
        
        //方向提示图片
        _gestureDirectionImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"nexttrack_icon")];
        _gestureDirectionImageView.frame = CGRectMake(50.f, 10.f, 30.f, 20.f);
        [_gesturePlayDurationView addSubview:_gestureDirectionImageView];
        
        //进度
        _gestureProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _gestureProgressView.frame = CGRectMake(10.f, 40.f, 110.f, 2.f);
        _gestureProgressView.progressTintColor = self.tintColor;
        _gestureProgressView.trackTintColor = [UIColor whiteColor];
        [_gesturePlayDurationView addSubview:_gestureProgressView];
        
        //标签
        _gesturePlayDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 45.f, 120.f, 20.f)];
        _gesturePlayDurationLabel.font = [UIFont systemFontOfSize:13.f];
        _gesturePlayDurationLabel.textColor = [UIColor whiteColor];
        _gesturePlayDurationLabel.textAlignment = NSTextAlignmentCenter;
        [_gesturePlayDurationView addSubview:_gesturePlayDurationLabel];
        
        
        //手势
//-------------------------------------------
        [self _setUpGestureRecognizer];
        
    }
    return self;
}

- (void)_setUpGestureRecognizer
{
    //单击
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureHandle:)];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    //双击
    UITapGestureRecognizer * doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureHandle:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    
    //双击需要单击失败
    [tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    
    //滑动手势识别
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureHandle:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    
    //缩放手势识别
    UIPinchGestureRecognizer * pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_pinchGestureHandle:)];
    pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:pinchGestureRecognizer];
}


- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    UIColor * tintColor = self.tintColor;
    
    _gestureProgressView.progressTintColor = tintColor;
    _playProgressBar.glowTrackColor        = tintColor;
    _bottomProgressBar.progressTintColor   = tintColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGFloat boundsWidth = CGRectGetWidth(bounds);
    
    if (_fullScreenShow) {
        
        //标题视图
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
        _titleView.frame  = CGRectMake(0.f, 0.f, boundsWidth, 65.f);
        _backButton.frame = CGRectMake(0.f, 20.f, 45.f, 45.f);
        _titleLabel.frame = CGRectMake(45.f, 20.f, boundsWidth - 95.f, 45.f);
#else
        if (!GreaterThanIOS8System) {
            _titleView.frame  = CGRectMake(0.f, 0.f, boundsWidth, 65.f);
            _backButton.frame = CGRectMake(0.f, 20.f, 45.f, 45.f);
            _titleLabel.frame = CGRectMake(45.f, 20.f, boundsWidth - 95.f, 45.f);            
        }else{
            _titleView.frame  = CGRectMake(0.f, 0.f, boundsWidth, 55.f);
            _backButton.frame = CGRectMake(0.f, 10.f, 45.f, 45.f);
            _titleLabel.frame = CGRectMake(45.f, 10.f, boundsWidth - 95.f, 45.f);
        }
#endif
        
        _playDurationLabel.frame = CGRectMake(45.f, 0.f, 45.f, 45.f);
        _playProgressBar.frame   = CGRectMake(90.f, 0.f, boundsWidth - 140.f, 45.f);
        _videoTimeLabel.frame    = CGRectMake(boundsWidth - 50.f, 0.f, 45.f, 45.f);

    }else{
        _titleView.frame  = CGRectMake(0.f, 0.f, boundsWidth, 30.f);
        _titleLabel.frame = CGRectMake(0.f, 0.f, boundsWidth, 30.f);
        
        _playDurationLabel.frame = CGRectMake(50.f, 0.f, 45.f, 25.f);
        _playProgressBar.frame   = CGRectMake(40.f, 10.f, boundsWidth - 80.f, 35.f);
        _videoTimeLabel.frame    = CGRectMake(boundsWidth - 90.f, 0.f, 45.f, 25.f);
    }
    
    //底下控制条视图
    _bottomControllerBarView.frame = CGRectMake(0.f, CGRectGetHeight(bounds) - 45.f, boundsWidth, 45.f);
    _zoomButton.frame              = CGRectMake(boundsWidth - 45.f , CGRectGetHeight(bounds) - 45.f, 45.f, 45.f);
    
    //手势控制播放视图
    _gesturePlayDurationView.frame = CGRectMake((boundsWidth - 130.f) * 0.5f, 80.f, 130.f, 70.f);
    
    //下端进度条
    _bottomProgressBar.frame       = CGRectMake(0.f, CGRectGetHeight(bounds) - 2.f, boundsWidth, 2.f);
}


//----------------------------------------------------------

- (void)setPlayButtonStatus:(PCVPlayButtonStatus)playButtonStatus
{
    if (playButtonStatus == PCVPlayButtonStatusPlay) {
        [_playButton setImage:ImageWithName(@"play_icon") forState:UIControlStateNormal];
    }else{
        [_playButton setImage:ImageWithName(@"pause_icon") forState:UIControlStateNormal];
    }
}

- (void)setFullScreenShow:(BOOL)fullScreenShow
{
    if (_fullScreenShow != fullScreenShow) {
        
        _fullScreenShow = fullScreenShow;
        
        if (!_fullScreenShow) {
            
            _backButton.hidden = YES;
            _zoomButton.hidden = NO;
            _bottomProgressBar.hidden = !self.contentHidden || !_isControlPlay;
            
            [self _cancelPanGestureEvent];
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
#else
            if (!GreaterThanIOS8System) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
            }
#endif
            
        }else{
            
            _backButton.hidden = NO;
            _zoomButton.hidden = YES;
            _bottomProgressBar.hidden = YES;
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            [[UIApplication sharedApplication] setStatusBarHidden:self.contentHidden];
#else
            if (!GreaterThanIOS8System) {
                [[UIApplication sharedApplication] setStatusBarHidden:self.contentHidden];
            }
#endif
            
        }
    }
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setVideoDuration:(NSTimeInterval)videoDuration
{
    _videoDuration = videoDuration;
    
    _playProgressBar.maxValue   = videoDuration;
    _videoTimeLabel.text        = moviePlayDurationFormatterString(videoDuration,NO);
}

- (void)setLoadDuration:(NSTimeInterval)loadDuration
{
    if (_loadDuration != loadDuration) {
        _loadDuration = loadDuration;
        
        if (!self.contentHidden) {
            [_playProgressBar setLoadedValue:loadDuration animated:NO];
        }
    }
}

- (void)setPlayDuration:(NSTimeInterval)playDuration
{
    playDuration = MAX(0.f, playDuration);
    
    if (_playDuration != playDuration) {
        _playDuration = playDuration;
        
        if (!self.contentHidden) {
            if (!_lockPlayTimeLabel) {
                [_playProgressBar setValue:playDuration animated:NO];
                _playDurationLabel.text = moviePlayDurationFormatterString(playDuration,NO);
            }
        }
         _bottomProgressBar.progress = _playDuration / _videoDuration;
    }
}

- (void)_updateDurationUI
{
    [_playProgressBar setLoadedValue:_loadDuration animated:NO];
    [_playProgressBar setValue:_playDuration animated:NO];
    
    _playDurationLabel.text = moviePlayDurationFormatterString(_playDuration,NO);
}

- (void)startControlPlay
{
    if (!_isControlPlay) {
        _isControlPlay = YES;
        
        _controlItemView.hidden = NO;
        
        [self performSelector:@selector(_timeToHiddenContent) withObject:nil afterDelay:3.f];
    }
}

- (void)endControlPlay
{
    if (_isControlPlay) {
        _isControlPlay = NO;
        
        [self _reset];
    }
}

- (void)_reset
{
    _lockPlayTimeLabel = NO;
    _panGestureType    = PCVPanGestureTypeNone;
    _controlItemView.hidden     = YES;
    _bottomProgressBar.hidden   = YES;
    
    self.playDurationViewHidden = YES;
    self.contentHidden          = NO;
    self.playDuration  = 0.f;
    self.loadDuration  = 0.f;
    self.videoDuration = 0.f;
    
    [self setPlayButtonStatus:PCVPlayButtonStatusPlay];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeToHiddenContent) object:nil];
}



#pragma mark - about view
//----------------------------------------------------------

- (BOOL)contentHidden
{
    return _contentView.alpha == 0.f;
}

- (void)setContentHidden:(BOOL)contentHidden
{
    [self _setContentHidden:contentHidden animated:NO];
}

- (void)_setContentHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (self.contentHidden != hidden) {
        
        _bottomProgressBar.hidden = !hidden || _fullScreenShow;
        
        //显示时更新UI
        if (!hidden) {
            [self _updateDurationUI];
        }
        
        if (animated) {
            
            [UIView animateWithDuration:0.3f animations:^{
                _contentView.alpha = hidden ? 0.f : 1.f;
            }];
            
        }else{
            _contentView.alpha = hidden ? 0.f : 1.f;
        }
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
        if (_fullScreenShow) {
            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
        }
#else
        if (!GreaterThanIOS8System && _fullScreenShow) {
            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
        }
        
#endif
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeToHiddenContent) object:nil];
        
        if (!hidden) {
            //3s后消失
            [self performSelector:@selector(_timeToHiddenContent) withObject:nil afterDelay:3.f];
        }

        
    }
}

- (void)_timeToHiddenContent
{
    if ([self _highlightOfBarView]) {
        [self performSelector:@selector(_timeToHiddenContent) withObject:nil afterDelay:3.f];
    }else{
        [self _setContentHidden:YES animated:YES];
    }
}


- (BOOL)_highlightOfBarView
{
    return  _playProgressBar.isDragging ||
            _playButton.isHighlighted   ||
            _zoomButton.isHighlighted   ||
            _backButton.isHighlighted;
}

- (void)_playProgressBarValueChange:(id)sender
{
    NSTimeInterval nextPlayDuration = _playProgressBar.value;
    
    //移动过程中对进度条上锁
    _lockPlayTimeLabel = YES;
    
    _playDurationLabel.text = moviePlayDurationFormatterString(nextPlayDuration,NO);
    
    if(!_playProgressBar.isDragging){
        //结束移动解锁
        _lockPlayTimeLabel = NO;
        
        [self.delegate playControllerView:self willChangePlayDuration:nextPlayDuration];
    }
}

- (BOOL)playDurationViewHidden
{
    return _gesturePlayDurationView.alpha == 0.f;
}

- (void)setPlayDurationViewHidden:(BOOL)playDurationViewHidden
{
    [self _setPlayDurationViewHidden:playDurationViewHidden animated:NO];
}


- (void)_setPlayDurationViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (self.playDurationViewHidden != hidden) {
        
        if (animated) {
            
            [UIView animateWithDuration:0.4f animations:^{
                _gesturePlayDurationView.alpha = hidden ? 0.f : 1.f;
            }];
            
        }else{
            _gesturePlayDurationView.alpha = hidden ? 0.f : 1.f;
        }
    }
}

- (void)_setGesturePlayDuration:(NSTimeInterval)gestureplayDuration
{
    gestureplayDuration = ChangeInMinToMax(gestureplayDuration,0,_videoDuration);
    
    if (_gesturePlayDuration != gestureplayDuration) {
        _gesturePlayDuration = gestureplayDuration;
        
        _gesturePlayDurationLabel.text = [NSString stringWithFormat:@"%@/%@",moviePlayDurationFormatterString(_gesturePlayDuration,NO), _videoTimeLabel.text];
        _gestureProgressView.progress = _gesturePlayDuration / _videoDuration;
    }
}

- (void)_setChangePlayDurationDirection:(PCVChangePlayDurationDirection)direction
{
    if (_changePlayDurationDirection != direction) {
        _changePlayDurationDirection = direction;
        
        if (direction == PCVChangePlayDurationDirectionNext) {
            _gestureDirectionImageView.image = ImageWithName(@"nexttrack_icon");
        }else{
            _gestureDirectionImageView.image = ImageWithName(@"prevtrack_icon");
        }
        
    }
}

#pragma mark - delegate
//----------------------------------------------------------


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!_isControlPlay || (!_fullScreenShow && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])) {
        return NO;
    }
    
    return YES;
}

#pragma mark - event
//----------------------------------------------------------


- (void)_playButtonHandle:(id)sender
{
    [self.delegate playControllerViewDidTapPlayButton:self];
}

- (void)_backButtonHandle:(id)sender
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeToHiddenContent) object:nil];
    
    [self.delegate playControllerViewDidTapBackButton:self];
}

- (void)_zoomButtonHandle:(id)sender
{
    [self.delegate playControllerViewDidTapZoomButton:self];
}

- (void)_tapGestureHandle:(UITapGestureRecognizer *)sender
{
    if (sender.numberOfTapsRequired == 1) {
        //隐藏/显示控制栏
        [self _setContentHidden:!self.contentHidden animated:YES];
    }else{
        //变换缩放模式
        [self.delegate playControllerViewDidChangeScalingMode:self];
    }
}

- (void)_panGestureHandle:(UIPanGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    
    if (state == UIGestureRecognizerStateBegan) {
        
        //判断移动方向，确定手势类型
        CGPoint velocity = [sender velocityInView:self];
        
        if (fabsf(velocity.x) > fabsf(velocity.y) ){
            
            //左右移动改变播放进度
            _panGestureType = PCVPanGestureTypeChangePlayDuration;
            
            //显示
            self.playDurationViewHidden = NO;
            [self _setGesturePlayDuration:_playDuration];
            
        }else{
            
            _panGestureType = fabsf([sender locationInView:self].x) > CGRectGetMidX(self.bounds) ?PCVPanGestureTypeChangeVolum : PCVPanGestureTypeChangeBrightness;
        }
    }else if (state == UIGestureRecognizerStateChanged){
        
        CGPoint translation = [sender translationInView:self];
        
        switch (_panGestureType) {
                
            case PCVPanGestureTypeChangeVolum: //改变声音
                
                if (translation.y != 0) {
                    
                    //计算声音改变的增量
                    CGFloat detal = - 1.5f * translation.y / CGRectGetHeight(self.frame);
                    
                    //设置声音
                    
                    MPMusicPlayerController * appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
                    
                    //标准化
                    float volume = appMusicPlayer.volume + detal;
                    volume = ChangeInMinToMax(volume,0.f,1.f);
                    
                    //设置声音大小
                    appMusicPlayer.volume = volume;
                    
                }
                break;
                
            case PCVPanGestureTypeChangeBrightness://改变亮度
                
                if (translation.y != 0) {
                    
                    //计算亮度改变的增量
                    CGFloat detal = - 1.5f * translation.y / CGRectGetHeight(self.frame);

                    //设置亮度
                    MyBrightnessManager *brightnessManager = [MyBrightnessManager new];
                    CGFloat brightness = [brightnessManager brightness] + detal;
                    brightness = ChangeInMinToMax(brightness, 0.f, 1.f);
                    [brightnessManager setBrightness:brightness];
                }
                
                break;
            
            case PCVPanGestureTypeChangePlayDuration: //改变播放进度
                
                //设置播放进度
                if (translation.x != 0) {
                    
                    //半高
                    CGFloat halfHeight = CGRectGetMidY(self.bounds);
                    
                    //敏感度
                    float sensetive = 1.f - (fabsf(halfHeight - [sender locationInView:self].y) / halfHeight);
                    
                    //设置方向
                    [self _setChangePlayDurationDirection:(translation.x > 0) ? PCVChangePlayDurationDirectionNext : PCVChangePlayDurationDirectionPrev];
                    
                    //设置播放进度
                    [self _setGesturePlayDuration:_gesturePlayDuration + translation.x * 3.f * sensetive];
                }
                
                break;
            
            default:
                break;
        }
        
        //偏移清零
        [sender setTranslation:CGPointZero inView:self];
        
    }else if(state == UIGestureRecognizerStateEnded){
        
        if (_panGestureType == PCVPanGestureTypeChangePlayDuration) {
            //通知进度改变
            [self.delegate playControllerView:self willChangePlayDuration:_gesturePlayDuration];
            [self _setPlayDurationViewHidden:YES animated:YES];
        }
        
        _panGestureType = PCVPanGestureTypeNone;
    }else{
        [self _cancelPanGestureEvent];
    }
}

- (void)_cancelPanGestureEvent
{
    if (_panGestureType == PCVPanGestureTypeChangePlayDuration) {
        self.playDurationViewHidden = YES;
        _panGestureType = PCVPanGestureTypeNone;
    }
}

- (void)_pinchGestureHandle:(UIPinchGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    
    if (state == UIGestureRecognizerStateChanged) {
        [self.delegate playControllerView:self changingScaleFactor:[sender scale]];
    }else if (state == UIGestureRecognizerStateEnded){
        [self.delegate playControllerView:self endChangeScaleFactor:[sender scale]];
    }else if (state == UIGestureRecognizerStateCancelled){
        [self.delegate playControllerViewCancleChangeScaleFactor:self];
    }
}


@end
