//
//  MyRefreshControl.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-16.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyRefreshControl.h"
#import "MacroDef.h"

//----------------------------------------------------------

/*
 *刷新控件高度
 */
#define RefreshControlHeight 50

//----------------------------------------------------------

@interface MyRefreshControl ()

/**
 *  开始刷新
 */
- (void)_startRefreshing;

/**
 *  注册KVO消息
 */
- (void)_registerKVO;

/**
 *  取消注册KVO消息
 */
- (void)_unRegisterKVO;

/**
 *  更新frame
 */
- (void)_updateFrame;

/**
 *  更新标签文本
 */
- (void)_updateTitleText;

/**
 *  滑动偏移
 */
- (void)_scrollOffset:(CGFloat)offset;

/**
 *  设置用于刷新的ContentInset
 */
- (void)_setContentInsetForRefreshing;

/**
 *  设置用于刷新的ContentOffset
 */
- (void)_setContentOffsetForRefreshing;

/**
 *  更新更新状态时的offset和inset
 */
- (void)_updateRefreshingPosition;

@end

//----------------------------------------------------------

@implementation MyRefreshControl
{
    MyRefreshControlStyle    _style;

    __weak UIScrollView     *_scrollView;
    
    UILabel                 *_titleLabel;
    MyActivityIndicatorView *_activityIndicatorView;
    
    UIEdgeInsets             _originalContentInset;
    
    BOOL                     _ignoreChange;
    BOOL                     _readyToRefresh;
    BOOL                     _hasRegisterObserver;
}

@synthesize textColor                  = _textColor;
@synthesize backgrounpView             = _backgrounpView;
@synthesize refreshingText             = _refreshingText;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithStyle:MyRefreshControlStyleTop];
}


- (id)initWithStyle:(MyRefreshControlStyle)style
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        
        _style = style;
        
        _originalContentInset = UIEdgeInsetsZero;
        _locationOffsetY = 0.f;
        _scorllOffsetY = 0.f;
        
        _alphaChangeWithScroll = YES;
        
        //初始化子视图
        
        //titleLabel
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = self.textColor;
        [self _updateTitleText];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        
        //刷新活动指示器
        _activityIndicatorView = [[MyActivityIndicatorView alloc] initWithStyle:MyActivityIndicatorViewStyleDeterminate];
        _activityIndicatorView.bounds           = CGRectMake(0.f, 0.f, 30.f, 30.f);
        _activityIndicatorView.hidesWhenStopped = NO;
        _activityIndicatorView.clockwise        = style == MyRefreshControlStyleTop;
        _activityIndicatorView.twoStepAnimation = NO;
        [self addSubview:_activityIndicatorView];


    }
    
    return self;
}

//- (void)dealloc
//{
//    [self _unRegisterKVO];
//}


#pragma MARK - FRAME

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _activityIndicatorView.center = CGPointMake(CGRectGetWidth(bounds) * 0.3f, CGRectGetMidY(bounds));
    _titleLabel.bounds = CGRectMake(0.f, 0.f, CGRectGetWidth(bounds) * 0.35f, CGRectGetHeight(bounds));
    _titleLabel.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

}


- (void)setFrame:(CGRect)frame
{
    [self _updateFrame];
}

- (void)setBounds:(CGRect)bounds
{
    [self _updateFrame];
}

- (void)setLocationOffsetY:(CGFloat)locationOffsetY
{
    if (_locationOffsetY != locationOffsetY) {
        _locationOffsetY = locationOffsetY;
        
        [self _updateFrame];
    }
}

- (void)setScorllOffsetY:(CGFloat)scorllOffsetY
{
    if (_scorllOffsetY != scorllOffsetY) {
        _scorllOffsetY = scorllOffsetY;
        
        [self _updateRefreshingPosition];
    }
}

- (void)_updateFrame
{
    UIScrollView * scrollView = _scrollView;
    
    
    CGFloat y = 0;
    
    if (_style == MyRefreshControlStyleTop) {
        y = - _locationOffsetY - RefreshControlHeight;
    }else{
        
        CGSize contentSize = scrollView.contentSize;
        
        CGFloat canShowHeight = CGRectGetHeight(scrollView.bounds) -  _originalContentInset.top - _originalContentInset.bottom;
        
        y = MAX(canShowHeight, contentSize.height) + _locationOffsetY;
    }
    
    [super setFrame:CGRectMake(0, y, CGRectGetWidth(scrollView.bounds), RefreshControlHeight)];
    [self setNeedsLayout];
    
    //更新
    [self _updateRefreshingPosition];
}

#pragma MARK - UI


- (void)setAlpha:(CGFloat)alpha
{
    if (!_alphaChangeWithScroll) {
        super.alpha = alpha;
    }
}

- (void)setAlphaChangeWithScroll:(BOOL)alphaChangeWithScroll
{
    if (_alphaChangeWithScroll != alphaChangeWithScroll) {
        _alphaChangeWithScroll = alphaChangeWithScroll;
        
        super.alpha = 1.f;
    }
}


- (UIColor *)textColor
{
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    
    return _textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor) {
        _textColor = textColor;
        
        _titleLabel.textColor = self.textColor;
    }
}

- (UIView *)backgrounpView
{
    if (!_backgrounpView) {
        _backgrounpView = [[UIView alloc] initWithFrame:self.bounds];
        _backgrounpView.backgroundColor = [UIColor clearColor];
        
        [self insertSubview:_backgrounpView atIndex:0];
    }
    
    return _backgrounpView;
}

- (NSString *)refreshingText
{
    if (!_refreshingText) {
        _refreshingText = (_style == MyRefreshControlStyleTop) ? @"正在刷新..." : @"正在加载...";
    }
    
    return _refreshingText;
}

- (void)setRefreshingText:(NSString *)refreshingText
{
    _refreshingText = refreshingText;
    
    [self _updateTitleText];
}


#pragma MARK - KVO

- (void)_registerKVO
{
    UIScrollView *scrollView = _scrollView;
    
    if (!_hasRegisterObserver && scrollView) {
        _hasRegisterObserver = YES;
        
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld context:nil];
        [scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        
        if (_style == MyRefreshControlStyleBottom) {
            [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        }
    }
}

- (void)_unRegisterKVO
{
    UIScrollView *scrollView = _scrollView;
    
    if (_hasRegisterObserver && scrollView) {
        _hasRegisterObserver = NO;
        
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [scrollView removeObserver:self forKeyPath:@"contentInset"];
        [scrollView removeObserver:self forKeyPath:@"frame"];
        
        if (_style == MyRefreshControlStyleBottom) {
            [scrollView removeObserver:self forKeyPath:@"contentSize"];
        }
    }
}

- (void)_updateTitleText
{
    if (_refreshing) {
        _titleLabel.text = self.refreshingText;
    }else if (!_readyToRefresh){
        _titleLabel.text = (_style == MyRefreshControlStyleTop) ? @"下拉刷新" : @"上拉加载";
    }else{
        _titleLabel.text = (_style == MyRefreshControlStyleTop) ? @"松开刷新" : @"松开加载";
    }
}


- (void)setEnabled:(BOOL)enabled
{
    if (!enabled) {
        [self endRefreshing];
    }
    
    [super setEnabled:enabled];
}

- (void)setHidden:(BOOL)hidden
{
    if (hidden) {
        [self endRefreshing];
    }
    
    [super setHidden:hidden];
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        
        if (![newSuperview isKindOfClass:[UIScrollView class]]) {
            
            @throw  [[NSException alloc] initWithName:NSInternalInconsistencyException
                                               reason:@"刷新控件只能为UIScrollView的子视图"
                                             userInfo:nil];
        }
        
        //相关变量初始化
        _readyToRefresh = NO;
        _refreshing = NO;
        _ignoreChange = NO;
        _showing = NO;
        _activityIndicatorView.style = MyActivityIndicatorViewStyleDeterminate;
        
        //设置透明敷
        if (_alphaChangeWithScroll) {
            super.alpha = 0.f;
        }
        
        //更新标签文字
        [self _updateTitleText];
        
        //记录滑动视图
        _scrollView = (UIScrollView *)newSuperview;
        
        //设置初始位置
        _originalContentInset = [(UIScrollView *)newSuperview contentInset];
        
        //更新frame
        [self _updateFrame];
        
        //注册KVO
        [self _registerKVO];
        
    }else {
        
        //取消注册KVO
        [self _unRegisterKVO];
        
        _scrollView = nil;
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if(!newWindow){
        [self _unRegisterKVO];
    }else{
        [self _registerKVO];
        [self _updateFrame];
    }
}

//- (void)didMoveToWindow
//{
//    //当变为显示状态需要更新状态改变
//    if (self.window && _needUpdateRefreshStatusWhenMoveToWindow) {
//        
//        _needUpdateRefreshStatusWhenMoveToWindow = NO;
//        
//        _refreshing = !_refreshing;
//        if (_refreshing) {
//            [self endRefreshing];
//        }else {
//            [self beginRefreshing];
//        }
//    }
//}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UIScrollView *scrollView = object;
    
//    NSLog(@"\nchangePath = %@ \nchangeValue = %@ \ncontentOffset.y = %f \ncontentInset.top = %f \n",keyPath,[change objectForKey:@"new"],scrollView.contentOffset.y,scrollView.contentInset.top);

    if ([keyPath isEqualToString:@"frame"] ){
        [self _updateFrame];
    }else if([keyPath isEqualToString:@"contentSize"]) {
        
        if (![[change objectForKey:@"old"] isEqualToValue:[change objectForKey:@"new"]]) {
            [self _updateFrame];
        }
        
    }else if ([keyPath isEqualToString:@"contentInset"]) {
        
        if (_ignoreChange) {
            return;
        }
        
        _originalContentInset = scrollView.contentInset;
        
        if (_style == MyRefreshControlStyleBottom) {
            [self _updateFrame];
        }else{
            [self _updateRefreshingPosition];
        }
        
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        
        if (_ignoreChange || !self.enabled || self.isHidden) {
            return;
        }
        
        //相对偏移量
        CGFloat offset = 0;
        
        if (_style == MyRefreshControlStyleTop) {
            offset = - scrollView.contentOffset.y - _scorllOffsetY - _originalContentInset.top;
        }else{
            
            float minYInFrame = CGRectGetMinY(self.frame) - scrollView.contentOffset.y;
            offset = CGRectGetHeight(scrollView.bounds) - _originalContentInset.bottom - minYInFrame - _scorllOffsetY + _locationOffsetY;
        }
        
        [self _scrollOffset:offset];

    }
}

- (void)_scrollOffset:(CGFloat)offset
{
    UIScrollView * scrollView = _scrollView;
    
    _showing = (offset > 0);
    
    if (_refreshing ) {
        
        if (_style == MyRefreshControlStyleTop) {
            
            //更改contentInset确保表头显示正确
            _ignoreChange = YES;
            
            UIEdgeInsets contentInset = _originalContentInset;
            
            if (offset >= RefreshControlHeight) {
                contentInset.top += (RefreshControlHeight + _scorllOffsetY);
            }else if (offset > 0 ) {
                contentInset.top += (offset + _scorllOffsetY);
            }
            
            scrollView.contentInset = contentInset;
            
            _ignoreChange = NO;
        }
        
    }else {
        
        //已经准备刷新且手放开
        if(_readyToRefresh && !scrollView.isTracking){
            
            //开始刷新
            _readyToRefresh = NO;
//            _activityIndicatorView.style = MyActivityIndicatorViewStyleIndeterminate;
//            _arrowImageView.transform = CGAffineTransformConcat(_arrowImageView.transform, CGAffineTransformMakeRotation(- M_PI));// CGAffineTransformMakeRotation(0.f);
            
            //记录当前偏移量
            CGPoint contentOffset = scrollView.contentOffset;
            
            //开始刷新
            [self _startRefreshing];
            
            //恢复到之前偏移量
            _ignoreChange = YES;
            _scrollView.contentOffset = contentOffset;
            _ignoreChange = NO;
            
            //发开始刷新事件消息
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            
            return;
        }
        
        
        if (offset > RefreshControlHeight) { //已经全部显示
            
            if (!_readyToRefresh && self.enabled && scrollView.isTracking) {
                
                _readyToRefresh = YES;
                
                _activityIndicatorView.progress = _activityIndicatorView.indeterminateProgress;
                
                if (_alphaChangeWithScroll) {
                    super.alpha = 1.f;
                }
                
//                //箭头转向
//                [UIView animateWithDuration:0.2f animations:^{
//                    
//                    _arrowImageView.transform = CGAffineTransformConcat(_arrowImageView.transform, CGAffineTransformMakeRotation(M_PI));
//                }];
                
                [self _updateTitleText];
                
            }
        } else if (offset > 0 ){
            
            _activityIndicatorView.progress = offset / RefreshControlHeight * _activityIndicatorView.indeterminateProgress;
            
            if (_alphaChangeWithScroll) {
                super.alpha = offset / RefreshControlHeight;
            }
            
            if (_readyToRefresh) {
                _readyToRefresh = NO;

//                [UIView animateWithDuration:0.2f animations:^{
//                    _arrowImageView.transform = CGAffineTransformConcat(_arrowImageView.transform, CGAffineTransformMakeRotation(- M_PI));;
//                }];
                
                [self _updateTitleText];
            }
        }
    }
}


- (void)_setContentInsetForRefreshing
{
    _ignoreChange = YES;
    
    UIEdgeInsets contentInset = _originalContentInset;
    
    if (_style == MyRefreshControlStyleTop){
        contentInset.top += (RefreshControlHeight + _scorllOffsetY);
    }else{
        
        UIScrollView * scrollView = _scrollView;
        
        CGFloat offset = CGRectGetHeight(scrollView.bounds) - _originalContentInset.top - _originalContentInset.bottom - scrollView.contentSize.height;
        offset = MAX(0.f, offset);
        
        contentInset.bottom += (RefreshControlHeight + _scorllOffsetY + offset);
    }
    
    _scrollView.contentInset = contentInset;
    
    _ignoreChange = NO;

}

- (void)_setContentOffsetForRefreshing
{
    CGFloat offsetY = 0;
    
    if (_style == MyRefreshControlStyleTop) {
        offsetY = - _originalContentInset.top - RefreshControlHeight -  _scorllOffsetY;
    }else{
        
        UIScrollView * scrollView = _scrollView;
        
        offsetY =  CGRectGetMaxY(self.frame) - _locationOffsetY - CGRectGetHeight(scrollView.frame) + _originalContentInset.bottom + _scorllOffsetY;
    }
    
    _scrollView.contentOffset = CGPointMake(0, offsetY);
}


- (void)_updateRefreshingPosition
{
    if (_refreshing) {
        
        [self _setContentInsetForRefreshing];
        [self _setContentOffsetForRefreshing];
    }
}


- (void)_startRefreshing
{
    _refreshing = YES;
    
    _activityIndicatorView.style = MyActivityIndicatorViewStyleIndeterminate;
    
    [_activityIndicatorView startAnimating];
    
//    _activityIndicatorView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
//    
//    [UIView animateWithDuration:0.2f animations:^{
//        _activityIndicatorView.transform = CGAffineTransformMakeScale(1.f, 1.f);
//    }];
//    
//    _arrowImageView.hidden = YES;
    
    [self _updateTitleText];

    [self _setContentInsetForRefreshing];
}


- (void)beginRefreshing
{
    if (!_refreshing && _scrollView && self.enabled && !self.isHidden) {
        
//        //防止不在显示状态时更新位置发生错误
//        if (!self.window) {
//            
//            _refreshing = YES;
//            _needUpdateRefreshStatusWhenMoveToWindow = ! _needUpdateRefreshStatusWhenMoveToWindow;
//            
//            return;
//        }
//    
        [self _startRefreshing];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        
        if (_alphaChangeWithScroll) {
            super.alpha = 1.f;
        }
        
        [self _setContentOffsetForRefreshing];
        
        [UIView commitAnimations];
    }
}

- (void)endRefreshing
{
    if (_refreshing && _scrollView) {
        
        _refreshing = NO;
        
        _ignoreChange = YES;
        
        [UIView animateWithDuration:0.3f animations:^{
            
//            _activityIndicatorView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            
            _scrollView.contentInset = _originalContentInset;
            
            if (_alphaChangeWithScroll) {
                super.alpha = 0.f;
            }
            
        } completion:^(BOOL finished){
            
            _activityIndicatorView.style = MyActivityIndicatorViewStyleDeterminate;
            _ignoreChange = NO;
            _readyToRefresh = NO;
            _showing = NO;
            
//            if (self.enabled) {
            [self _updateTitleText];
//            }
        
        }];
    }
}




@end
