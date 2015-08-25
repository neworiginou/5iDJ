//
//  MyDimissAnimatedTransitioning.m
//  5idj
//
//  Created by Xuzhanya on 14/10/23.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "MyPresentAnimatedTransitioning.h"

@implementation MyPresentAnimatedTransitioning
{
    void(^_animations)();
}

- (id)init
{
    return [self initWithType:PresentAnimatedTransitioningTypePresent animations:nil];
}

- (id)initWithType:(PresentAnimatedTransitioningType)type
{
    return [self initWithType:type animations:nil];
}

- (id)initWithType:(PresentAnimatedTransitioningType)type animations:(void(^)(void))animations
{
    self = [super init];
    
    if (self) {
        _type = type;
        _animations = [animations copy];
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
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView * containerView = [transitionContext containerView];
    
    CGRect finalFrame   = [transitionContext finalFrameForViewController:toVC];
    
    UIView * maskView = [[UIView alloc] initWithFrame:containerView.bounds];
    maskView.backgroundColor = BlackColorWithAlpha(0.6f);
    
    if (self.type == PresentAnimatedTransitioningTypePresent) {
        
        [containerView addSubview:maskView];
        [containerView addSubview:toVC.view];
        
        maskView.alpha  = 0.f;
        toVC.view.frame = CGRectOffset(finalFrame, 0.f, CGRectGetHeight(finalFrame));
        
    }else{
        
        [containerView insertSubview:maskView  belowSubview:fromVC.view];
        [containerView insertSubview:toVC.view belowSubview:maskView];
        
        toVC.view.frame = finalFrame;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        toVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
#endif
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if (self.type == PresentAnimatedTransitioningTypePresent) {
            
            toVC.view.frame = finalFrame;
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            toVC.view.transform   = CGAffineTransformIdentity;
#endif
            fromVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
            
            maskView.alpha = 1.f;
            
        }else{
            CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
            fromVC.view.frame = CGRectOffset(initialFrame, 0, CGRectGetHeight(initialFrame));
            
            //ios8以下SDK需如此不然会错乱
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            toVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
#endif
            toVC.view.transform = CGAffineTransformIdentity;
            
            maskView.alpha = 0.f;
        }
        
        //自定义动作
        if (_animations) {
            _animations();
        }
    }
                     completion:^(BOOL finished) {
                         
                         [maskView removeFromSuperview];
                         fromVC.view.transform = CGAffineTransformIdentity;
                         toVC.view.transform   = CGAffineTransformIdentity;
                         
                         //通知完成
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
