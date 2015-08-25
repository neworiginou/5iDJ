//
//  MySideViewControllerDefaultTransitioning.m
//  YHDemo
//
//  Created by Xuzhanya on 14-9-30.
//  Copyright (c) 2014年 hldw. All rights reserved.
//

#import "MySideViewControllerDefaultTransitioning.h"
#import "MySideViewController.h"
#import "MacroDef.h"

@interface MySideViewControllerDefaultTransitioning ()

@property(nonatomic,strong,readonly) UIView * blackShadowView;

@end


@implementation MySideViewControllerDefaultTransitioning

@synthesize blackShadowView = _blackShadowView;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.transitionDuration = 0.4f;
    }
    
    return self;
}

- (void)dealloc
{
    [_blackShadowView removeFromSuperview];
}

- (UIView *)blackShadowView
{
    if (!_blackShadowView) {
        _blackShadowView = [[UIView alloc] init];
        _blackShadowView.backgroundColor = BlackColorWithAlpha(0.6f);
    }
    
    return _blackShadowView;
}


- (NSTimeInterval)transitionDuration:(id<MySideViewControllerContextTransitioning>)transitionContext
{
    return self.transitionDuration;
}

- (void)startUpdateViewWithContext:(id <MySideViewControllerContextTransitioning>)transitionContext
{
    BOOL moveToCenter  = ([transitionContext toPosition] == MySideViewControllerPositionCenter);
    UIView  * sideView = moveToCenter ? [transitionContext fromView] : [transitionContext toView];
    
    self.blackShadowView.frame = sideView.frame;
    [[transitionContext containerView] insertSubview:self.blackShadowView aboveSubview:sideView];
    
    self.blackShadowView.alpha = moveToCenter ? 0.f : 1.f;
}

- (void)updateViewForProgress:(CGFloat)progress withContext:(id<MySideViewControllerContextTransitioning>)transitionContext
{
    BOOL moveToCenter = ([transitionContext toPosition] == MySideViewControllerPositionCenter);
    
    UIView  * centerView =  moveToCenter ? [transitionContext toView] : [transitionContext fromView];
    UIView  * sideView   = !moveToCenter ? [transitionContext toView] : [transitionContext fromView];
    
    if (moveToCenter) {
        
        CGFloat scale = 1.f - 0.2f * progress;
        sideView.transform = CGAffineTransformMakeScale(scale, scale);
        
        self.blackShadowView.alpha = progress;
    }else{
        
        CGFloat scale = 0.8f + 0.2f * progress;
        sideView.transform = CGAffineTransformMakeScale(scale, scale);
        
        self.blackShadowView.alpha = 1.f - progress;
    }
    
    CGRect centerFrame = [transitionContext initialFrameForView:centerView];
    CGFloat moveLength = CGRectGetMinX([transitionContext finalFrameForView:centerView]) - CGRectGetMinX(centerFrame);
    
    centerFrame.origin.x += (moveLength * progress);
    centerView.frame = centerFrame;
}

- (void)endUpdateViewWithContext:(id <MySideViewControllerContextTransitioning>)transitionContext
{
    [transitionContext toView].transform   = CGAffineTransformIdentity;
    [transitionContext fromView].transform = CGAffineTransformIdentity;
    
    [transitionContext fromView].frame = [transitionContext finalFrameForView:[transitionContext fromView]];
    [transitionContext toView].frame   = [transitionContext finalFrameForView:[transitionContext toView]];
    
    [self.blackShadowView removeFromSuperview];
}

- (void)cancleUpdateViewWithContext:(id <MySideViewControllerContextTransitioning>)transitionContext
{
    [transitionContext toView].transform   = CGAffineTransformIdentity;
    [transitionContext fromView].transform = CGAffineTransformIdentity;
    
    [transitionContext fromView].frame = [transitionContext initialFrameForView:[transitionContext fromView]];
    [transitionContext toView].frame   = [transitionContext initialFrameForView:[transitionContext toView]];
    
    [self.blackShadowView removeFromSuperview];
}

@end
