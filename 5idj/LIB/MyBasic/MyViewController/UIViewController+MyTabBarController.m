//
//  UIViewController+MyTabBarController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-2.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//


//----------------------------------------------------------
#import "UIViewController+MyTabBarController.h"
#import "MyTabBarController.h"
#import "MyPushPopAnimatedTransitioning.h"
#import "MyTabChangeTransitioning.h"
#import  <objc/runtime.h>


//----------------------------------------------------------

static char tabBarInteractiveEnabledkey,gestureHiddenTabBarEnabledKey;

//----------------------------------------------------------

@implementation UIViewController (MyTabBarController)

- (MyTabBarController *)myTabBarController
{
    if ([self isKindOfClass:[MyTabBarController class]]) {
        
        return (MyTabBarController *)self;
    }else{
        
        UITabBarController * tabBarController = self.tabBarController;
        if (tabBarController && [tabBarController isKindOfClass:[MyTabBarController class]]) {
            return (MyTabBarController *)tabBarController;
        }else{
            return [self.parentViewController myTabBarController];
        }
    }
}

#pragma mark - MyTabBarControllerTransitioningProtocol

- (id<UIViewControllerAnimatedTransitioning>)changeTabBarItemAnimatedTransitioning:(ChangeTabBarItemDirection)diretion
{
    assert(diretion != ChangeTabBarItemDirectionNone);
    
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    if (childViewController) {
        return [childViewController changeTabBarItemAnimatedTransitioning:diretion];
    }else{
        
        return [[MyTabChangeTransitioning alloc] initWithTabChangeDirection:
                (diretion == ChangeTabBarItemDirectionPrev) ? TabChangeDirectionPrev : TabChangeDirectionNext
                type:MyTabChangeTransitioningTypeTranslation animation:nil];
    }
}

- (BOOL)isTabBarInteractiveEnabled
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    return childViewController ? [childViewController isTabBarInteractiveEnabled] :[objc_getAssociatedObject(self, &tabBarInteractiveEnabledkey) boolValue];
}

- (void)setTabBarInteractiveEnabled:(BOOL)tabBarInteractiveEnabled
{
    objc_setAssociatedObject(self, &tabBarInteractiveEnabledkey, tabBarInteractiveEnabled ? @YES : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isTabBarInteracting
{
    return [self myTabBarController].isInteracting;
}

- (BOOL)interactiveGestureShouldBeginWithPoint:(CGPoint)point withDirection:(ChangeTabBarItemDirection)diretion
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    return childViewController ? [childViewController interactiveGestureShouldBeginWithPoint:point withDirection:diretion] : YES;
}

- (float)interactiveCompletePercentForTranslation:(CGPoint)translation direction:(ChangeTabBarItemDirection)diretion startPoint:(CGPoint)startPoint;
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    if (childViewController) {
        return [childViewController interactiveCompletePercentForTranslation:translation direction:diretion startPoint:startPoint];
    }else{
        
        if (diretion == ChangeTabBarItemDirectionNone) {
            return 1.f;
        }
        
        float completePercent = ((diretion == ChangeTabBarItemDirectionPrev) ? translation.x : - translation.x) / CGRectGetWidth(self.view.bounds);
        
        return completePercent;
    }
}

- (void)startInteractiveWithDirection:(ChangeTabBarItemDirection)diretion
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    if (childViewController) {
        [childViewController startInteractiveWithDirection:diretion];
    }
}

- (void)finishInteractiveWithDirection:(ChangeTabBarItemDirection)diretion
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    if (childViewController) {
        [childViewController finishInteractiveWithDirection:diretion];
    }
}

- (void)cancelInteractiveWithDirection:(ChangeTabBarItemDirection)diretion
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    if (childViewController) {
        [childViewController cancelInteractiveWithDirection:diretion];
    }
}

#pragma mark - MyTabBarControllerTabBarHiddenProtocol

- (BOOL)isGestureHiddenTabBarEnabled
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    return childViewController ? [childViewController isGestureHiddenTabBarEnabled] :[objc_getAssociatedObject(self, &gestureHiddenTabBarEnabledKey) boolValue];
}

- (void)setGestureHiddenTabBarEnabled:(BOOL)gestureHiddenTabBarEnabled
{
    objc_setAssociatedObject(self, &gestureHiddenTabBarEnabledKey, gestureHiddenTabBarEnabled ? @YES : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hiddenTabBarGestureShouldReceiveTouch:(UITouch *)touch
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    return childViewController ? [childViewController hiddenTabBarGestureShouldReceiveTouch:touch] : YES;
}

- (CGFloat)minMoveValueForHiddenTabBar
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    return childViewController ? [childViewController minMoveValueForHiddenTabBar] : 20.f;
}

- (void)gestureWantToHiddenTabBar:(BOOL)hidden
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    if (childViewController) {
        [childViewController gestureWantToHiddenTabBar:hidden];
    }
}

- (BOOL)tabBarWillGestureHidden:(BOOL)hidden
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    return childViewController ? [childViewController tabBarWillGestureHidden:hidden] : YES;
}

- (void)animationWhenTabBarGestureHidden:(BOOL)hidden
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    if (childViewController) {
        [childViewController animationWhenTabBarGestureHidden:hidden];
    }
}

- (void)tabBarDidGestureHidden:(BOOL)hidden
{
    UIViewController * childViewController = [self childViewControllerForTabBarControllerTransitioning];
    
    if (childViewController) {
        [childViewController tabBarDidGestureHidden:hidden];
    }
}

- (UIViewController *)childViewControllerForTabBarControllerTransitioning
{
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)self topViewController];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [(UITabBarController *)self selectedViewController];
    }
    
    return nil;
}

- (UIViewController *)childViewControllerForTabBarHidden
{
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)self topViewController];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [(UITabBarController *)self selectedViewController];
    }
    
    return nil;
}
@end
