//
//  MyBasicViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-2.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyBasicViewController.h"
#import "MyNavigationTransitioningDelegate.h"
#import "MyTabBarController.h"
#import "MyViewControllerTransitioningDelegate.h"
#import "MacroDef.h"
#import "help.h"

//----------------------------------------------------------

@interface MyBasicViewController ()

//设备方向改变
- (void)_deviceOrientationDidChange:(NSNotification *) notification;

@end

//----------------------------------------------------------

@implementation MyBasicViewController
{
    //视图当前方向
    UIInterfaceOrientation _viewInterfaceOrientation;
    
    BOOL _rotateEnable:1;
    BOOL _rotating:1;
    BOOL _navigationInteractivePopEnable:1;
    BOOL _tabBarInteractiveEnabled:1;
    BOOL _interactiveDismissEnabled:1;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _viewInterfaceOrientation = UIInterfaceOrientationPortrait;
    }
    
    return self;
}

- (BOOL)isViewShowing
{
    return self.view.window != nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
     [[UIApplication sharedApplication] setStatusBarOrientation:self.viewInterfaceOrientation];
#else
    if (!GreaterThanIOS8System) {
         [[UIApplication sharedApplication] setStatusBarOrientation:self.viewInterfaceOrientation];
    }
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //移动到
    [self.myTabBarController setTabBarHidden:self.hiddenTabBarWhenViewDidAppear
                                    animated:YES
                                  animations:nil
                                  completion:nil];
    
    //尝试旋转
    [self attempRotateToDeviceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)tabBarDidGestureHidden:(BOOL)hidden
{
    [super tabBarDidGestureHidden:hidden];
    
    if (_memoryTabBarHiddenStatus) {
        _hiddenTabBarWhenViewDidAppear = hidden;
    }
}

//是否支持某方向
#define SupportedOrientation(_orientation) ([self supportedOrientations] & (1<< _orientation))

- (void)_deviceOrientationDidChange:(NSNotification *)notification
{
    if (_rotateEnable && !_rotating && ![self isNavigationInteractivePoping] && ![self isTabBarInteracting] && ![self isInteractiveDismissing]) {
        
        UIDeviceOrientation orientaion = [UIDevice currentDevice].orientation;
        
        if ((UIInterfaceOrientation)orientaion != _viewInterfaceOrientation && SupportedOrientation(orientaion)){
            //是否可以自动旋转
            if ([self willAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)orientaion]) {
                self.viewInterfaceOrientation = (UIInterfaceOrientation)orientaion;
            }
        }
    }
}

@end


//@implementation MyBasicViewController (MyNavigationController)
//
//- (void)finishInteractivePop
//{
//    [super finishInteractivePop];
//    
//    [self didPopByGesture];
//}
//
//- (void)didPopByGesture
//{
//    
//}
//
//@end


@implementation MyBasicViewController (MyRotate)

- (void)setRotateEnable:(BOOL)rotateEnable
{
    _rotateEnable = rotateEnable;
}

- (BOOL)isRotateEnabled
{
    return _rotateEnable;
}

- (BOOL)isRotating
{
    return _rotating;
}

- (UIInterfaceOrientation)viewInterfaceOrientation
{
    return _viewInterfaceOrientation;
}

- (void)setViewInterfaceOrientation:(UIInterfaceOrientation)viewInterfaceOrientation
{
    if (!_rotateEnable || _rotating || [self isNavigationInteractivePoping] || [self isTabBarInteracting] || [self isInteractiveDismissing]) {
        return;
    }
    
    UIInterfaceOrientation toInterfaceOrientation = viewInterfaceOrientation;
    
    if (toInterfaceOrientation != _viewInterfaceOrientation && SupportedOrientation(toInterfaceOrientation)) {
        
        UIInterfaceOrientation fromInterfaceOrientation = _viewInterfaceOrientation;
        
        //将要开始动作
        [self viewWillRotateToInterfaceOrientation:toInterfaceOrientation];
        
        _viewInterfaceOrientation = toInterfaceOrientation;
        
        //询问是否需要动作
        if ([self needAnimationsWhenRotateToInterfaceOrientation:toInterfaceOrientation fromInterfaceOrientation:fromInterfaceOrientation]) {
            
            [UIView animateWithDuration:[self animationsDurationWhenRotateToInterfaceOrientation:toInterfaceOrientation fromInterfaceOrientation:fromInterfaceOrientation]
                             animations:^{
                                 
                                 //自定义动作
                                 [self animationsWhenRotateToInterfaceOrientation:toInterfaceOrientation fromInterfaceOrientation:fromInterfaceOrientation];
                                 
                                 //旋转
                                 [self _rotateToInterfaceOrientation:toInterfaceOrientation];
                                 
                             }
                             completion:^(BOOL finished){
                                 [self viewDidRotateFromInterfaceOrientation:fromInterfaceOrientation];
                             }];
        }else{
            [self _rotateToInterfaceOrientation:toInterfaceOrientation];
            [self viewDidRotateFromInterfaceOrientation:fromInterfaceOrientation];
        }
    }
}


- (void)_rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
//    [[UIApplication sharedApplication] setStatusBarOrientation:toInterfaceOrientation animated:NO];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    [[UIApplication sharedApplication] setStatusBarOrientation:toInterfaceOrientation animated:NO];
#else
    if (!GreaterThanIOS8System) {
        [[UIApplication sharedApplication] setStatusBarOrientation:toInterfaceOrientation animated:NO];
    }
#endif
    
    //设置视图仿射变换
    self.view.transform = rotationAffineTransformForOrientation(toInterfaceOrientation);
    
    //设置视图大小
    CGRect bounds = self.view.superview.bounds;
    self.view.bounds = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? CGRectMake(0, 0,CGRectGetHeight(bounds),CGRectGetWidth( bounds)) : bounds;
}


- (NSUInteger)supportedOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)willAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
};

- (BOOL)needAnimationsWhenRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation fromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    return YES;
}

- (NSTimeInterval)animationsDurationWhenRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation fromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSTimeInterval time = [[UIApplication sharedApplication] statusBarOrientationAnimationDuration];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        return 2 * time;
    }
    
    return time;
}


- (void)viewWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //记录当前允许否
    _navigationInteractivePopEnable = [self isNavigationInteractivePopEnabled];
    _tabBarInteractiveEnabled = [self isTabBarInteractiveEnabled];
    _interactiveDismissEnabled = [self isInteractiveDismissEnabled];
    
    //旋转过程中不允许交互
    [self setNavigationInteractivePopEnable:NO];
    [self setTabBarInteractiveEnabled:NO];
    [self setInteractiveDismissEnable:NO];
    
    _rotating = YES;
}

- (void)animationsWhenRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation fromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //do noting
}

- (void)viewDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _rotating = NO;
    
    [self setNavigationInteractivePopEnable:_navigationInteractivePopEnable];
    [self setTabBarInteractiveEnabled:_tabBarInteractiveEnabled];
    [self setInteractiveDismissEnable:_interactiveDismissEnabled];
}

- (void)attempRotateToDeviceOrientation
{
    [self _deviceOrientationDidChange:nil];
}

- (void)setNavigationInteractivePopEnable:(BOOL)navigationInteractivePopEnable
{
    if (!_rotating) {
        [super setNavigationInteractivePopEnable:navigationInteractivePopEnable];
    }else{
        _navigationInteractivePopEnable = navigationInteractivePopEnable;
    }
}

//- (BOOL)isNavigationInteractivePopEnabled
//{
//    return _rotating ? _navigationInteractivePopEnable : [super isNavigationInteractivePopEnabled];
//}

- (void)setTabBarInteractiveEnabled:(BOOL)tabBarInteractiveEnabled
{
    if (!_rotating) {
        [super setTabBarInteractiveEnabled:tabBarInteractiveEnabled];
    }else{
        _tabBarInteractiveEnabled = tabBarInteractiveEnabled;
    }
}

//- (BOOL)isTabBarInteractiveEnabled
//{
//    return _rotating ? _tabBarInteractiveEnabled : [super isTabBarInteractiveEnabled];
//}


@end
