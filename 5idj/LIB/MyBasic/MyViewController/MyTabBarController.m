//
//  MyTabBarController.m
//  shopping
//
//  Created by hldw航 on 13-12-4.
//  Copyright (c) 2013年 Xu zhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyTabBarController.h"
#import "MacroDef.h"
#import "help.h"

//----------------------------------------------------------

@interface MyTabBarController ()

- (void)_hiddenTabBarPanGestureHander:(UIGestureRecognizer *)gestureRecognizer;

- (void)_interactiveGestureHandle:(UIGestureRecognizer *)gestureRecognizer;

@end

//----------------------------------------------------------

@implementation MyTabBarController
{
    BOOL                                   _tabBarHidden;
    UIPanGestureRecognizer               * _hiddenTabBarPanGestureRecognizer;
    
    UIPanGestureRecognizer               * _interactiveGestureRecognizer;
    UIPercentDrivenInteractiveTransition * _interactiveTransition;
    
    UIViewController                     * _interactivetSelectedViewController;
    ChangeTabBarItemDirection              _interactiveDirection;
    float                                  _interactivePercentComplete;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    //隐藏tabbar的手势
    _hiddenTabBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_hiddenTabBarPanGestureHander:)];
    _hiddenTabBarPanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_hiddenTabBarPanGestureRecognizer];
    
    //交互切换的手势
    _interactiveGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_interactiveGestureHandle:)];
    _interactiveGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_interactiveGestureRecognizer];
    
}

- (void)setTabBarHidden:(BOOL)tabBarHidden
{
    [self setTabBarHidden:tabBarHidden animated:NO animations:nil completion:nil];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated animations:(void (^)(void))animations completion:(void (^)(void))completionBlock
{
    //系统版本在7.0以下且tabbar不是半透明不支持隐藏标题栏
    if (!GreaterThanIOS7System || self.tabBar.translucent == NO) {
        return;
    }
    
    if (_tabBarHidden != hidden) {
        _tabBarHidden = hidden;
        
//        UIView *contentView = [self valueForKey:@"_viewControllerTransitionView"];
        
//        CGRect contentViewRect = contentView.frame;
        CGRect tabBarRect = self.tabBar.frame;
        
//        //系统版本小于7需设置界面铺满屏幕
//        if (systemVersion() < 7.0f) {
//            
//            if (hidden) {
//                contentViewRect.size.height = CGRectGetHeight(self.view.frame);
//                contentView.frame = contentViewRect;
//            }else{
//                contentViewRect.size.height = CGRectGetHeight(self.view.frame)-CGRectGetHeight(tabBarRect);
//            }
//        }
        
        
        if (hidden) {
            tabBarRect.origin.y += CGRectGetHeight(tabBarRect);
        }else{
            tabBarRect.origin.y -= CGRectGetHeight(tabBarRect);
        }
        
        self.tabBar.hidden = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                             animations:^{
                                 
                                 self.tabBar.frame = tabBarRect;
                                 
                                 if (animations) {
                                     animations();
                                 }
                                 
                             } completion:^(BOOL finished){
                                 
//                                 if (!hidden) {
//                                     contentView.frame = contentViewRect;
//                                 }
                                 
                                 self.tabBar.hidden = hidden;
                                 
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
            
        }else{
            
            self.tabBar.frame = tabBarRect;
            
//            if (!hidden) {
//                contentView.frame = contentViewRect;
//            }
            
            self.tabBar.hidden = hidden;
            
            if (completionBlock) {
                completionBlock();
            }
        }
        
    }
    else{
        
        if (completionBlock) {
            completionBlock();
        }
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIViewController * selectedViewController = self.selectedViewController;
    
    if (gestureRecognizer == _interactiveGestureRecognizer) {
        
        return (self.viewControllers.count > 1 && selectedViewController && [selectedViewController isTabBarInteractiveEnabled]);
        
    }else if (gestureRecognizer == _hiddenTabBarPanGestureRecognizer){
    
        return (selectedViewController && [selectedViewController isGestureHiddenTabBarEnabled] && [selectedViewController hiddenTabBarGestureShouldReceiveTouch:touch]);
    }
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _interactiveGestureRecognizer){
        
        //获取偏移
        CGPoint translation = [_interactiveGestureRecognizer translationInView:self.view];
        
        if(fabsf(translation.x) > fabsf(translation.y)){
            
            UIViewController * selectedViewController = self.selectedViewController;
            
            return (selectedViewController && [selectedViewController interactiveGestureShouldBeginWithPoint:[_interactiveGestureRecognizer locationInView:self.view] withDirection:translation.x < 0 ? ChangeTabBarItemDirectionNext : ChangeTabBarItemDirectionPrev]);
        }
        
        return NO;
        
    }else if (gestureRecognizer == _hiddenTabBarPanGestureRecognizer){
        //获取偏移
        CGPoint translation = [_hiddenTabBarPanGestureRecognizer translationInView:self.view];
        
        //上下移动则开始识别
        return (fabsf(translation.x) < fabsf(translation.y));
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return  (gestureRecognizer == _interactiveGestureRecognizer);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (gestureRecognizer == _hiddenTabBarPanGestureRecognizer);
}


- (void)_hiddenTabBarPanGestureHander:(UIGestureRecognizer *)gestureRecognizer
{
 
    UIViewController * selectedViewController = self.selectedViewController;
    
    CGPoint translation = [_hiddenTabBarPanGestureRecognizer translationInView:self.view];
    
    //达到响应条件
    if (fabsf(translation.y) >= [selectedViewController minMoveValueForHiddenTabBar]) {
        
        BOOL hidden = translation.y < 0;
        
        [selectedViewController gestureWantToHiddenTabBar:hidden];
        
        if (_tabBarHidden != hidden &&
            [selectedViewController tabBarWillGestureHidden:hidden]) {

            [self setTabBarHidden:hidden animated:YES
                       animations:^{
                        
                           //动作
                           [selectedViewController animationWhenTabBarGestureHidden:hidden];
                       }
                       completion:^{
                           //结束
                           [selectedViewController tabBarDidGestureHidden:hidden];
                       }];
            
        }
        
        //重新计数
        [_hiddenTabBarPanGestureRecognizer setTranslation:CGPointZero inView:self.view];
    }
}

- (void)_interactiveGestureHandle:(UIGestureRecognizer *)gestureRecognizer
{
    if (_interactivetSelectedViewController && ![_interactivetSelectedViewController isTabBarInteractiveEnabled]) {
        //取消
        goto CancelLabel;
    }
    
    UIGestureRecognizerState state = gestureRecognizer.state;
    
    if (state == UIGestureRecognizerStateBegan) {
        
        _interactivetSelectedViewController = self.selectedViewController;
        _interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        _interactiveTransition.completionCurve = UIViewAnimationCurveLinear;
        _interactivePercentComplete = 0.f;
        
        //方向
        _interactiveDirection = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view].x < 0 ? ChangeTabBarItemDirectionNext : ChangeTabBarItemDirectionPrev;
        
        //获取目的索引
        NSInteger tragetIndex = (_interactiveDirection == ChangeTabBarItemDirectionNext) ? self.selectedIndex + 1 : self.selectedIndex - 1;
        tragetIndex = (tragetIndex < 0) ? (self.viewControllers.count -1) : ((tragetIndex >= self.viewControllers.count) ? 0 : tragetIndex);
        
        _interacting = YES;
        
        //切换到目的索引
        self.selectedIndex = tragetIndex;
        
        [_interactivetSelectedViewController startInteractiveWithDirection:_interactiveDirection];
        
    }else{
        
        CGPoint locationPoint =  [gestureRecognizer locationInView:self.view];
        CGPoint translation   =  [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
        
        _interactivePercentComplete += [_interactivetSelectedViewController interactiveCompletePercentForTranslation:translation direction:_interactiveDirection startPoint:locationPoint];
        
        
        if (state == UIGestureRecognizerStateChanged) {
            
            _interactivePercentComplete = ChangeInMinToMax(_interactivePercentComplete, 0.f, 1.f);
            [_interactiveTransition updateInteractiveTransition:_interactivePercentComplete];
            
        }else{
            
            //速度
            CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view];
            
            _interactivePercentComplete += [_interactivetSelectedViewController interactiveCompletePercentForTranslation:velocity direction:_interactiveDirection startPoint:locationPoint];
            
            //完成
            if (state == UIGestureRecognizerStateEnded && _interactivePercentComplete >= 0.5f) {
                [_interactiveTransition finishInteractiveTransition];
                
                [_interactivetSelectedViewController finishInteractiveWithDirection:_interactiveDirection];
            }else{//取消
                
CancelLabel:
                [_interactiveTransition cancelInteractiveTransition];
                
                [_interactivetSelectedViewController cancelInteractiveWithDirection:_interactiveDirection];
            }
            
            //变量还原
            _interactiveDirection = ChangeTabBarItemDirectionNone;
            _interactivetSelectedViewController = nil;
            _interactiveTransition = nil;
            _interacting = NO;
            _interactivePercentComplete = 0.f;
        }
        
        [(UIPanGestureRecognizer *)gestureRecognizer setTranslation:CGPointZero inView:self.view];
    }
}



- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (!_interactiveTransition) {
        return nil;
    }
    
    UIViewController * selectedViewController = self.selectedViewController;

    ChangeTabBarItemDirection direction = _interactiveDirection;
    
    //当前无方向则通过索引计算方向
    if (direction == ChangeTabBarItemDirectionNone) {
        
        NSUInteger fromIndex = [self.viewControllers indexOfObject:fromVC];
        NSUInteger toIndex = [self.viewControllers indexOfObject:toVC];
        
        direction = (toIndex > fromIndex)? ChangeTabBarItemDirectionNext : ChangeTabBarItemDirectionPrev;
    }
    
    return [selectedViewController changeTabBarItemAnimatedTransitioning:direction];

}

- (id<UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return _interactiveTransition;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([tabBarController isTabBarInteracting]) {
        return NO;
    }
    
    return YES;
}


//#pragma mark - Autorotate
//
//- (BOOL)shouldAutorotate
//{
//    return [self.selectedViewController shouldAutorotate];
//}
//
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    UIViewController * selectedViewController = self.selectedViewController;
//    
//    if (selectedViewController) {
//        [selectedViewController supportedInterfaceOrientations];
//    }
//    
//    return UIInterfaceOrientationMaskPortrait;
//}


@end

