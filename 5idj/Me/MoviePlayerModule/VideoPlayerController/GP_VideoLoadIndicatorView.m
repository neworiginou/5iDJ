//
//  GP_VideoLoadIndicatorView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-18.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoLoadIndicatorView.h"

//----------------------------------------------------------

@interface GP_VideoLoadIndicatorView ()

@property(nonatomic,strong,readonly) UIButton * playButton;

- (void)_playButtonHandle;

@end

//----------------------------------------------------------

@implementation GP_VideoLoadIndicatorView
{
    BOOL _isAnimatingHidden;
}

@synthesize playButton = _playButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.titleLabelColor = [UIColor whiteColor];
        self.detailLabelColor = [UIColor whiteColor];
        self.activityIndicatorView.lineWidth = 2.f;
        self.activityIndicatorView.twoStepAnimation = YES;
        self.activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 45.f, 45.f);
    }
    return self;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        
        //播放按钮
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 75.f, 75.f)];
        [_playButton setImage:ImageWithName(@"play_big_normal_icon") forState:UIControlStateNormal];
        [_playButton setImage:ImageWithName(@"play_big_highlight_icon") forState:UIControlStateHighlighted];
        [_playButton addTarget:self action:@selector(_playButtonHandle) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _playButton;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_playButton && _playButton.superview) {
        return CGRectContainsPoint(_playButton.bounds, [_playButton convertPoint:point fromView:self]);
    }
    
    return NO;
}


- (void)showLoadingStatusWithTitle:(NSString *)title detailText:(NSString *)detailText
{
    _isAnimatingHidden = NO;
    [super showLoadingStatusWithTitle:title detailText:detailText];
}


- (void)showLoadingVideo
{
    [self showLoadingStatusWithTitle:@"正在缓冲视频..." detailText:nil];
}


- (void)showLoadingVideoURL
{
    [self showLoadingStatusWithTitle:@"正在获取视频地址..." detailText:nil];
}

- (void)showPlayErroWithTitle:(NSString *)title detailText:(NSString *)detailText
{
    self.playButton.transform = CGAffineTransformIdentity;
    self.playButton.alpha     = 1.f;
    
    [self showCustomViewStatusWithCustomView:self.playButton title:title detailText:detailText];
}


- (void)showPlayButtonWithTitle:(NSString *)title
{
    [self showPlayErroWithTitle:title detailText:nil];
}

- (void)showCustomViewStatusWithCustomView:(UIView *)customView title:(NSString *)title detailText:(NSString *)detailText
{
    _isAnimatingHidden = NO;
    
    [super showCustomViewStatusWithCustomView:customView title:title detailText:detailText];
    
}

- (void)showNoNetworkStatusWithImage:(UIImage *)image title:(NSString *)title detailText:(NSString *)detailText observerNetworkChange:(BOOL)observerNetworkChange
{
    _isAnimatingHidden = NO;
    
    [super showNoNetworkStatusWithImage:image
                                  title:title
                             detailText:detailText
                  observerNetworkChange:observerNetworkChange];
    
    
}

- (void)hiddenView
{
    if (_isAnimatingHidden) {
        return;
    }
    
    [super hiddenView];
    
    [_playButton.layer removeAllAnimations];
}


- (void)_playButtonHandle
{
    
    [UIView animateWithDuration:0.4f animations:^{
        
        _isAnimatingHidden = YES;
        
        self.playButton.transform = CGAffineTransformMakeScale(2.f, 2.f);
        self.playButton.alpha     = 0.f;
    
    } completion:^(BOOL finished){
        
        _isAnimatingHidden = NO;
        
        if (finished) {
            [self hiddenView];
        }
        
    }];
    
    [self.delegate videoLoadIndicatorViewDidTapPlay:self];
}


@end
