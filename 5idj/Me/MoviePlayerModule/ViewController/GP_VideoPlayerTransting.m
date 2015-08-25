//
//  GP_VideoPlayerTransting.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-14.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoPlayerTransting.h"

//----------------------------------------------------------

@implementation GP_VideoPlayerTransting

- (id)init
{
    return [self initWithType:PresentAnimatedTransitioningTypePresent];
}

- (id)initWithType:(PresentAnimatedTransitioningType)type
{
    self = [super init];
    
    if (self) {
        _type = type;
    }
    
    return self;
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView * containerView    = [transitionContext containerView];
    
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect finalFrame   = [transitionContext finalFrameForViewController:toVC];
    
    
    UIView * shadowView = [[UIView alloc] init];
    shadowView.backgroundColor = BlackColorWithAlpha(0.8f);
    
        //设置旋转点
    CGFloat anchorPointY = 0.f;
    
    if (self.type == PresentAnimatedTransitioningTypeDismiss) {
        
        anchorPointY = CGRectGetWidth(initialFrame) * 2 / CGRectGetHeight(initialFrame) + 1.f;
        fromVC.view.layer.anchorPoint = CGPointMake(0.5f, anchorPointY);
        fromVC.view.center = CGPointMake(0.5f * CGRectGetWidth(initialFrame), CGRectGetHeight(initialFrame)* anchorPointY);
        
        //设置阴影
        [fromVC.view.layer setShadowPath:[UIBezierPath bezierPathWithRect:fromVC.view.bounds].CGPath];
        [fromVC.view.layer setShadowOpacity:1.f];
        [fromVC.view.layer setShadowOffset: CGSizeMake(-2.f, 2.f)];
        
        shadowView.frame = finalFrame;
        toVC.view.frame = finalFrame;
        [containerView insertSubview:shadowView belowSubview:fromVC.view];
        [containerView insertSubview:toVC.view belowSubview:shadowView];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        toVC.view.transform   = CGAffineTransformMakeScale(0.9f, 0.9f);
#endif
        
    }else{
        
        toVC.view.frame = finalFrame;
        anchorPointY = CGRectGetWidth(finalFrame) * 2 / CGRectGetHeight(finalFrame) + 1.f;
        toVC.view.layer.anchorPoint = CGPointMake(0.5f, anchorPointY);
        toVC.view.center = CGPointMake(0.5f * CGRectGetWidth(finalFrame), CGRectGetHeight(finalFrame)* anchorPointY);
        
        //设置阴影
        [toVC.view.layer setShadowPath:[UIBezierPath bezierPathWithRect:toVC.view.bounds].CGPath];
        [toVC.view.layer setShadowOpacity:1.f];
        [toVC.view.layer setShadowOffset: CGSizeMake(2.f, 2.f)];

        
        shadowView.frame = initialFrame;
        shadowView.alpha = 0.f;
        [containerView addSubview:shadowView];
        [containerView addSubview:toVC.view];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        toVC.view.transform   = CGAffineTransformMakeRotation(-_2_A_TAN_1_4);
#endif
    }
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if (self.type == PresentAnimatedTransitioningTypeDismiss) {
           
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            fromVC.view.transform = CGAffineTransformIdentity;
            toVC.view.transform   = CGAffineTransformMakeScale(0.9f, 0.9f);
#endif
            fromVC.view.transform = CGAffineTransformMakeRotation(_2_A_TAN_1_4);
            toVC.view.transform   = CGAffineTransformIdentity;
            
            shadowView.alpha = 0.f;
            
        }else{
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
            fromVC.view.transform = CGAffineTransformIdentity;
            toVC.view.transform   = CGAffineTransformMakeRotation(-_2_A_TAN_1_4);
#endif

            fromVC.view.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
            toVC.view.transform   = CGAffineTransformIdentity;
            
            shadowView.alpha = 1.f;
        }
        
    } completion:^(BOOL finished){

        //移除
        [shadowView removeFromSuperview];
        
        UIViewController * viewController = (self.type == PresentAnimatedTransitioningTypeDismiss) ? fromVC : toVC;
        [viewController.view.layer setShadowOpacity:0.f];
        [viewController.view.layer setShadowPath:nil];
        viewController.view.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        
        
        fromVC.view.transform = CGAffineTransformIdentity;
        toVC.view.transform   = CGAffineTransformIdentity;
        
        fromVC.view.frame = initialFrame;
        toVC.view.frame   = finalFrame;
        
        //通知完成
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
    
}

@end
