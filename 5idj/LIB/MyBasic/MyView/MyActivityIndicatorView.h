//
//  MyActivityIndicatorView.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-25.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@protocol  MyActivityIndicatorViewProtocol

/**
 * 是否在停止动作时隐藏，默认为YES
 */
@property(nonatomic) BOOL hidesWhenStopped;

///**
// * 颜色，默认为灰色
// */
//@property(readwrite, nonatomic, retain) UIColor *color UI_APPEARANCE_SELECTOR;


- (void)startAnimating;
- (void)stopAnimating;


- (BOOL)isAnimating;

@end

//----------------------------------------------------------


typedef NS_ENUM(int, MyActivityIndicatorViewStyle) {
    MyActivityIndicatorViewStyleIndeterminate,
    MyActivityIndicatorViewStyleDeterminate
};

//----------------------------------------------------------

@interface MyActivityIndicatorView : UIView <MyActivityIndicatorViewProtocol>

- (id)initWithStyle:(MyActivityIndicatorViewStyle)style;

/**
 * 风格，默认为MyActivityIndicatorViewStyleIndeterminate
 */
@property(nonatomic) MyActivityIndicatorViewStyle style;


/**
 * 线的宽度，默认为1
 */
@property(nonatomic) CGFloat    lineWidth;


/**
 * 是否是顺时针方向旋转，默认为YES
 */
@property(nonatomic) BOOL       clockwise;

/**
 * 开始动画时是否分为两步，默认为NO
 */
@property(nonatomic) BOOL       twoStepAnimation;


/**
 * MyActivityIndicatorViewStyleIndeterminate风格时的进度默认为0.9f
 */
@property(nonatomic) float      indeterminateProgress;

/**
 * 进度，取值在0.f - 1.f
 * 对于MyActivityIndicatorViewStyleIndeterminate风格进度恒为indeterminateProgress，且更改此值会被忽略
 */
@property(nonatomic) float  progress;

@end
