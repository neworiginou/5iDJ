//
//  MyViewControllerTransitioningDelegate.m
//  5idj
//
//  Created by Xuzhanya on 14-10-22.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyViewControllerTransitioningDelegate.h"
#import "MyPresentAnimatedTransitioning.h"
#import "MacroDef.h"
#import  <objc/runtime.h>

//----------------------------------------------------------

@interface MyViewControllerTransitioningDelegate ()

@property(nonatomic,strong,readonly) UIPanGestureRecognizer * interactiveGestureRecognizer;

@end


@implementation MyViewControllerTransitioningDelegate
{
    UIPercentDrivenInteractiveTransition * _interactiveTransition;
    UIViewController                     * _interactivePresentingViewController;
}

@synthesize interactiveGestureRecognizer = _interactiveGestureRecognizer;

#pragma mark - life circle

- (void)dealloc
{
    [self.presentedViewController.view removeGestureRecognizer:_interactiveGestureRecognizer];
}

- (UIPanGestureRecognizer *)interactiveGestureRecognizer
{
    if (!_interactiveGestureRecognizer) {
        _interactiveGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_interactiveGestureHandle:)];
        _interactiveGestureRecognizer.delegate = self;
    }
    
    return _interactiveGestureRecognizer;
}


- (void)presentViewController:(UIViewController *)viewControllerToPresent
{
    if (_interactiveDismissing) {
        @throw [NSException exceptionWithName:@"方法调用错误"
                                       reason:@"正在Dismiss交互中无法present视图控制器"
                                     userInfo:nil];
    }
    
    if (self.presentedViewController && _interactiveGestureRecognizer) {
        [_interactiveGestureRecognizer removeTarget:self action:@selector(_interactiveGestureHandle:)];
        [self.presentedViewController.view removeGestureRecognizer:_interactiveGestureRecognizer];
        self.presentedViewController.transitioningDelegate = nil;
    }
    
    _interactiveGestureRecognizer = nil;
    
    if (viewControllerToPresent) {
        [viewControllerToPresent.view addGestureRecognizer:self.interactiveGestureRecognizer];
        viewControllerToPresent.transitioningDelegate = self;
    }
    
    _presentedViewController = viewControllerToPresent;
}


#pragma mark - gestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (gestureRecognizer == _interactiveGestureRecognizer);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == _interactiveGestureRecognizer) {
        
        UIViewController * presentedViewController = self.presentedViewController;
        if ([presentedViewController isInteractiveDismissEnabled]) {
            return [presentedViewController interactiveDismissGestureShouldReceiveTouch:touch];
        }
        
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer == _interactiveGestureRecognizer){
        
        UIViewController * presentedViewController = self.presentedViewController;
        CGPoint translation = [_interactiveGestureRecognizer translationInView:presentedViewController.view];
        
        return [presentedViewController interactiveDismissGestureShouldBeginWithTranslation:translation];
    }
    return YES;
}

- (void)_interactiveGestureHandle:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIGestureRecognizerState state = panGestureRecognizer.state;
    UIViewController * presentedViewController = self.presentedViewController;

    if (state == UIGestureRecognizerStateBegan) {
        
        _interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        _interactiveTransition.completionCurve = UIViewAnimationCurveLinear;
        _interactiveDismissing = YES;
        _interactivePresentingViewController = presentedViewController.presentingViewController;
        
        [_interactivePresentingViewController dismissViewControllerAnimated:YES
                                                                 completion:nil];
        
        [presentedViewController startInteractiveDismiss];
        
    }else{
        
        CGPoint locationPoint = [panGestureRecognizer locationInView:_interactivePresentingViewController.view];
        CGPoint translation   = [panGestureRecognizer translationInView:_interactivePresentingViewController.view];
        
        //完成的比例
        CGFloat fraction = [presentedViewController interactiveDismissCompletePercentForTranslation:translation withStartPoint:locationPoint] + [_interactiveTransition percentComplete];
        
        if (state == UIGestureRecognizerStateChanged) {
            [_interactiveTransition updateInteractiveTransition:ChangeInMinToMax(fraction, 0.f, 1.f)];
        }else{
            
            //速度
            CGPoint velocity = [panGestureRecognizer velocityInView:_interactivePresentingViewController.view];
            
            //加上速度
            fraction += [presentedViewController interactiveDismissCompletePercentForTranslation:velocity withStartPoint:locationPoint];
            
            //完成
            if ( state == UIGestureRecognizerStateEnded && fraction >= 0.5f) {
                [_interactiveTransition finishInteractiveTransition];
                [presentedViewController finishInteractiveDismiss];
            }else{//取消
                [_interactiveTransition cancelInteractiveTransition];
                [presentedViewController cancelInteractiveDismiss];
            }
            
            _interactiveTransition = nil;
            _interactivePresentingViewController = nil;
            _interactiveDismissing = NO;
        }
        
        //置0
        [panGestureRecognizer setTranslation:CGPointZero inView:_interactivePresentingViewController.view];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    id<UIViewControllerAnimatedTransitioning> animatedTransitioning = [presented viewControllerAnimatedTransitioningForPresented];
    return animatedTransitioning ?: [[MyPresentAnimatedTransitioning alloc] initWithType:PresentAnimatedTransitioningTypePresent];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    id<UIViewControllerAnimatedTransitioning> animatedTransitioning = [dismissed viewControllerAnimatedTransitioningForDismissed];
    return animatedTransitioning ?: [[MyPresentAnimatedTransitioning alloc] initWithType:PresentAnimatedTransitioningTypeDismiss];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return _interactiveTransition;
}

@end

//----------------------------------------------------------

static char interactiveDismissEnableKey;

//----------------------------------------------------------

@implementation UIViewController (MyViewControllerTransitioning)

- (MyViewControllerTransitioningDelegate *)viewControllerTransitioningDelegate
{
    id delegate = self.presentingViewController.transitioningDelegate;
    
    if (delegate && [delegate isKindOfClass:[MyViewControllerTransitioningDelegate class]]) {
        return delegate;
    }
    
    return nil;
}

- (BOOL)isInteractiveDismissEnabled
{
    UIViewController * childViewController = [self childViewControllerForViewControllerTransitioning];
    
    return childViewController ? [childViewController isInteractiveDismissEnabled] : [objc_getAssociatedObject(self, &interactiveDismissEnableKey) boolValue];
    
}

- (void)setInteractiveDismissEnable:(BOOL)interactiveDismissEnable
{
    objc_setAssociatedObject(self, &interactiveDismissEnableKey, interactiveDismissEnable ? @YES : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isInteractiveDismissing
{
    return self.viewControllerTransitioningDelegate.isInteractiveDismissing;
}

- (id<UIViewControllerAnimatedTransitioning>)viewControllerAnimatedTransitioningForPresented
{
    UIViewController * childViewController = [self childViewControllerForViewControllerTransitioning];
    return childViewController ? [childViewController viewControllerAnimatedTransitioningForPresented] : nil;
}

- (id<UIViewControllerAnimatedTransitioning>)viewControllerAnimatedTransitioningForDismissed
{
    UIViewController * childViewController = [self childViewControllerForViewControllerTransitioning];
    return childViewController ? [childViewController viewControllerAnimatedTransitioningForDismissed] : nil;
}


- (BOOL)interactiveDismissGestureShouldReceiveTouch:(UITouch *)touch
{
    UIViewController * childViewController = [self childViewControllerForViewControllerTransitioning];
    return childViewController ? [childViewController interactiveDismissGestureShouldReceiveTouch:touch] : YES;
}

- (BOOL)interactiveDismissGestureShouldBeginWithTranslation:(CGPoint)translation
{
    UIViewController * childViewController = [self childViewControllerForViewControllerTransitioning];
    
    if (childViewController) {
        return  [childViewController interactiveDismissGestureShouldBeginWithTranslation:translation];
    }else{
        //向下移动
        return (translation.y > 0 && fabsf(translation.x) < fabsf(translation.y));
    }
}

- (float)interactiveDismissCompletePercentForTranslation:(CGPoint)translation
                                          withStartPoint:(CGPoint)startPoint
{
    UIViewController * childViewController = [self childViewControllerForViewControllerTransitioning];
    
    if (childViewController) {
        return  [childViewController interactiveDismissCompletePercentForTranslation:translation
                                                                      withStartPoint:startPoint];
    }else{
        return translation.y / CGRectGetHeight(self.view.bounds);
    }
}

- (void)startInteractiveDismiss
{
    UIViewController * childViewController = [self childViewControllerForViewControllerTransitioning];
    [childViewController startInteractiveDismiss];
}

- (void)finishInteractiveDismiss
{
    UIViewController * childViewController = [self childViewControllerForViewControllerTransitioning];
    [childViewController finishInteractiveDismiss];
}

- (void)cancelInteractiveDismiss
{
    UIViewController * childViewController = [self childViewControllerForViewControllerTransitioning];
    [childViewController cancelInteractiveDismiss];
}

- (UIViewController *)childViewControllerForViewControllerTransitioning
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

