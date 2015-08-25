//
//  GP_BasicSegmentViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicSegmentViewController.h"
#import "GP_SwipeChangeTabHelpView.h"

//----------------------------------------------------------


@implementation GP_BasicSegmentViewController
{
    UISwipeGestureRecognizer * _leftSwipeGestureRecognizer;
    UISwipeGestureRecognizer * _rightSwipeGestureRecognizer;
    
    UIView * _segmentedControlBGView;
}

- (BOOL)isSupportFullScreenMode
{
    return YES;
}

- (CGFloat)topExtentViewHeight
{
    return 50.f;
}

- (BOOL)fullScreenModeIncludeTopExtentView
{
    return YES;
}

- (NSString *)backHelpViewText
{
    return @"亲，从左边缘向右横滑可以返回哟";
}

- (id)initWithSemgentedItemArray:(NSArray *)itemArray
{
    self = [super initWithNibName:nil bundle:nil];
    
    if(self){
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        _segmentedControl.frame = CGRectMake(10.f, 10.f, screenSize().width - 20.f, 30.f);
        _segmentedControl.tintColor = [self currentThemeColor];
        
        //设置文本属性
        [_segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont boldSystemFontOfSize:15],NSFontAttributeName,
                                            defaultTitleTextColor,NSForegroundColorAttributeName,nil]
                                            forState:UIControlStateNormal];
        
        _segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        
        [_segmentedControl addTarget:self action:@selector(segmentedSelectedIndexChangeHandle) forControlEvents:UIControlEventValueChanged];
        
        
        _needTransitionWhenSelectIndexChange = YES;
        
        //监听改变
        [_segmentedControl addObserver:self forKeyPath:@"selectedSegmentIndex" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    }
    
    return self;
}

- (void)dealloc
{
    [_segmentedControl removeObserver:self forKeyPath:@"selectedSegmentIndex"];
}


- (void)didChangeThemeColor
{
    _segmentedControl.tintColor = [self currentThemeColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.needGestureChangeSelectedIndex    = YES;
    
    //...
    _segmentedControlBGView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 64.f, screenSize().width, 50.f)];
    _segmentedControlBGView.backgroundColor = defaultCellBackgroundColor;
    [self.topExtentView addSubview:_segmentedControlBGView];
    [_segmentedControlBGView addSubview:_segmentedControl];
    
    //过渡视图
    _transitionLayoutView = [[UIView alloc] initWithFrame:self.view.bounds];
    _transitionLayoutView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                             UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_transitionLayoutView];
}

- (UIScrollView *)contentView
{
    return nil;
}

- (void)setNeedGestureChangeSelectedIndex:(BOOL)needGestureChangeSelectedIndex
{
    if (_needGestureChangeSelectedIndex != needGestureChangeSelectedIndex) {
        
        if (_needGestureChangeSelectedIndex) {

            [self.view removeGestureRecognizer:_leftSwipeGestureRecognizer];
            [self.view removeGestureRecognizer:_rightSwipeGestureRecognizer];
            
            [self contentView].delaysContentTouches = YES;
        }
        
        _needGestureChangeSelectedIndex = needGestureChangeSelectedIndex;
        
        if (_needGestureChangeSelectedIndex) {
            
            [self contentView].delaysContentTouches = NO;
            
            if (!_leftSwipeGestureRecognizer) {
                _leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipeGestureHandle:)];
                _leftSwipeGestureRecognizer.delegate = self;
                _leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            }
            
            [self.view addGestureRecognizer:_leftSwipeGestureRecognizer];
            
            if (!_rightSwipeGestureRecognizer) {
                _rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipeGestureHandle:)];
                _rightSwipeGestureRecognizer.delegate = self;
                _rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            }
            
            [self.view addGestureRecognizer:_rightSwipeGestureRecognizer];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == _leftSwipeGestureRecognizer || gestureRecognizer == _rightSwipeGestureRecognizer) {
        if (!self.isFullScreenMode && !self.isTransiting && [touch locationInView:self.segmentedControl].y > 40.f) {
            return (gestureRecognizer == _rightSwipeGestureRecognizer) ? self.segmentedControl.selectedSegmentIndex != 0 : self.segmentedControl.selectedSegmentIndex != self.segmentedControl.numberOfSegments - 1;
        }
        return NO;
    }
    return YES;
}


- (void)_swipeGestureHandle:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    NSInteger targetIndex = self.segmentedControl.selectedSegmentIndex + (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft  ? 1 : -1);

    //选择的索引改变
    self.segmentedControl.selectedSegmentIndex = targetIndex;
    [self segmentedSelectedIndexChangeHandle];
}


- (void)segmentedSelectedIndexChangeHandle
{
    GP_SwipeChangeTabHelpView * swipeChangeTabHelpView = [[GP_SwipeChangeTabHelpView alloc] initWithKey:@"HadShowSwipeChangeSelectIndexHelpView"];
    [swipeChangeTabHelpView show];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedSegmentIndex"] && _needTransitionWhenSelectIndexChange) {
        
        NSInteger oldIndex = [[change objectForKey:@"old"] integerValue];
        NSInteger newIndex = [[change objectForKey:@"new"] integerValue];
        
        if (oldIndex != UISegmentedControlNoSegment && newIndex != UISegmentedControlNoSegment ) {
            
            _isTransiting = YES;
            
            //过渡效果
            [UIView transitionWithView:self.view duration:0.5f
                               options:newIndex > oldIndex ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{
                                
                                for (UIView * view in _transitionLayoutView.subviews) {
                                    [view removeFromSuperview];
                                    [_transitionLayoutView addSubview:view];
                                }
                                
                            } completion:^(BOOL finishwd){
                                _isTransiting = NO;
                            }];
        }
        
    }
}

- (BOOL)interactivePopGestureShouldReceiveTouch:(UITouch *)touch
{
    if (self.segmentedControl.numberOfSegments > 1) {
        return [touch locationInView:self.view].x <= 40.f * screenWidthScaleFactor();
    }
    
    return YES;
}


- (void)setFullScreenMode:(BOOL)fullScreenMode
                 animated:(BOOL)animated
           animationBlock:(void (^)())animationBlock
            completeBlock:(void (^)())completeBlock
{
    typeof(self) __weak weak_self = self;
    
    [super setFullScreenMode:fullScreenMode
                    animated:animated
              animationBlock:animated ? ^{
                  
                  typeof(self) _self = weak_self;
                  _self->_segmentedControlBGView.alpha = fullScreenMode ? 0.f : 1.f;
                  
                  if (animationBlock) {
                      animationBlock();
                  }
    
              } : nil
               completeBlock:animated ? completeBlock : ^{
                   
                   typeof(self) _self = weak_self;
                   _self->_segmentedControlBGView.alpha = fullScreenMode ? 0.f : 1.f;
                   
                   if (completeBlock) {
                       completeBlock();
                   }
                   
               }];
}



@end
