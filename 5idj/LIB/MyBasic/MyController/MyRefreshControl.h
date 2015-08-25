//
//  MyRefreshControl.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-16.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyActivityIndicatorView.h"


//----------------------------------------------------------

/**
 * 刷新控件的风格，上刷新控件和下刷新控件
 */
typedef NS_ENUM(int, MyRefreshControlStyle){
    /* 上刷新控件 */
    MyRefreshControlStyleTop,
    /* 下刷新控件 */
    MyRefreshControlStyleBottom
};



//----------------------------------------------------------

/**
 *  刷新控件，必需作为UIScrollView的子视图，刷新激活时发送UIControlEventValueChanged事件
 */
@interface MyRefreshControl : UIControl

/**
 * 通过风格初始化，默认风格为MyRefreshControlStyleTop
 */
- (id)initWithStyle:(MyRefreshControlStyle)style;

/**
 * 定位时Y轴的偏移量，当需要在上端预留出一部分空间可使用此值，此值不影响更新响应所需要的偏移值
 * 比如将此值设为10，那么刷新控件定位会多向上(下)偏移10，但响应更新所需的偏移临界值不变
 * 正为向上(下)偏移，负则为向下(上)偏移，默认为0
 */
@property(nonatomic) CGFloat locationOffsetY;

/**
 *  滑动时响应更新的Y轴偏移量的偏移值。
 *  比如将此值设为10，响应更新所需的偏移临界值也需要多向下(上)滑动10
 *  正为向上(下)偏移，负则为向下(上)偏移，默认为0
 */
@property(nonatomic) CGFloat scorllOffsetY;

/**
 *  刷新状态，为YES则在刷新
 */
@property(nonatomic,readonly,getter = isRefreshing) BOOL refreshing;

/**
 *  出现状态，为YES表示出现
 */
@property(nonatomic,readonly,getter = isShowing) BOOL showing;


/**
 *  alpha是否随滑动改变，默认为YES
 */
@property(nonatomic) BOOL alphaChangeWithScroll;


///**
// * 设置不可用状态
// */
//- (void)setUnEnableWithTitle:(NSString *)title;

/**
 * 刷新指示的箭头的图片
 */
//@property(nonatomic,strong) UIImage  *arrowImage;

/**
 * 标签的文本的颜色，默认为黑色
 */
@property(nonatomic,strong) UIColor *textColor UI_APPEARANCE_SELECTOR;

///**
// * 活动指示器
// */
//@property(nonatomic,strong,readonly) id<MyActivityIndicatorViewProtocol> activityIndicatorView;

/*
 *活动指示器风格，默认为UIActivityIndicatorViewStyleGray
 */
//@property(nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle UI_APPEARANCE_SELECTOR;

/**
 * 活动指示器颜色,默认为nil
 */
//@property(nonatomic,strong) UIColor *activityIndicatorViewColor UI_APPEARANCE_SELECTOR;

/**
 * 背景视图
 */
@property(nonatomic,strong,readonly) UIView *backgrounpView UI_APPEARANCE_SELECTOR;


/*
 *刷新文字，即刷新时显示的文字，默认为“正在刷新...”
 */
@property(nonatomic,strong) NSString * refreshingText;

/*
 *手动开始刷新
 */
- (void)beginRefreshing;

/*
 *手动结束刷新
 */
- (void)endRefreshing;

@end
