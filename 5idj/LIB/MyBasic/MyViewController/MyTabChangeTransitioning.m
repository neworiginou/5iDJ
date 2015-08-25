//
//  MyTabChangeTransitioning.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-12.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "MyTabChangeTransitioning.h"
#include "MacroDef.h"

#define A_TAN_1_4  0.244979

@implementation MyTabChangeTransitioning
{
    TabChangeDirection           _direction;
    MyTabChangeTransitioningType _type;
    void(^_animation)();
}

- (id)init
{
    return [self initWithTabChangeDirection:TabChangeDirectionNext
                                       type:MyTabChangeTransitioningTypeTranslation
                                  animation:nil];
}

- (id)initWithTabChangeDirection:(TabChangeDirection)direction
{
    return [self initWithTabChangeDirection:direction
                                       type:MyTabChangeTransitioningTypeTranslation
                                  animation:nil];
}

- (id)initWithTabChangeDirection:(TabChangeDirection)direction
                            type:(MyTabChangeTransitioningType)type
                       animation:(void(^)())animation
{
    self = [super init];
    
    if (self) {
        _direction = direction;
        _animation = [animation copy];
        _type      = type;
        _transitionDuration = 0.4f;
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    UIViewController * toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView * containerView    = [transitionContext containerView];
    
    CGFloat viewWidth   = CGRectGetWidth(containerView.bounds);
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect finalFrame   = [transitionContext finalFrameForViewController:toVC];
    
    UIView * fromShadowView = nil;
    UIView * toShadowView = nil;
    
    if (_type == MyTabChangeTransitioningTypeRotation) {
        
        //设置旋转点
        CGFloat anchorPointY = CGRectGetWidth(initialFrame) * 2 / CGRectGetHeight(initialFrame) + 1.f;
        fromVC.view.layer.anchorPoint = CGPointMake(0.5f, anchorPointY);
        fromVC.view.center = CGPointMake(0.5f * CGRectGetWidth(initialFrame), CGRectGetHeight(initialFrame)* anchorPointY);
        
        toVC.view.frame = finalFrame;
        
    }else{
        
        fromVC.view.frame = initialFrame;
        toVC.view.frame   = CGRectOffset(finalFrame, _direction == TabChangeDirectionNext ? viewWidth : - viewWidth , 0.f);
        
        //设置阴影视图
        fromShadowView = [[UIView alloc] initWithFrame:fromVC.view.frame];
        fromShadowView.backgroundColor = BlackColorWithAlpha(0.6f);
        fromShadowView.alpha = 0.f;
        [containerView addSubview:fromShadowView];
        
    }
    
    
    toShadowView = [[UIView alloc] initWithFrame:toVC.view.frame];
    toShadowView.backgroundColor = BlackColorWithAlpha(0.6f);
    [containerView insertSubview:toShadowView belowSubview:fromVC.view];
    [containerView insertSubview:toVC.view belowSubview:toShadowView];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    toVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
#endif
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        //ios8以下SDK需如此不然会错乱
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
        toVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
#endif
        toVC.view.transform = CGAffineTransformIdentity;
        
        
        if (_type == MyTabChangeTransitioningTypeRotation) {
            
            //设置旋转角度
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            fromVC.view.transform = CGAffineTransformIdentity;
#endif
            fromVC.view.transform = (_direction == TabChangeDirectionPrev) ? CGAffineTransformMakeRotation(2 * A_TAN_1_4) :
            CGAffineTransformMakeRotation(- 2 * A_TAN_1_4);
            
        }else{
            
            fromVC.view.frame = CGRectOffset(initialFrame, (_direction == TabChangeDirectionNext) ? -viewWidth : viewWidth , 0.f);
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            fromVC.view.transform = CGAffineTransformIdentity;
#endif
            fromVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
        }
        
        
        toVC.view.frame      = finalFrame;
        fromShadowView.frame = fromVC.view.frame;
        toShadowView.frame   = finalFrame;
        
        fromShadowView.alpha = 1.f;
        toShadowView.alpha   = 0.f;
        
        
        //自定义动作
        if (_animation) {
            _animation();
        }
        
    } completion:^(BOOL finished){
        
        //移除
        [toShadowView removeFromSuperview];
        [fromShadowView removeFromSuperview];
        
        
        //还原
        fromVC.view.transform = CGAffineTransformIdentity;
        fromVC.view.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        fromVC.view.frame = initialFrame;
        
        toVC.view.transform = CGAffineTransformIdentity;
        
        //通知完成
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
}


@end
