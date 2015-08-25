//
//  MyBasicViewController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-2.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyTabBarController.h"

//----------------------------------------------------------

@interface MyBasicViewController : UIViewController

//视图是否显示
@property(nonatomic,readonly,getter = isViewShowing) BOOL viewShowing;

//是否隐藏tabbar当视图出现的时候，默认为NO
@property(nonatomic, getter = isHiddenTabBarWhenViewDidAppear) BOOL hiddenTabBarWhenViewDidAppear;

//是否记忆tabbar隐藏状态，默认为NO，即当手势改变tabbar隐藏状态时是否记忆状态到下次视图出现，通过改变hiddenTabBarWhenViewDidAppear实现
@property(nonatomic, getter = isMemoryTabBarHiddenStatus) BOOL memoryTabBarHiddenStatus;

@end

////----------------------------------------------------------
//
//@interface MyBasicViewController (MyNavigationController)
//
//- (void)didPopByGesture;
//
//@end

//----------------------------------------------------------

@interface MyBasicViewController (MyRotate)

//旋转可用性，默认为NO
@property(nonatomic,getter = isRotateEnabled) BOOL rotateEnable;

//是否正在旋转
@property(nonatomic,readonly,getter = isRotating) BOOL rotating;

//视图方向
@property(nonatomic) UIInterfaceOrientation viewInterfaceOrientation;

//支持的旋转方向
- (NSUInteger)supportedOrientations;

//将要自动旋转到toInterfaceOrientation，返回YES允许旋转
- (BOOL)willAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

//由fromInterfaceOrientation旋转到toInterfaceOrientation时是否需要动作，返回YES
- (BOOL)needAnimationsWhenRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation fromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

//由fromInterfaceOrientation旋转到toInterfaceOrientation动作的时间
- (NSTimeInterval)animationsDurationWhenRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation fromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

//开始旋转到toInterfaceOrientation
- (void)viewWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

//旋转过程中的动作
- (void)animationsWhenRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation fromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

//已经由fromInterfaceOrientation旋转到当前方向
- (void)viewDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;


//尝试旋转到当前设备方向
- (void)attempRotateToDeviceOrientation;

@end

