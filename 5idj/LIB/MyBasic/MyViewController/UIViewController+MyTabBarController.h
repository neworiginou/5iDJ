//
//  UIViewController+MyTabBarController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-2.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//


//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

typedef NS_ENUM(NSUInteger, ChangeTabBarItemDirection){
    ChangeTabBarItemDirectionNone = 0,
    ChangeTabBarItemDirectionPrev,//向前
    ChangeTabBarItemDirectionNext //向后
} ;


//----------------------------------------------------------

@protocol MyTabBarControllerTransitioningProtocol

/*
 *切换标签视图的动画
 */
- (id<UIViewControllerAnimatedTransitioning>)changeTabBarItemAnimatedTransitioning:(ChangeTabBarItemDirection)diretion;

@property(nonatomic, getter = isTabBarInteractiveEnabled) BOOL tabBarInteractiveEnabled;
@property(nonatomic, readonly, getter = isTabBarInteracting) BOOL tabBarInteracting;


- (BOOL)interactiveGestureShouldBeginWithPoint:(CGPoint)point withDirection:(ChangeTabBarItemDirection)diretion;

- (float)interactiveCompletePercentForTranslation:(CGPoint)translation direction:(ChangeTabBarItemDirection)diretion startPoint:(CGPoint)startPoint;

//@optional

- (void)startInteractiveWithDirection:(ChangeTabBarItemDirection)diretion;
- (void)finishInteractiveWithDirection:(ChangeTabBarItemDirection)diretion;
- (void)cancelInteractiveWithDirection:(ChangeTabBarItemDirection)diretion;

//用于TabBarControllerTransitioning的子视图控制器，默认为nil
- (UIViewController *)childViewControllerForTabBarControllerTransitioning;

@end

//----------------------------------------------------------
@protocol MyTabBarControllerTabBarHiddenProtocol

/*
 *是否可以通过滑动隐藏及显示TabBar，默认为NO
 */
@property(nonatomic, getter = isGestureHiddenTabBarEnabled) BOOL gestureHiddenTabBarEnabled;

//隐藏tabbar手势是否接收touch
- (BOOL)hiddenTabBarGestureShouldReceiveTouch:(UITouch *)touch;

//响应隐藏tabbar的临界值
- (CGFloat)minMoveValueForHiddenTabBar;

/*
 *手势想要隐藏tabbar，该函数调用后将判断是否可以被隐藏和tabBarWillGestureHidden
 */
- (void)gestureWantToHiddenTabBar:(BOOL)hidden;

/*
 *tabBar将要由于滑动隐藏或显示（hidden为YES为隐藏，否则为显示）
 *
 *默认该函数不执行任何操作，如果有需要请从子类覆盖该函数执行你想要的操作
 */
- (BOOL)tabBarWillGestureHidden:(BOOL)hidden;

/*
 *tabBar由于滑动隐藏或显示（hidden为YES为隐藏，否则为显示）时会执行的动作
 *
 *默认该函数不执行任何操作，如果有需要请从子类覆盖该函数执行你想要的操作
 */
- (void)animationWhenTabBarGestureHidden:(BOOL)hidden;

/*
 *tabBar已经由于滑动隐藏或显示（hidden为YES为隐藏，否则为显示）
 *
 *默认该函数不执行任何操作，如果有需要请从子类覆盖该函数执行你想要的操作
 */
- (void)tabBarDidGestureHidden:(BOOL)hidden;

//用于TabBarHidden的子视图控制器，默认为nil
- (UIViewController *)childViewControllerForTabBarHidden;

@end

//----------------------------------------------------------

@class MyTabBarController;

//----------------------------------------------------------


@interface UIViewController (MyTabBarController) <
                                                    MyTabBarControllerTransitioningProtocol,
                                                    MyTabBarControllerTabBarHiddenProtocol
                                                 >

/*
 *获取当前页面的MyTabBarControlle，如果无返回nil
 */
@property(nonatomic,readonly) MyTabBarController * myTabBarController;

@end

