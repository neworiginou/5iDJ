//
//  GP_BasicSegmentViewController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicSubViewController.h"

//----------------------------------------------------------

@interface GP_BasicSegmentViewController : GP_BasicSubViewController <UIGestureRecognizerDelegate>

- (id)initWithSemgentedItemArray:(NSArray *)itemArray;

@property(nonatomic,strong,readonly) UISegmentedControl * segmentedControl;

//过渡动画的布局视图
@property(nonatomic,strong,readonly) UIView * transitionLayoutView;

//是否正在过去
@property(nonatomic,readonly) BOOL isTransiting;

//是否需要过渡动画当选择的index改变时
@property(nonatomic) BOOL needTransitionWhenSelectIndexChange;

//选择的index改变
- (void)segmentedSelectedIndexChangeHandle;

//是否需要手势改变选择的索引，默认为YES
@property(nonatomic) BOOL needGestureChangeSelectedIndex;

- (UIScrollView *)contentView;


@end
