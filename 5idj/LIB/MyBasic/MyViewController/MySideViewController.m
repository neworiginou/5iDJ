//
//  MySideViewController.m
//  YHDemo
//
//  Created by Xuzhanya on 14-9-29.
//  Copyright (c) 2014年 hldw. All rights reserved.
//

//----------------------------------------------------------

#import "MySideViewController.h"
#import "MacroDef.h"
#import "MySideViewControllerDefaultTransitioning.h"
#import <objc/runtime.h>

//----------------------------------------------------------

@interface _MySideViewControllerContextTransitioning : NSObject <MySideViewControllerContextTransitioning>

- (id)initWithSideViewController:(MySideViewController *)sideViewController
                    fromPosition:(MySideViewControllerPosition)fromPosition
                      toPosition:(MySideViewControllerPosition)toPosition;

- (void)updateFrameWithSideViewController:(MySideViewController *)sideViewController;

@end

//----------------------------------------------------------

@interface _MySideViewControllerLayoutView : UIView <UIGestureRecognizerDelegate>

- (id)initWithSideViewController:(MySideViewController *)sideViewController;

@property(nonatomic,weak,readonly)  MySideViewController * sideViewController;

@property(nonatomic,strong,readonly) UIView * leftView;
@property(nonatomic,strong,readonly) UIView * centerView;
@property(nonatomic,strong,readonly) UIView * rightView;

- (void)updateSubViewsFrame;

- (UIView *)superViewForPosition:(MySideViewControllerPosition)position;


- (void)completedTransitionWithContext:(id<MySideViewControllerContextTransitioning>)context
                             animation:(id<MySideViewControllerAnimatedTransitioning>)animation
                         startProgress:(CGFloat)startProgress
                              velocity:(CGFloat)velocity
                              animated:(BOOL)animated
                        completedBlock:(void(^)())completedBlock;

- (void)cancleTransitionWithContext:(id<MySideViewControllerContextTransitioning>)context
                          animation:(id<MySideViewControllerAnimatedTransitioning>)animation
                      startProgress:(CGFloat)startProgress
                           animated:(BOOL)animated
                     completedBlock:(void(^)())completedBlock;


@property(nonatomic,strong,readonly) UIPanGestureRecognizer * interactivePanGesture;
@property(nonatomic,strong,readonly) UITapGestureRecognizer * interactiveTapGesture;

@end

//----------------------------------------------------------

@interface MySideViewController ()

@property(nonatomic,strong,readonly) NSMutableArray * viewControllers;

@property(nonatomic,strong,readonly) NSMutableArray * transitioningCompletedBlocks;

@property(nonatomic,strong,readonly) _MySideViewControllerLayoutView  * layoutView;

//过渡的上下文
@property(nonatomic,strong) _MySideViewControllerContextTransitioning * transitioningContext;

@end

//----------------------------------------------------------

@implementation MySideViewController
{
    BOOL  _viewIsLoaded;
    
    id<MySideViewControllerAnimatedTransitioning> _animatedTransitioning;
    
    CGFloat _transitioningProgress;
    CGFloat _transitioningWidthScale;
}

@synthesize viewControllers              = _viewControllers;
@synthesize transitioningCompletedBlocks = _transitioningCompletedBlocks;

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithLeftSideWidthScale:0.8f rightSideWidthScale:0.8f];
}

- (id)initWithLeftSideWidthScale:(CGFloat)leftSideWidthScale
             rightSideWidthScale:(CGFloat)rightSideWidthScale
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _leftSideWidthScale = ChangeInMinToMax(leftSideWidthScale, 0.f, 1.f);
        _rightSideWidthScale = ChangeInMinToMax(rightSideWidthScale, 0.f, 1.f);
        _showingPosition = MySideViewControllerPositionCenter;
        _interactiveTransitioningEnable = YES;
    }
    
    return self;
}

#pragma - child view controller

- (CGRect)viewShowingFrameForPosition:(MySideViewControllerPosition)position
{
    CGRect frame = self.view.bounds;
    
    switch (position) {
        case MySideViewControllerPositionLeft:
            return CGRectMake(0.f, 0.f, floorf(CGRectGetWidth(frame) * _leftSideWidthScale), CGRectGetHeight(frame));
            break;
            
        case MySideViewControllerPositionRight:
        {
            CGFloat viewWidth = floorf(CGRectGetWidth(frame) * _rightSideWidthScale);
            return CGRectMake(CGRectGetWidth(frame) - viewWidth, 0.f, viewWidth, CGRectGetHeight(frame));
        }
            break;
            
        default:
            return frame;
            break;
    }
}

- (CGRect)viewFrameForPosition:(MySideViewControllerPosition)position
            withShowingPositon:(MySideViewControllerPosition)showingPosition
{
    if (position == MySideViewControllerPositionCenter) {
        
        CGRect frame = self.view.bounds;
        
        if (showingPosition == MySideViewControllerPositionLeft) {
            frame = CGRectOffset(frame, floorf(CGRectGetWidth(frame) * _leftSideWidthScale), 0.f);
        }else if(showingPosition == MySideViewControllerPositionRight){
            frame = CGRectOffset(frame, - floorf(CGRectGetWidth(frame) * _rightSideWidthScale), 0.f);
        }
        
        return frame;
        
    }else{
        return [self viewShowingFrameForPosition:position];
    }
}

- (CGRect)viewCurrentFrameForPosition:(MySideViewControllerPosition)position
{
    return [self viewFrameForPosition:position withShowingPositon:self.showingPosition];
}

- (UIViewController *)viewControllerForPosition:(MySideViewControllerPosition)position
{
    id viewController = self.viewControllers[position];
    
    if (viewController == [NSNull null]) {
        viewController = nil;
    }
    
    return viewController;
}


#define IsAppearedForPosition(position)  \
    (self.showingPosition == position || position == MySideViewControllerPositionCenter)

- (void)setViewController:(UIViewController *)viewController
              forPosition:(MySideViewControllerPosition)position
{
    if (self.isTransitioning) {
        
        typeof(self) __weak weak_self = self;
        
        [self _addActionToTransitioningCompletedBlock:^{
            
            typeof(self) _self = weak_self;
            [_self setViewController:viewController forPosition:position];
            
        }];
    }else{
        
        UIViewController * fromViewController = [self viewControllerForPosition:position];
        
        if (fromViewController) {
            [fromViewController.view removeFromSuperview];
            [fromViewController willMoveToParentViewController:nil];
            [fromViewController removeFromParentViewController];
        }
        
        self.viewControllers[position] = viewController ?: [NSNull null];
        
        if (viewController) {
            
            [self addChildViewController:viewController];
            [self didMoveToParentViewController:self];
            
            if (_viewIsLoaded && IsAppearedForPosition(position)) {
                
                //添加视图
                [self _addViewForPosition:position];
            }
        }
    }
}

- (void)_addActionToTransitioningCompletedBlock:(void(^)())actionBlock
{
    [self.transitioningCompletedBlocks addObject:[actionBlock copy]];
}

- (void)_commitTransitioningCompletedBlock
{
    for (void(^actionBlock)() in self.transitioningCompletedBlocks) {
        
        //异步执行
        dispatch_async(dispatch_get_main_queue(), ^{
            actionBlock();
        });
    }
    
    [self.transitioningCompletedBlocks removeAllObjects];
}

- (void)_addViewForPosition:(MySideViewControllerPosition)position
{
    UIViewController * viewController = [self viewControllerForPosition:position];
    
    if (viewController) {
        
        //添加视图
        UIView * superView = [self.layoutView superViewForPosition:position];
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                               UIViewAutoresizingFlexibleWidth;
        viewController.view.frame = superView.bounds;
        [superView addSubview:viewController.view];
    }
}

- (void)_removeViewForPosition:(MySideViewControllerPosition)position
{
    if (position != MySideViewControllerPositionCenter) {
        
        UIViewController * viewController = [self viewControllerForPosition:position];
        [viewController.view removeFromSuperview];
    }
}

- (NSMutableArray *)viewControllers
{
    if (!_viewControllers) {
        _viewControllers = [NSMutableArray arrayWithObjects:[NSNull null],
                                                            [NSNull null],
                                                            [NSNull null],nil];
    }
    return _viewControllers;
}

- (NSMutableArray *)transitioningCompletedBlocks
{
    if(!_transitioningCompletedBlocks){
        _transitioningCompletedBlocks = [NSMutableArray array];
    }
    
    return _transitioningCompletedBlocks;
}

#pragma load View

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _layoutView = [[_MySideViewControllerLayoutView alloc] initWithSideViewController:self];
    _layoutView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                   UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_layoutView];
    
    _viewIsLoaded = YES;
    
    //添加视图
    [self _addViewForPosition:MySideViewControllerPositionCenter];
    if (self.showingPosition != MySideViewControllerPositionCenter) {
        [self _addViewForPosition:self.showingPosition];
    }
    
    //手势识别
    [_layoutView.interactivePanGesture addTarget:self action:@selector(_interactivePanGestureHandle:)];
    [_layoutView.interactiveTapGesture addTarget:self action:@selector(_interactiveTapGestureHandle:)];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //更新上下文
    if (self.isTransitioning) {
        [self.transitioningContext updateFrameWithSideViewController:self];
    }else{
        [self.layoutView updateSubViewsFrame];
    }
}


- (void)setShowingPosition:(MySideViewControllerPosition)showingPosition
{
    [self setShowingPosition:showingPosition animated:NO];
}

- (void)setShowingPosition:(MySideViewControllerPosition)showingPosition animated:(BOOL)animated
{
    [self _setShowingPosition:showingPosition animated:animated notifer:YES];
}

- (void)_setShowingPosition:(MySideViewControllerPosition)showingPosition animated:(BOOL)animated notifer:(BOOL)notifer
{
    if (_showingPosition != showingPosition) {
        
        if (!_viewIsLoaded) {
            _showingPosition = showingPosition;
        }else{
            
            if (self.isTransitioning) {
                
                typeof(self) __weak weak_self = self;
                [self _addActionToTransitioningCompletedBlock:^{
                    typeof(self) _self = weak_self;
                    [_self _setShowingPosition:showingPosition animated:animated notifer:notifer];
                }];
                
                return;
            }
            
            //不经过中间的切换
            if (_showingPosition != MySideViewControllerPositionCenter &&
                showingPosition != MySideViewControllerPositionCenter) {
        
                //先移到中点
                [self _setShowingPosition:MySideViewControllerPositionCenter
                                 animated:animated
                                  notifer:notifer];
                
                //在移到目的
                [self _setShowingPosition:showingPosition
                                 animated:animated
                                  notifer:notifer];
            }else{
                
                MySideViewControllerPosition fromPosition = _showingPosition;
                MySideViewControllerPosition toPosition   = showingPosition;
                
                UIViewController * fromViewController = [self viewControllerForPosition:fromPosition];
                
                if (fromPosition != MySideViewControllerPositionCenter) {
                    [fromViewController beginAppearanceTransition:NO animated:animated];
                }
                
                if (toPosition != MySideViewControllerPositionCenter) {
                    [self _addViewForPosition:toPosition];
                }
                
                
                //生成上下文
                _MySideViewControllerContextTransitioning * transitioningContext = [[_MySideViewControllerContextTransitioning alloc] initWithSideViewController:self fromPosition:fromPosition toPosition:toPosition];
                
                //过渡动画
                id<MySideViewControllerAnimatedTransitioning> animatedTransitioning = [self _getAnimatedTransitioning];
                
                
                //开始
                [self _startTransitionWithContext:transitioningContext
                                        animation:animatedTransitioning
                                          notifer:notifer];
                
                _showingPosition = showingPosition;
                
                //完成
                [self _completedTransitionWithContext:transitioningContext
                                            animation:animatedTransitioning
                                        startProgress:0.f
                                             velocity:0.f
                                             animated:animated
                                       completedBlock:^{
                    
                                           if (fromPosition != MySideViewControllerPositionCenter) {
                                               [fromViewController endAppearanceTransition];
                                           }
                    
                                       }  notifer:notifer];
                
            }
        }
    }
}

#pragma mark - transitioning

- (id<MySideViewControllerAnimatedTransitioning>)_getAnimatedTransitioning
{
    id<MySideViewControllerAnimatedTransitioning> animatedTransitioning = [[self viewControllerForPosition:MySideViewControllerPositionCenter] sideViewControllerAnimatedTransitioning];
 
    return animatedTransitioning ?: [[MySideViewControllerDefaultTransitioning alloc] init];
}

- (void)_startTransitionWithContext:(id<MySideViewControllerContextTransitioning>)context
                          animation:(id<MySideViewControllerAnimatedTransitioning>)animation
                            notifer:(BOOL)notifer
{
    _transitioning = YES;
    
    [animation startUpdateViewWithContext:context];
    
    if (notifer) {
        [self _sendStartShowingMessgaeWithContext:context];
    }
}

- (void)_completedTransitionWithContext:(id<MySideViewControllerContextTransitioning>)context
                              animation:(id<MySideViewControllerAnimatedTransitioning>)animation
                          startProgress:(CGFloat)startProgress
                               velocity:(CGFloat)velocity
                               animated:(BOOL)animated
                         completedBlock:(void(^)())completedBlock
                                notifer:(BOOL)notifer
{
    [self.layoutView completedTransitionWithContext:context
                                          animation:animation
                                      startProgress:startProgress
                                           velocity:velocity
                                           animated:animated
                                     completedBlock:^{
        
                                        _transitioning = NO;
        
                                         if (context.fromPosition != MySideViewControllerPositionCenter) {
                                             [self _removeViewForPosition:context.fromPosition];
                                         }
                                         
                                         if (completedBlock) {
                                             completedBlock();
                                         }
        
                                         if(notifer){
                                             [self _sendCompletedShowingMessgaeWithContext:context];
                                         }
                                         
                                         [self _commitTransitioningCompletedBlock];
        
                                     }];
}

- (void)_cancelTransitionWithContext:(id<MySideViewControllerContextTransitioning>)context
                           animation:(id<MySideViewControllerAnimatedTransitioning>)animation
                       startProgress:(CGFloat)startProgress
                            animated:(BOOL)animated
                      completedBlock:(void(^)())completedBlock
                             notifer:(BOOL)notifer
{
    [self.layoutView cancleTransitionWithContext:context
                                       animation:animation
                                   startProgress:startProgress
                                        animated:animated
                                  completedBlock:^{
                                
                                      _transitioning = NO;
                                
                                      if (context.toPosition != MySideViewControllerPositionCenter) {
                                          [self _removeViewForPosition:context.toPosition];
                                      }
                                
                                      if (completedBlock) {
                                          completedBlock();
                                      }
                                      
                                      if (notifer) {
                                          [self _sendCancleShowingMessgaeWithContext:context];
                                      }
                                      
                                
                                      [self _commitTransitioningCompletedBlock];
                                
                            }];
}

#pragma mark - delegate

- (void)_sendStartShowingMessgaeWithContext:(id<MySideViewControllerContextTransitioning>)context
{
    id<MySideViewControllerDelegate> delegate = self.delegate;
    
    ifRespondsSelector(delegate, @selector(sideViewController:willShowPosition:)){
        [delegate sideViewController:self willShowPosition:[context toPosition]];
    }
}

- (void)_sendCompletedShowingMessgaeWithContext:(id<MySideViewControllerContextTransitioning>)context
{
    id<MySideViewControllerDelegate> delegate = self.delegate;
    
    ifRespondsSelector(delegate, @selector(sideViewController:didShowPosition:fromPosition:)){
        
        [delegate sideViewController:self
                     didShowPosition:[context toPosition]
                        fromPosition:[context fromPosition]];
    }

}

- (void)_sendCancleShowingMessgaeWithContext:(id<MySideViewControllerContextTransitioning>)context
{
    id<MySideViewControllerDelegate> delegate = self.delegate;
    
    ifRespondsSelector(delegate, @selector(sideViewController:cancleShowPosition:)){
        
        [delegate sideViewController:self cancleShowPosition:[context toPosition]];
    }
}

#pragma mark - interactive Gesture

- (void)_interactiveTapGestureHandle:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self _setShowingPosition:MySideViewControllerPositionCenter animated:YES notifer:YES];
}

- (void)_interactivePanGestureHandle:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!self.transitioningContext) {
        return;
    }
    
    UIGestureRecognizerState  state = panGestureRecognizer.state;
    
    if (state == UIGestureRecognizerStateBegan) {
        
        _transitioningProgress = 0.f;
        _animatedTransitioning = [self _getAnimatedTransitioning];
        
        MySideViewControllerPosition position = self.transitioningContext.fromPosition == MySideViewControllerPositionCenter ? self.transitioningContext.toPosition : self.transitioningContext.fromPosition;
        if (position == MySideViewControllerPositionLeft) {
            _transitioningWidthScale = self.leftSideWidthScale;
        }else{
            _transitioningWidthScale = self.rightSideWidthScale;
        }
        
        if (self.transitioningContext.fromPosition != MySideViewControllerPositionCenter) {
            
            [[self viewControllerForPosition:self.transitioningContext.fromPosition] beginAppearanceTransition:NO animated:YES];
        }
        
        if (self.transitioningContext.toPosition != MySideViewControllerPositionCenter) {
            [self _addViewForPosition:self.transitioningContext.toPosition];
        }
        
        //开始
        [self _startTransitionWithContext:self.transitioningContext
                                animation:_animatedTransitioning
                                  notifer:YES];
        
        [[self viewControllerForPosition:MySideViewControllerPositionCenter] startSideViewControllerInteractiveTransitioning:self.transitioningContext];
        
    }else{
        
        CGPoint translation   = [panGestureRecognizer translationInView:self.layoutView];
        
        //计算进度
        _transitioningProgress += [self _progressForTranslation:translation];
        _transitioningProgress = ChangeInMinToMax(_transitioningProgress, 0.f, 1.f);
        
        if (state == UIGestureRecognizerStateChanged) {
        
            //更新
            [_animatedTransitioning updateViewForProgress:_transitioningProgress withContext:self.transitioningContext];
        }else{
            
            //速度
            CGFloat velocity = [self _progressForTranslation:[panGestureRecognizer velocityInView:self.layoutView]];
            
            CGFloat fraction = _transitioningProgress + velocity;
            
           
            MySideViewControllerPosition fromPosition = self.transitioningContext.fromPosition;
            MySideViewControllerPosition toPosition   = self.transitioningContext.toPosition;
            
            //完成过渡
            if (state == UIGestureRecognizerStateEnded && fraction >= 0.5f) {
                
                _showingPosition = toPosition;
                
                [self _completedTransitionWithContext:self.transitioningContext
                                            animation:_animatedTransitioning
                                        startProgress:_transitioningProgress
                                             velocity:velocity
                                             animated:YES
                                       completedBlock:^{
                                           
                                           if (fromPosition != MySideViewControllerPositionCenter) {
                                               
                                               [[self viewControllerForPosition:fromPosition] endAppearanceTransition];
                                           }
                                       
                                       } notifer:YES];
                
                //完成
                [[self viewControllerForPosition:MySideViewControllerPositionCenter] finishSideViewControllerInteractiveTransitioning:self.transitioningContext];
                
            }else{
                
                [self _cancelTransitionWithContext:self.transitioningContext
                                         animation:_animatedTransitioning
                                     startProgress:_transitioningProgress
                                          animated:YES
                                    completedBlock:^{
                                        
                                        if(fromPosition != MySideViewControllerPositionCenter){
                                            UIViewController * fromVC = [self viewControllerForPosition:fromPosition];
                                            
                                            [fromVC beginAppearanceTransition:YES animated:NO];
                                            [fromVC endAppearanceTransition];
                                        }
                
                                    } notifer:YES];
                
                //取消
                [[self viewControllerForPosition:MySideViewControllerPositionCenter] cancelSideViewControllerInteractiveTransitioning:self.transitioningContext];
                
            }
            
            self.transitioningContext = nil;
            _transitioningContext     = nil;
            _transitioningProgress    = 0.f;
        }
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.layoutView];
    }
}

- (CGFloat)_progressForTranslation:(CGPoint)translation
{
    return  ((self.transitioningContext.fromPosition - self.transitioningContext.toPosition) * translation.x / (CGRectGetWidth(self.view.bounds) * _transitioningWidthScale));
}

@end

//----------------------------------------------------------

@implementation _MySideViewControllerContextTransitioning
{
    NSDictionary * _frameDictionary;
}

@synthesize fromPosition  = _fromPosition;
@synthesize toPosition    = _toPosition;
@synthesize containerView = _containerView;
@synthesize fromView      = _fromView;
@synthesize toView        = _toView;

- (id)initWithSideViewController:(MySideViewController *)sideViewController
                    fromPosition:(MySideViewControllerPosition)fromPosition
                      toPosition:(MySideViewControllerPosition)toPosition
{
    
    self = [super init];
    
    if (self) {
        
        _fromPosition  = fromPosition;
        _toPosition    = toPosition;
        _containerView = sideViewController.layoutView;
        _fromView      = [sideViewController.layoutView superViewForPosition:fromPosition];
        _toView        = [sideViewController.layoutView superViewForPosition:toPosition];
        
        [self updateFrameWithSideViewController:sideViewController];
    }
    
    return self;
}

- (void)updateFrameWithSideViewController:(MySideViewController *)sideViewController
{
    NSMutableDictionary * frameDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    
    CGRect fromIR = [sideViewController viewShowingFrameForPosition:_fromPosition];
    CGRect toIR   = [sideViewController viewFrameForPosition:_toPosition withShowingPositon:_fromPosition];
    CGRect fromFR = [sideViewController viewFrameForPosition:_fromPosition withShowingPositon:_toPosition];
    CGRect toFR   = [sideViewController viewShowingFrameForPosition:_toPosition];
    
    [frameDictionary setObject:NSStringFromCGRect(fromIR) forKey:[self _initialFrameKeyForView:_fromView]];
    [frameDictionary setObject:NSStringFromCGRect(toIR)   forKey:[self _initialFrameKeyForView:_toView]];
    [frameDictionary setObject:NSStringFromCGRect(fromFR) forKey:[self _finalFrameKeyForView:_fromView]];
    [frameDictionary setObject:NSStringFromCGRect(toFR)   forKey:[self _finalFrameKeyForView:_toView]];
    
    _frameDictionary = frameDictionary;
}

- (CGRect)initialFrameForView:(UIView *)view
{
    return [self _frameForKey:[self _initialFrameKeyForView:view]];
}

- (CGRect)finalFrameForView:(UIView *)view
{
    return [self _frameForKey:[self _finalFrameKeyForView:view]];
}

- (CGRect)_frameForKey:(id<NSCopying>)key
{
    CGRect frame = CGRectZero;
    
    if (key) {
        
        id value = _frameDictionary[key];
        
        if ([value isKindOfClass:[NSValue class]]) {
            frame = [value CGRectValue];
        }else if ([value isKindOfClass:[NSString class]]){
            frame = CGRectFromString(value);
        }
    }
    
    return frame;
}

- (id<NSCopying>)_initialFrameKeyForView:(UIView *)view
{
    return view ? [NSString stringWithFormat:@"%ul_initial",(unsigned int)view] : nil;
}

- (id<NSCopying>)_finalFrameKeyForView:(UIView *)view
{
    return view ? [NSString stringWithFormat:@"%ul_final",(unsigned int)view] : nil;
}

@end

//----------------------------------------------------------


@implementation _MySideViewControllerLayoutView

- (id)initWithSideViewController:(MySideViewController *)sideViewController
{
    self = [super initWithFrame:sideViewController.view.bounds];
    
    if (self) {
        
        _sideViewController = sideViewController;
        
        _leftView   = [[UIView alloc] init];
        _centerView = [[UIView alloc] init];
        _rightView  = [[UIView alloc] init];
        
        [self addSubview:_leftView];
        [self addSubview:_rightView];
        [self addSubview:_centerView];
        
        [self _updatePosition];

        //设置阴影
        _centerView.layer.shadowOffset  = CGSizeZero;
        _centerView.layer.shadowOpacity = 1.f;

        //添加手势
        _interactivePanGesture = [[UIPanGestureRecognizer alloc] init];
        _interactivePanGesture.delegate = self;
        [self addGestureRecognizer:_interactivePanGesture];
        
        _interactiveTapGesture = [[UITapGestureRecognizer alloc] init];
        _interactiveTapGesture.delegate = self;
        [self addGestureRecognizer:_interactiveTapGesture];
        
    }
    return self;
}

- (void)_updatePosition
{
    MySideViewControllerPosition showingPosition = self.sideViewController.showingPosition;
    
    _centerView.userInteractionEnabled = (showingPosition == MySideViewControllerPositionCenter);
    _leftView.userInteractionEnabled   = (showingPosition == MySideViewControllerPositionLeft);
    _rightView.userInteractionEnabled  = (showingPosition == MySideViewControllerPositionRight);
    
}

- (void)updateSubViewsFrame
{
    MySideViewController * sideViewController = self.sideViewController;
    
    _leftView.frame = [sideViewController viewCurrentFrameForPosition:MySideViewControllerPositionLeft];
    _centerView.frame = [sideViewController viewCurrentFrameForPosition:MySideViewControllerPositionCenter];
    _rightView.frame = [sideViewController viewCurrentFrameForPosition:MySideViewControllerPositionRight];
    
    
    //设置阴影路径
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:CGRectMake(0.f, 0.f, 5.f, CGRectGetHeight(_centerView.bounds))];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetWidth(_centerView.bounds) - 5.f, 0.f, 5.f, CGRectGetHeight(_centerView.bounds))]];
    _centerView.layer.shadowPath = path.CGPath;
}


- (UIView *)superViewForPosition:(MySideViewControllerPosition)position
{
    switch (position) {
        case MySideViewControllerPositionLeft:
            return self.leftView;
            break;
            
        case MySideViewControllerPositionRight:
            return self.rightView;
            break;
            
        default:
            return self.centerView;
            break;
    }
}

- (void)completedTransitionWithContext:(id<MySideViewControllerContextTransitioning>)context
                             animation:(id<MySideViewControllerAnimatedTransitioning>)animation
                         startProgress:(CGFloat)startProgress
                              velocity:(CGFloat)velocity
                              animated:(BOOL)animated
                        completedBlock:(void(^)())completedBlock
{
    [self _transitionWithContext:context
                       animation:animation
                   startProgress:startProgress
                     endProgress:1.f
                        velocity:velocity
                        animated:animated
                  completedBlock:^{
                      
                      [animation endUpdateViewWithContext:context];
                      
                      if (completedBlock) {
                          completedBlock();
                      }
                      
                      //更新位置
                      [self _updatePosition];
                  }];

}

- (void)cancleTransitionWithContext:(id<MySideViewControllerContextTransitioning>)context
                          animation:(id<MySideViewControllerAnimatedTransitioning>)animation
                      startProgress:(CGFloat)startProgress
                           animated:(BOOL)animated
                     completedBlock:(void(^)())completedBlock
{
    
    [self _transitionWithContext:context
                       animation:animation
                   startProgress:startProgress
                     endProgress:0.f
                        velocity:0.f
                        animated:animated
                  completedBlock:^{
                      
                      [animation cancleUpdateViewWithContext:context];
                      
                      if (completedBlock) {
                          completedBlock();
                      }
                      
                      //更新位置
                      [self _updatePosition];
                  }];
}



- (void)_transitionWithContext:(id<MySideViewControllerContextTransitioning>)context
                     animation:(id<MySideViewControllerAnimatedTransitioning>)animation
                 startProgress:(CGFloat)startProgress
                   endProgress:(CGFloat)endProgress
                      velocity:(CGFloat)velocity
                      animated:(BOOL)animated
                completedBlock:(void(^)())completedBlock
{
    assert(startProgress >= 0.f && startProgress <= 1.f);
    assert(endProgress   >= 0.f && endProgress   <= 1.f);
    
    if (animated) {
        
        [animation updateViewForProgress:startProgress withContext:context];
        
        CGFloat progressLength = fabs(startProgress - endProgress);
        NSTimeInterval transitionDuration = [animation transitionDuration:context] * progressLength;
        
        if (velocity > 0.f) {
            
            CGFloat _tempDuration = progressLength * progressLength * 2 / velocity;
            transitionDuration = MIN(transitionDuration, _tempDuration);
        }
        
        transitionDuration = MAX(0.1f, transitionDuration);
        
        [UIView animateWithDuration:transitionDuration
                              delay:0.f
                            options: (velocity > 1.f) ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [animation updateViewForProgress:endProgress withContext:context];
                         }
                         completion:^(BOOL finished){
                             
                             if (completedBlock) {
                                 completedBlock();
                             }
                             
                         }];
        
    }else{
        [animation updateViewForProgress:endProgress withContext:context];
        
        if (completedBlock) {
            completedBlock();
        }
    }

}


#pragma mark - gesture delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //交互手势识别下任何其他手势都无效
    return (gestureRecognizer == _interactivePanGesture);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    MySideViewController * sideViewController = self.sideViewController;
    
    if (!sideViewController.transitioning && sideViewController.isInteractiveTransitioningEnabled) {
        
        UIViewController * centerViewController = [sideViewController viewControllerForPosition:MySideViewControllerPositionCenter];
        
        BOOL interactiveTransitioningEnabled = YES;
        
        if (centerViewController) {
            interactiveTransitioningEnabled = [centerViewController isSideViewControllerInteractiveTransitioningEnabled];
        }

        if (gestureRecognizer == _interactiveTapGesture) {
            
            interactiveTransitioningEnabled = interactiveTransitioningEnabled              &&
                (sideViewController.showingPosition != MySideViewControllerPositionCenter) &&
                CGRectContainsPoint(self.centerView.frame, [touch locationInView:self]);
            
        }else{
            
            interactiveTransitioningEnabled = interactiveTransitioningEnabled &&
                ((sideViewController.showingPosition == MySideViewControllerPositionCenter) ||CGRectContainsPoint(self.centerView.frame, [touch locationInView:self]));
            
        }
        
        return interactiveTransitioningEnabled;
    }
    
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _interactivePanGesture) {
        
        CGPoint translation = [_interactivePanGesture translationInView:self];
        
        //水平方向的偏移
        if (fabsf(translation.x) > fabsf(translation.y)) {
            
            MySideViewController * sideViewController = self.sideViewController;
            MySideViewControllerPosition position = sideViewController.showingPosition;
            
            //确定下一个位置
            NSInteger nextPosition = (NSInteger)position + (translation.x < 0 ? 1 : -1);
            
            //在有效范围内
            if (MySideViewControllerPositionLeft <= nextPosition && nextPosition <= MySideViewControllerPositionRight) {
                
                //nextPosition存在页面
                if ([sideViewController viewControllerForPosition:nextPosition] ) {
                    
                    id<MySideViewControllerContextTransitioning> context = [[_MySideViewControllerContextTransitioning alloc] initWithSideViewController:sideViewController fromPosition:position toPosition:nextPosition];
                    
                    BOOL bRet = YES;
                    
                    UIViewController * centerViewController = [sideViewController viewControllerForPosition:MySideViewControllerPositionCenter];
                    
                    if (centerViewController) {
                        
                        bRet = [centerViewController sideViewControllerInteractiveTransitioningShouldBeginWithPoint:[_interactivePanGesture locationInView:_centerView] context:context];
                    }
                    
                    if (bRet) {
                        sideViewController.transitioningContext = context;
                    }
                    
                    return bRet;
                }
            }
        }
        
        return NO;
    }
 
    return YES;
}

@end

//----------------------------------------------------------

static char SideViewControllerInteractiveTransitioningEnableKey;

@implementation UIViewController (MySideViewController)

- (MySideViewController *)sideViewController
{
    MySideViewController * sideViewController = nil;
    
    if ([self isKindOfClass:[MySideViewController class]]) {
        sideViewController = (MySideViewController *)self;
    }else{
        sideViewController = [self.parentViewController sideViewController];
    }
    
    return sideViewController;
}

- (id<MySideViewControllerAnimatedTransitioning>)sideViewControllerAnimatedTransitioning
{
    UIViewController * childViewController = [self childViewControllerForSideViewControllerTransitioning];
    
    return childViewController ? [childViewController sideViewControllerAnimatedTransitioning] : nil;
}

-(void)setSideViewControllerInteractiveTransitioningEnable:(BOOL)sideViewControllerInteractiveTransitioningEnable
{
    objc_setAssociatedObject(self, & SideViewControllerInteractiveTransitioningEnableKey, sideViewControllerInteractiveTransitioningEnable ? @YES : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSideViewControllerInteractiveTransitioningEnabled
{
    UIViewController * childViewController = [self childViewControllerForSideViewControllerTransitioning];
    
    return childViewController ? [childViewController isSideViewControllerInteractiveTransitioningEnabled] : [objc_getAssociatedObject(self, &SideViewControllerInteractiveTransitioningEnableKey) boolValue];
}

- (BOOL)isSideViewControllerTransitioning
{
    return [self sideViewController].isTransitioning;
}

- (BOOL)sideViewControllerInteractiveTransitioningShouldBeginWithPoint:(CGPoint)point context:(id <MySideViewControllerContextTransitioning>)transitionContext
{
    UIViewController * childViewController = [self childViewControllerForSideViewControllerTransitioning];
    
    return childViewController ? [childViewController sideViewControllerInteractiveTransitioningShouldBeginWithPoint:point context:transitionContext] : YES;
}

- (void)startSideViewControllerInteractiveTransitioning:(id<MySideViewControllerContextTransitioning>)transitionContext
{
    UIViewController * childViewController = [self childViewControllerForSideViewControllerTransitioning];
    
    [childViewController startSideViewControllerInteractiveTransitioning:transitionContext];
}

-(void)finishSideViewControllerInteractiveTransitioning:(id<MySideViewControllerContextTransitioning>)transitionContext
{
    UIViewController * childViewController = [self childViewControllerForSideViewControllerTransitioning];
    
    [childViewController finishSideViewControllerInteractiveTransitioning:transitionContext];
}

- (void)cancelSideViewControllerInteractiveTransitioning:(id<MySideViewControllerContextTransitioning>)transitionContext
{
    UIViewController * childViewController = [self childViewControllerForSideViewControllerTransitioning];
    
    [childViewController cancelSideViewControllerInteractiveTransitioning:transitionContext];
}

- (UIViewController *)childViewControllerForSideViewControllerTransitioning
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




