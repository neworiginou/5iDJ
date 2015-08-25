//
//  MyScrollPage.m
//  shopping
//
//  Created by hldw航 on 13-11-28.
//  Copyright (c) 2013年 Xu zhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyScrollPage.h"
#import "help.h"
#import "MacroDef.h"

//----------------------------------------------------------

@interface MyScrollPage()

/*
 *更新视图，视图从新加载，但不重新从数据源加载视图大小，页面个数等信息
 */
- (void)_updateView;

/*
 *更新页面到索引index的页面
 */
- (void)_updatePageViewToIndex:(NSInteger) index;

/*
 *更新标题视图
 */
- (void)_updateTitleView;

/**
 * 布局标题视图
 */
- (void)_layoutTitleViews;

/*
 *获取显示index所需要的所有页面的索引集合
 */
- (NSIndexSet *)_NeedPageViewIndexSet:(NSInteger)index;

/*
 *标题文本标签
 */
@property(nonatomic,strong,readonly) UILabel * titleLabel;


/*
 *页面指示器视图
 */
@property(nonatomic,strong,readonly) UIView * pageIndicatorView;

/*
 *pageControl改变页面的回调函数
 */
- (void)_pageControlValueChange;

/*
 *自动切换页面的回调函数
 */
- (void)_timeToChangePage;

/*
 *更新计时器
 */
- (void)_updateTimer;


/*
 *轻击手势识别对象的引用
 */
@property(nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;

/*
 *轻击手势响应函数
 */
- (void)_tapGestureRecognizerHandle;


//KVO
- (void)_registerForKVO;
- (void)_unregisterFromKVO;
- (NSArray *)_observableKeypaths;
- (void)_updateUIForKeypath:(NSString *)keyPath;


@end

//----------------------------------------------------------

@implementation MyScrollPage
{
    UIView     *_currentPageView;
    UIView     *_prevPageView;
    UIView     *_nextPageView;
    
    //滚动视图
    UIScrollView    *_scrollView;
    //页面视图
    UIPageControl   *_pageControl;
    
    //标题视图
    UIView          *_titleView;
    
    //页面个数
    NSUInteger  _pageCount;
    
    //页面尺寸
    CGSize      _pageSize;
    
    //复用池
    NSMutableDictionary *_reusePool;
    //复用类注册池
    NSMutableDictionary *_registerPool;
    
    
    //标记
    struct {
        unsigned short isInitPageView:1;                    //是否初始化了页面
        unsigned short isInitNumberOfPageView:1;            //是否初始化了页面个数
        unsigned short isInitPageSize:1;                    //是否初始化了页面大小
        unsigned short needLoadDataWhenMoveToWindow:1;      //需要加载数据当移动到窗口
        unsigned short needUpdateViewWhenMoveToWindow:1;    //需要更新视图当移动到窗口
        unsigned short needIgnoringPageChange:1;            //需要忽略页面改变
        unsigned short needIgnoringContentOffsetChange:1;   //需要忽视ContentOffset的改变
        unsigned short needSendPageChangeWhenAnimateEnd:1;  //是否在动作结束发送页面改变的消息
        unsigned short circleChangePage:1;                  //循环切换页面
        unsigned short animating:1;                         //是否有自动动作切换页面
        unsigned short isUpdatingView:1;                    //是否在更新视图
        
    } _myScrollPageFlags;
    
}

/************************初始化***********************/


- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithStyle:MyScrollPageStyleTop circle:NO];

    if (self) {
        self.frame = frame;
    }
    
    return self;
}

- (id)initWithStyle:(MyScrollPageStyle)style
{
    return [self initWithStyle:style circle:NO];
}


- (id)initWithStyle:(MyScrollPageStyle)style circle:(BOOL)circle
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        
        _style = style;
        
        //标记初始化
        _myScrollPageFlags.circleChangePage = circle;
        _myScrollPageFlags.animating = 0;
        _myScrollPageFlags.isInitPageView = 1;
        _myScrollPageFlags.isInitNumberOfPageView = 1;
        _myScrollPageFlags.isInitPageSize = 1;
        _myScrollPageFlags.needLoadDataWhenMoveToWindow = 1;
        _myScrollPageFlags.needUpdateViewWhenMoveToWindow = 0;
        _myScrollPageFlags.needIgnoringPageChange = 0;
        _myScrollPageFlags.needIgnoringContentOffsetChange = 0;
        _myScrollPageFlags.needSendPageChangeWhenAnimateEnd = 0;
        _myScrollPageFlags.isUpdatingView = 0;
        
        
        _pageSize           = CGSizeZero;
        _currentPageIndex   = -1;
        _animationTime      = 3.f;
        _animationDirection = PageChangeAnimationDirectionLeft;
        
        
        _scrollEnable               = YES;
        _pageControlBackgrounpColor = BlackColorWithAlpha(0.4f);
        _titleTextColor             = [UIColor whiteColor];
        _titleTextFont              = [UIFont systemFontOfSize:13.f];
        _titleBackgrounpColor       = self.pageControlBackgrounpColor;
        _pageIndicatorColor         = self.tintColor;
        _hiddenPageControl          = _style == MyScrollPageStyleBottom;
        _hiddenPageIndicator        = _style == MyScrollPageStyleTop;
        
        
        //初始化滑动界面
        _scrollView=[[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.bouncesZoom = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        [self addSubview:_scrollView];
        
        
        //初始化页面控件
        _pageControl=[[UIPageControl alloc] init];
        _pageControl.hidden = _hiddenPageControl;
        [self setPageControlBackgrounpColor:self.pageControlBackgrounpColor];
        [_pageControl addTarget:self action:@selector(_pageControlValueChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
        
        //复用池初始化
        _reusePool = [NSMutableDictionary dictionary];
        _registerPool = [NSMutableDictionary dictionary];
        
        //注册
        [self _registerForKVO];
        
    }
    
    return self;
}

- (void)dealloc
{
    [self _unregisterFromKVO];
}


/********************KVO****************************/

- (void)_registerForKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)_unregisterFromKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)_observableKeypaths
{
    return @[
              @"scrollEnable",
              @"pageControlBackgrounpColor",
              @"titleTextColor",
              @"titleTextFont",
              @"titleBackgrounpColor",
              @"pageIndicatorColor",
              @"hiddenPageIndicator",
              @"hiddenPageControl",
            ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([NSThread isMainThread]) {
        [self _updateUIForKeypath:keyPath];
    } else {
        [self performSelector:@selector(_updateUIForKeypath:) onThread:[NSThread mainThread] withObject:keyPath waitUntilDone:NO];
    }
}

- (void)_updateUIForKeypath:(NSString *)keyPath
{
    if ([keyPath isEqual:@"scrollEnable"]) {
        _scrollView.scrollEnabled = _scrollEnable;
    } else if([keyPath isEqualToString:@"pageControlBackgrounpColor"]){
        _pageControl.backgroundColor = _pageControlBackgrounpColor;
    } else if([keyPath isEqualToString:@"titleTextColor"]){
        _titleLabel.textColor = _titleTextColor;
    } else if ([keyPath isEqualToString:@"titleTextFont"]){
        _titleLabel.font = _titleTextFont;
    } else if ([keyPath isEqualToString:@"titleBackgrounpColor"]){
        _titleLabel.backgroundColor = _titleBackgrounpColor;
    } else if ([keyPath isEqualToString:@"pageIndicatorColor"]){
        _pageIndicatorView.backgroundColor = _pageIndicatorColor;
    }else if ([keyPath isEqualToString:@"hiddenPageIndicator"]){
        _pageIndicatorView.hidden = _hiddenPageIndicator;
    } else if ([keyPath isEqualToString:@"hiddenPageControl"]){
        if (_style == MyScrollPageStyleBottom) {
            _hiddenPageControl = YES;
        }
        _pageControl.hidden = _hiddenPageControl;
    }
}

/********************页面控件布局相关****************************/
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _layoutTitleViews];
    
    CGRect bounds = self.bounds;
    
    _scrollView.frame = bounds;
    
    _pageControl.frame = CGRectMake(0.f, CGRectGetHeight(bounds) - CGRectGetHeight(_pageControl.bounds), CGRectGetWidth(bounds), CGRectGetHeight(_pageControl.bounds));
    
    
    if (_titleLabel) {
        
        _titleLabel.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(bounds),35.f);
        
        if (_style == MyScrollPageStyleBottom) {
            _titleLabel.frame = CGRectOffset(_titleLabel.frame, 0.f, CGRectGetHeight(bounds) - 35.f);
        }
    }

}

- (void)_layoutTitleViews
{
    if (_titleView) {
        
        CGRect tmpFrame = _titleView.frame;
        
        if (_style == MyScrollPageStyleBottom){
            tmpFrame.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(tmpFrame);
        }else{
            tmpFrame.origin = CGPointZero;
        }
        
        _titleView.frame = tmpFrame;
    }
    
    if (!_hiddenPageIndicator) {
        
        self.pageIndicatorView.frame = (_pageCount == 0) ? CGRectZero : CGRectMake((_pageSize.width/_pageCount) * _currentPageIndex, _pageSize.height - 2, (_pageSize.width/_pageCount), 2.f);
        
        if (_pageIndicatorView.superview != self) {
            [self addSubview:_pageIndicatorView];
        }else{
            [self bringSubviewToFront:_pageIndicatorView];
        }
    }    
}


/********************页面大小相关****************************/

#define IfHaveDataSourceSel(_sel)                           \
    id<MyScrollPageDataSource> __dataSource = _dataSource;  \
    ifRespondsSelector(__dataSource, _sel)

- (void)setFrame:(CGRect)frame
{
    IfHaveDataSourceSel(@selector(pageSizeForScrollPage:)){
        frame.size = [self pageSize];
    }
    
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    IfHaveDataSourceSel(@selector(pageSizeForScrollPage:)){
        bounds.size = [self pageSize];
    }
    
    [super setBounds:bounds];
}

- (CGSize)pageSize
{
    if (_myScrollPageFlags.isInitPageSize) {
        
        IfHaveDataSourceSel(@selector(pageSizeForScrollPage:)){
            _myScrollPageFlags.isInitPageSize = 0;
            _pageSize = [__dataSource pageSizeForScrollPage:self];
            
            //设置大小
            CGRect tmpFrame = self.frame;
            tmpFrame.size = _pageSize;
            [super setFrame:tmpFrame];
            
        }else{
            _pageSize = self.frame.size;
        }
    }
    
    return _pageSize;
}

/********************复用相关****************************/

//加入复用池
#define AddViewToReusePool(_view)                                               \
do{                                                                             \
    if(_view){                                                                  \
        NSString * reuseIdentifier = [_view reuseIdentifier];                   \
        if (reuseIdentifier) {                                                  \
            NSMutableSet* viewSet = [_reusePool objectForKey:reuseIdentifier];  \
            if (!viewSet) {                                                     \
                viewSet = [NSMutableSet set];                                   \
                [_reusePool setObject:viewSet forKey:reuseIdentifier];          \
            }                                                                   \
            [viewSet addObject:_view];                                          \
        }                                                                       \
    }                                                                           \
}while(0)

#define removeViewFromReusePool(_view)                                          \
do{                                                                             \
    if(_view){                                                                  \
        NSString * reuseIdentifier = [_view reuseIdentifier];                   \
        if (reuseIdentifier) {                                                  \
            NSMutableSet* viewSet = [_reusePool objectForKey:reuseIdentifier];  \
            if (viewSet) {                                                      \
                [viewSet removeObject:_view];                                   \
                if (viewSet.count == 0) {                                       \
                    [_reusePool removeObjectForKey:reuseIdentifier];            \
                }                                                               \
            }                                                                   \
        }                                                                       \
    }                                                                           \
}while(0)

- (id)reusePageView:(NSString *)reuseIdentifier
{
    UIView * pageView = nil;
    
    if (reuseIdentifier) {
        
        NSMutableSet* viewSet =  [_reusePool objectForKey:reuseIdentifier];
        
        if (viewSet) {
            pageView = [viewSet anyObject];
        }
        
        if (!pageView) {
            //通过注册信息生成一个
            Class pageView_Class = [_registerPool objectForKey:reuseIdentifier];
            
            if (pageView_Class) {
                pageView = [[pageView_Class alloc] initWithReuseIdentifier:reuseIdentifier];
            }
        }
    }
    
    return pageView;
}

- (void)registerPageViewClass:(Class)pageView_Class reuseIdentifier:(NSString *)reuseIdentifier
{
    //加入注册池
    if (pageView_Class && reuseIdentifier) {
        [_registerPool setObject:pageView_Class forKey:reuseIdentifier];
    }
}


/********************页面视图相关****************************/

#define NextPageIndex(_index,pageCount)  ((_index + 1 ) % pageCount)
#define PrevPageIndex(_index,pageCount)  ((_index - 1 + pageCount ) % pageCount )

- (NSUInteger)numberOfPageViews
{
    if (_myScrollPageFlags.isInitNumberOfPageView ) {
        IfHaveDataSourceSel(@selector(numberOfPageInScrollPage:)){
            _myScrollPageFlags.isInitNumberOfPageView = 0;
            _pageCount = [__dataSource numberOfPageInScrollPage:self];
        }else{
            _pageCount = 0;
        }
    }
    
    return _pageCount;
}

- (UIView *)pageViewForIndex:(NSUInteger)index
{
    NSUInteger pageCount = [self numberOfPageViews];
    
    assert(0 <= index && index < pageCount);
    
    //从已有界面获取
    if (_currentPageIndex != -1) {
        
        //直接返回当前页面
        if (index == _currentPageIndex && _currentPageView) {
            return _currentPageView;
        }
        
        //下一个界面
        if (index == NextPageIndex(_currentPageIndex,pageCount) && _nextPageView) {
            return _nextPageView;
        }
        
        //上一个界面
        if (index == PrevPageIndex(_currentPageIndex,pageCount) && _prevPageView) {
            return _prevPageView;
        }
    }
    
    //从数据源获得
    IfHaveDataSourceSel(@selector(scorllPage:pageViewForIndex:)){
        UIView * pageView = [__dataSource scorllPage:self pageViewForIndex:index];
        return pageView;
    }
    
    return nil;
}


/********************页面更新相关****************************/

#define NeedCircle (_myScrollPageFlags.circleChangePage && [self numberOfPageViews] > 2)

#define SendChangeToPageMsg()                                                               \
do{                                                                                         \
    if (_currentPageIndex != -1) {                                                          \
        id<MyScrollPageDelegate> delegate = _delegate;                                      \
        ifRespondsSelector(delegate, @selector(scorllPage:didChangeToPageAtIndex:)){        \
            [delegate scorllPage:self didChangeToPageAtIndex:_currentPageIndex];            \
        }                                                                                   \
        [self didChangeToPageIndex:_currentPageIndex];                                      \
    }                                                                                       \
}while(0)

- (void)didMoveToWindow
{
    if (_myScrollPageFlags.needLoadDataWhenMoveToWindow ) {
        
        _myScrollPageFlags.needLoadDataWhenMoveToWindow = 0;
        _myScrollPageFlags.needUpdateViewWhenMoveToWindow = 0;
        
        [self reloadData];
        
    }else{
        
        if (_myScrollPageFlags.needUpdateViewWhenMoveToWindow){
    
            _myScrollPageFlags.needUpdateViewWhenMoveToWindow = 0;
            [self _updateView];
        }
        
        //更新时间计数器
        [self _updateTimer];
    }
}

- (void)reloadData
{
    if (self.window) {
       
        _myScrollPageFlags.isInitNumberOfPageView = 1;
        _myScrollPageFlags.isInitPageSize = 1;
        _myScrollPageFlags.isInitPageView = 1;
        
        //更新视图
        [self _updateView];
        
        //发送页面改变消息
        SendChangeToPageMsg();
        
        //更新时间计数器
        [self _updateTimer];
        
    } else {
        _myScrollPageFlags.needLoadDataWhenMoveToWindow = 1;
    }
}

- (void)setCircleChangePage:(BOOL)circleChangePage
{
    if (_myScrollPageFlags.circleChangePage != circleChangePage) {
        
        _myScrollPageFlags.circleChangePage = circleChangePage;
        
        if (self.window) {
            [self _updateView];
        }else{
            _myScrollPageFlags.needUpdateViewWhenMoveToWindow = 1;
        }
    }
}

- (BOOL)isCircleChangePage
{
    return _myScrollPageFlags.circleChangePage;
}

- (void)_updateView
{
    _myScrollPageFlags.isUpdatingView = YES;
    
    //设置当前页面索引
    NSUInteger pageCount = [self numberOfPageViews];
    _pageControl.numberOfPages = pageCount;
    
    //设置_scrollView相关属性
    CGSize pageSize = [self pageSize];
    _scrollView.contentSize = CGSizeMake(pageSize.width * pageCount, pageSize.height);
    
    //设置内容大小
    _scrollView.contentInset = NeedCircle ? UIEdgeInsetsMake(0, pageSize.width, 0, pageSize.width) : UIEdgeInsetsZero;
    
    _currentPageIndex = -1;
    
    //更新页面视图
    NSInteger __currentPageIndex = (pageCount == 0)? -1 :(( _currentPageIndex == -1) ? 0 : MIN(_currentPageIndex, pageCount - 1));
    [self _updatePageViewToIndex:__currentPageIndex];
    
    _myScrollPageFlags.isUpdatingView = NO;
    
}

- (void)_updatePageViewToIndex:(NSInteger) index
{
    NSUInteger pageCount = [self numberOfPageViews];
    CGSize pageSize = [self pageSize];
    
    assert(index < (NSInteger)pageCount);
    
    //移除所有页面
    [_currentPageView removeFromSuperview];
    [_prevPageView removeFromSuperview];
    [_nextPageView removeFromSuperview];
    
    //无页面，所有界面置nil
    if (index < 0 || _myScrollPageFlags.isInitPageView) {
        
        _myScrollPageFlags.isInitPageView = 0;
        _currentPageIndex = -1;
        _currentPageView = nil;
        _prevPageView = nil;
        _nextPageView = nil;
        
        //加入复用池
        AddViewToReusePool(_currentPageView);
        AddViewToReusePool(_prevPageView);
        AddViewToReusePool(_nextPageView);
    }
    
    if(index >= 0) {
        
        
        NSIndexSet * nextIndexSet = [self _NeedPageViewIndexSet:index];
        
        //当页面数大于2的时候才有页面可以复用
        if (pageCount > 2) {
            
            NSIndexSet * currentIndexSet = [self _NeedPageViewIndexSet:_currentPageIndex];
            
            //加入复用池
            [currentIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
                
                //不需要用的加入复用池
                if (![nextIndexSet containsIndex:idx]) {
                    
                    UIView * _reuseView = nil;
                    
                    //由于页面数大于2，无论什么情况，三个页面索引不可能重合，直接获取
                    if (idx == _currentPageIndex) {
                        _reuseView = _currentPageView;
                    }else if (idx == PrevPageIndex(_currentPageIndex, pageCount)){
                        _reuseView = _prevPageView;
                    }else{
                        _reuseView = _nextPageView;
                    }
                    
                    AddViewToReusePool(_reuseView);
                }
            }];
        }
        
        
        
        //获取所需要的三个界面
        __block UIView * __currentPageView = nil;
        __block UIView * __prevPageView = nil;
        __block UIView * __nextPageView = nil;
        
        [nextIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
            
            if (idx == index) {
                __currentPageView = [self pageViewForIndex:idx];
            }else{
                
                //请页面小于3时，索引可能重合，直接判断定位
                if (_pageCount < 3) {
                    
                    (idx > index)?
                    (__nextPageView = [self pageViewForIndex:idx]):
                    (__prevPageView = [self pageViewForIndex:idx]);
                    
                }else if(idx == PrevPageIndex(index, pageCount)){
                    __prevPageView = [self pageViewForIndex:idx];
                }else{
                    __nextPageView = [self pageViewForIndex:idx];
                }
            }
        }];
        
        _currentPageView = __currentPageView;
        _prevPageView = __prevPageView;
        _nextPageView = __nextPageView;
        
        //从复用池中移除
        removeViewFromReusePool(_currentPageView);
        removeViewFromReusePool(_prevPageView);
        removeViewFromReusePool(_nextPageView);
        
        
        _currentPageIndex = index;
        
        //设置各界面位置
        CGRect currentPageFrame = CGRectMake(pageSize.width * (_currentPageIndex - 1), 0.f, pageSize.width, pageSize.height);
        
        NSArray * _pageViews = @[_prevPageView ? :[NSNull null],_currentPageView ? :[NSNull null],_nextPageView ? :[NSNull null]];
        
        for (UIView * _pageView in _pageViews) {
            
            if ((NSNull *)_pageView != [NSNull null]) {
                _pageView.frame = currentPageFrame;
                
                //不能是同一个页面
                assert(_pageView.superview != _scrollView);
                [_pageView removeFromSuperview];
                
                [_scrollView addSubview:_pageView];
            }
            
            currentPageFrame = CGRectOffset(currentPageFrame, pageSize.width , 0);
        }
    }
    
    //忽略改变
    _myScrollPageFlags.needIgnoringContentOffsetChange = 1;
    
    //更新当前显示的位置
    _scrollView.contentOffset = CGPointMake(_currentPageIndex < 1 ? 0 :_currentPageIndex * pageSize.width, 0);
    
    _myScrollPageFlags.needIgnoringContentOffsetChange = 0;
    
    
    if (!_myScrollPageFlags.needIgnoringPageChange) {
        
        _pageControl.currentPage = _currentPageIndex;
        
        //更新标题视图
        [self _updateTitleView];
        
    }
}

- (NSIndexSet *)_NeedPageViewIndexSet:(NSInteger)index
{
    NSMutableIndexSet * indexSet = [[NSMutableIndexSet alloc] init];
    
    NSUInteger pageCount = [self numberOfPageViews];
    
    if(0 <= index && index < pageCount ){
        
        BOOL needCircle = NeedCircle;
        
        [indexSet addIndex:index];
        
        if(needCircle || index != 0){
            [indexSet addIndex:PrevPageIndex(index,pageCount)];
        }
        
        if (needCircle || index != (pageCount - 1)) {
            [indexSet addIndex:NextPageIndex(index,pageCount)];
        }
    }
    
    return indexSet;
}

/********************标题视图相关****************************/

@synthesize titleLabel=_titleLabel;

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        
        //初始化标题标签视图
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), 35.f)];
        _titleLabel.backgroundColor = self.titleBackgrounpColor;
        _titleLabel.textColor = self.titleTextColor;
        _titleLabel.font = self.titleTextFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.numberOfLines = 2;
        _titleLabel.minimumScaleFactor = 0.5f;
        _titleLabel.hidden = YES;
        [self addSubview:_titleLabel];
        
        if (_style == MyScrollPageStyleBottom) {
            _titleLabel.frame = CGRectOffset(_titleLabel.frame, 0.f, CGRectGetHeight(self.bounds) - 35.f);
        }
    }
    
    return _titleLabel;
}

- (void)_updateTitleView
{

    _titleLabel.hidden = YES;
    
    if (_titleView) {
        [_titleView removeFromSuperview];
        _titleView = nil;
    }
    
    IfHaveDataSourceSel(@selector(scorllPage:titleViewForIndex:)){
        
        if (_currentPageIndex != -1) {
            _titleView = [__dataSource scorllPage:self titleViewForIndex:_currentPageIndex];
            
            if (_titleView) {
                [self addSubview:_titleView];
            }
        }
        
    }
    
    if(!_titleView){
        
        IfHaveDataSourceSel(@selector(scorllPage:titleForIndex:)){
            
            if (_currentPageIndex != -1) {
                
                NSString * titleText = [__dataSource scorllPage:self titleForIndex:_currentPageIndex];
                
                if (titleText) {
                    self.titleLabel.hidden = NO;
                    self.titleLabel.text = titleText;
                    
                }
            }
        }
    }
    
    [self _layoutTitleViews];
}

/********************页面指示器相关****************************/

@synthesize pageIndicatorView = _pageIndicatorView;

- (UIView *)pageIndicatorView
{
    if (!_pageIndicatorView) {
        
        _pageIndicatorView = [[UIView alloc] init];
        _pageIndicatorView.userInteractionEnabled = NO;
        _pageIndicatorView.backgroundColor = _pageIndicatorColor;
        _pageIndicatorView.hidden = _hiddenPageIndicator;
        
//        [self addSubview:_pageIndicatorView];
    }
    
    return _pageIndicatorView;
}

//
//- (void)tintColorDidChange
//{
//    [super tintColorDidChange];
//    
//    _pageIndicatorView.backgroundColor = self.tintColor;
//}

/********************当前页面视图相关****************************/

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    [self setCurrentPageIndex:currentPageIndex animated:NO];
}

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated
{
    assert(currentPageIndex < [self numberOfPageViews]);
    
    if (_currentPageIndex != currentPageIndex) {
        
        if (animated) {
            
            _myScrollPageFlags.needIgnoringPageChange = 1;
            
            [_scrollView setContentOffset:CGPointMake(currentPageIndex < 1 ? 0 :currentPageIndex * [self pageSize].width , 0.f) animated:YES];
            
        }else{
            [self _updatePageViewToIndex:currentPageIndex];
        }
    }
}

/********************按时间动作相关****************************/

- (void)setAnimating:(BOOL)animating
{
    if (_myScrollPageFlags.animating != animating) {
        
        _myScrollPageFlags.animating = animating;
        
        [self _updateTimer];
    }
}

- (BOOL)isAnimating
{
    return _myScrollPageFlags.animating;
}


- (void)_updateTimer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeToChangePage) object:nil];
    
    //当前显示才更新
    if (self.isAnimating && self.window && [self numberOfPageViews] > 1) {
        [self performSelector:@selector(_timeToChangePage) withObject:nil afterDelay:self.animationTime];
    }
}

- (void)setAnimationTime:(NSTimeInterval)animationTime
{
    if (_animationTime != animationTime) {
        _animationTime = animationTime;
        
        [self _updateTimer];
    }
}

- (void)_timeToChangePage
{
    if (!_scrollView.isTracking&&!_scrollView.isDecelerating) {
        
        
        NSUInteger pageCount = [self numberOfPageViews];
        
        //目标页面索引
        NSInteger desPageIndex = (_animationDirection == PageChangeAnimationDirectionLeft) ? _currentPageIndex + 1 : _currentPageIndex - 1;
        
        if (!NeedCircle) {
            
            desPageIndex = desPageIndex < 0 ?  pageCount - 1 : ((desPageIndex > pageCount - 1) ? 0 : desPageIndex );
            
            _myScrollPageFlags.needSendPageChangeWhenAnimateEnd = 1;
            
            [self setCurrentPageIndex:desPageIndex animated:YES];
            
        }else{
            
            [_scrollView setContentOffset:CGPointMake(desPageIndex * [self pageSize].width, 0.f) animated:YES];
        }
    }
}

///********************页面切换相关****************************/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //是否忽略改变
    if (!_myScrollPageFlags.needIgnoringContentOffsetChange && !_myScrollPageFlags.isUpdatingView) {
        
        float pageWidth = [self pageSize].width;
        float contentOffsetX = scrollView.contentOffset.x;
        
        //目的索引
        NSInteger desPageIndex = pageWidth * _currentPageIndex < contentOffsetX ? floorf(contentOffsetX / pageWidth) : ceilf(contentOffsetX / pageWidth);
        
        if (desPageIndex != _currentPageIndex) {
            
            //将目的索引装换到合适值
            desPageIndex = (desPageIndex == -1) ? ([self numberOfPageViews] - 1) : ((desPageIndex == [self numberOfPageViews]) ? 0 : desPageIndex);
            
            //更新页面
            [self _updatePageViewToIndex:desPageIndex];
            
            if (!_myScrollPageFlags.needIgnoringPageChange) {
                SendChangeToPageMsg();
            }
            
        }

    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self _updateTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _updateTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_myScrollPageFlags.needIgnoringPageChange) {
        
        _myScrollPageFlags.needIgnoringPageChange = 0;
        
        //更新标题
        [self _updateTitleView];
        //更新页面
        _pageControl.currentPage = _currentPageIndex;
        
        if (_myScrollPageFlags.needSendPageChangeWhenAnimateEnd) {
            
            _myScrollPageFlags.needSendPageChangeWhenAnimateEnd = 0;
            
            //发送消息
            SendChangeToPageMsg();
        }
    }
    
    [self _updateTimer];
}

- (void)_pageControlValueChange
{
    _myScrollPageFlags.needSendPageChangeWhenAnimateEnd = 1;
    
    NSUInteger __currentPageIndex = _currentPageIndex;
    
    [self setCurrentPageIndex:_pageControl.currentPage animated:YES];
    
    _pageControl.currentPage = __currentPageIndex;
}


- (void)didChangeToPageIndex:(NSUInteger)pageIndex
{
    //do nothing
}


/********************轻击相关****************************/

- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizerHandle)];
    }
    
    return _tapGestureRecognizer;
}

- (void)setDelegate:(id<MyScrollPageDelegate>)delegate
{
    ifRespondsSelector(_delegate, @selector(scorllPage:didTapPageAtIndex:)){
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
    
    _delegate = delegate;
    
    ifRespondsSelector(delegate, @selector(scorllPage:didTapPageAtIndex:)){
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }
}

- (void)_tapGestureRecognizerHandle
{
    //没有正在拖拽或运动响应点击
    if (!_scrollView.isDragging && !_scrollView.isDecelerating) {
        
        if(_currentPageIndex != -1)
        {
            id<MyScrollPageDelegate> delegate = _delegate;
            ifRespondsSelector(delegate, @selector(scorllPage:didTapPageAtIndex:)){
                [delegate scorllPage:self didTapPageAtIndex:_currentPageIndex];
            }
            
            [self didTapPageIndex:_currentPageIndex];
        }
    }
    
}

- (void)didTapPageIndex:(NSUInteger)pageIndex
{
    //do nothing
}

@end
