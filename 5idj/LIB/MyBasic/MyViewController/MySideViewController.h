//
//  MySideViewController.h
//  YHDemo
//
//  Created by Xuzhanya on 14-9-29.
//  Copyright (c) 2014年 hldw. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, MySideViewControllerPosition) {
    MySideViewControllerPositionLeft   = 0,
    MySideViewControllerPositionCenter = 1,
    MySideViewControllerPositionRight  = 2
};

//----------------------------------------------------------

@class MySideViewController;

//----------------------------------------------------------

@protocol MySideViewControllerDelegate <NSObject>

@optional

- (void)sideViewController:(MySideViewController *)sideViewController
          willShowPosition:(MySideViewControllerPosition)position;


- (void)sideViewController:(MySideViewController *)sideViewController
           didShowPosition:(MySideViewControllerPosition)position
              fromPosition:(MySideViewControllerPosition)formPosition;

- (void)sideViewController:(MySideViewController *)sideViewController
        cancleShowPosition:(MySideViewControllerPosition)position;

@end

//----------------------------------------------------------

@interface MySideViewController : UIViewController

- (id)initWithLeftSideWidthScale:(CGFloat)leftSideWidthScale
             rightSideWidthScale:(CGFloat)rightSideWidthScale;

//左边视图宽度所占比例,默认为0.8f
@property(nonatomic,readonly) CGFloat leftSideWidthScale;

//右边视图宽度所占比例,默认为0.8f
@property(nonatomic,readonly) CGFloat rightSideWidthScale;

//视图的显示时的frame
- (CGRect)viewShowingFrameForPosition:(MySideViewControllerPosition)position;


- (CGRect)viewFrameForPosition:(MySideViewControllerPosition)position
            withShowingPositon:(MySideViewControllerPosition)showingPosition;
//
- (CGRect)viewCurrentFrameForPosition:(MySideViewControllerPosition)position;


//视图控制器
- (UIViewController *)viewControllerForPosition:(MySideViewControllerPosition)position;
- (void)setViewController:(UIViewController *)viewController
              forPosition:(MySideViewControllerPosition)position;


//当前显示的位置，默认为MySideViewControllerPositionCenter
@property(nonatomic) MySideViewControllerPosition showingPosition;

- (void)setShowingPosition:(MySideViewControllerPosition)showingPosition animated:(BOOL)animated;

//前提允许下交互式过渡可用性，默认为YES
@property(nonatomic,getter = isInteractiveTransitioningEnabled) BOOL interactiveTransitioningEnable;

//是否正在过渡中
@property(nonatomic,readonly,getter = isTransitioning) BOOL transitioning;

//代理
@property(nonatomic,weak) id<MySideViewControllerDelegate> delegate;

@end

//----------------------------------------------------------

/*
 * 过渡的上下文协议
 */
@protocol MySideViewControllerContextTransitioning <NSObject>

@property(nonatomic,readonly) MySideViewControllerPosition fromPosition,toPosition;

@property(nonatomic,strong,readonly) UIView * containerView;

@property(nonatomic,strong,readonly) UIView * fromView, * toView;

- (CGRect)initialFrameForView:(UIView *)view;
- (CGRect)finalFrameForView:(UIView *)view;

@end

//----------------------------------------------------------

/*
 * 过渡的动画
 */
@protocol MySideViewControllerAnimatedTransitioning <NSObject>

- (NSTimeInterval)transitionDuration:(id <MySideViewControllerContextTransitioning>)transitionContext;

//开始更新视图
- (void)startUpdateViewWithContext:(id <MySideViewControllerContextTransitioning>)transitionContext;

//更新视图
- (void)updateViewForProgress:(CGFloat)progress
                  withContext:(id <MySideViewControllerContextTransitioning>)transitionContext;

//结束更新视图
- (void)endUpdateViewWithContext:(id <MySideViewControllerContextTransitioning>)transitionContext;

//取消更新视图
- (void)cancleUpdateViewWithContext:(id <MySideViewControllerContextTransitioning>)transitionContext;

@end

//----------------------------------------------------------

/*
 * 过渡协议,MySideViewController的centerViewController实现
 */
@protocol  MySideViewControllerTransitioningProtocol

- (id<MySideViewControllerAnimatedTransitioning>)sideViewControllerAnimatedTransitioning;

//是否允许交互过渡
@property(nonatomic,getter = isSideViewControllerInteractiveTransitioningEnabled) BOOL sideViewControllerInteractiveTransitioningEnable;

//是否正在过渡
@property(nonatomic,readonly,getter = isSideViewControllerTransitioning) BOOL sideViewControllerTransitioning;


//从point点开始,返回NO取消
- (BOOL)sideViewControllerInteractiveTransitioningShouldBeginWithPoint:(CGPoint)point context:(id <MySideViewControllerContextTransitioning>)transitionContext;

//开始
- (void)startSideViewControllerInteractiveTransitioning:(id <MySideViewControllerContextTransitioning>)transitionContext;

//完成
- (void)finishSideViewControllerInteractiveTransitioning:(id <MySideViewControllerContextTransitioning>)transitionContext;

//取消
- (void)cancelSideViewControllerInteractiveTransitioning:(id <MySideViewControllerContextTransitioning>)transitionContext;

//用于SideViewControllerTransitioning的子视图控制器，默认为nil
- (UIViewController *)childViewControllerForSideViewControllerTransitioning;


@end

//----------------------------------------------------------

@interface UIViewController (MySideViewController) <MySideViewControllerTransitioningProtocol>

- (MySideViewController *)sideViewController;

@end



