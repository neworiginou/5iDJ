//
//  MyScrollPage.h
//  
//
//  Created by hldw航 on 13-11-28.
//  Copyright (c) 2013年 Xu zhanya. All rights reserved.
//

//----------------------------------------------------------

#import "UIView+ReuseDef.h"

//----------------------------------------------------------

/*
 *页面切换动作的方向
 */
typedef  NS_ENUM(int, PageChangeAnimationDirection)
{
    PageChangeAnimationDirectionLeft,   //左
    PageChangeAnimationDirectionRight   //右
};

/*
 *MyScrollPage风格
 */
typedef  NS_ENUM(int, MyScrollPageStyle)
{
    MyScrollPageStyleTop,               //该风格标题在顶端,页面控件在最底端，可以隐藏
    MyScrollPageStyleBottom             //该风格标题在底端，页面控件隐藏,标题下面有提示当前的标签
};


//----------------------------------------------------------

@protocol MyScrollPageDelegate,MyScrollPageDataSource;

//----------------------------------------------------------

/*
 *
 *该类实现了分页显示内容，通过滑动改变显示的页面
 *
 */
@interface MyScrollPage : UIView<UIScrollViewDelegate>

/*
 *通过风格初始化，默认为MyScrollPageStyleTop，即init和initWithFrame: 是此风格，等同于下面方法，circlr = false
 */
- (id)initWithStyle:(MyScrollPageStyle)style;

/*
 *style同上, circle决定是否循环切换界面
 */
- (id)initWithStyle:(MyScrollPageStyle)style circle:(BOOL)circle;

/*
 *控件风格
 */
@property(nonatomic,readonly) MyScrollPageStyle style;

/*
 *是否接收触摸消息，默认为yes
 */
@property(nonatomic) BOOL scrollEnable;

/*
 *页面控件的背景颜色，默认为50%透明度的黑色
 */
@property(nonatomic,strong) UIColor *pageControlBackgrounpColor UI_APPEARANCE_SELECTOR;

/*
 *标题文字的颜色,默认为白色
 */
@property(nonatomic,strong) UIColor *titleTextColor UI_APPEARANCE_SELECTOR;

/*
 *标题文字的字体，默认为13号系统字体
 */
@property(nonatomic,strong) UIFont  *titleTextFont UI_APPEARANCE_SELECTOR;

/*
 *标题文字的背景颜色，默认为50%透明度的黑色
 */
@property(nonatomic,strong) UIColor *titleBackgrounpColor UI_APPEARANCE_SELECTOR;

/*
 *当风格为MyScrollPageStyleBottom时最下面的页面标记的颜色，默认为tintcolor
 */
@property(nonatomic,strong) UIColor *pageIndicatorColor UI_APPEARANCE_SELECTOR;

/*
 *是否隐藏页面指示器，对于MyScrollPageStyleBottom默认为NO，对于MyScrollPageStyleTop默认为YES
 */
@property(nonatomic) BOOL hiddenPageIndicator;

/*
 *是否隐藏页面控件，对于MyScrollPageStyleBottom始终为YES ，对于MyScrollPageStyleTop默认为NO
 */
@property(nonatomic) BOOL hiddenPageControl;


/*
 *页面大小，会向数据源获取数据，如果无数据源则为frame的size
 */
- (CGSize)pageSize;

/*
 *获取总页面数目
 */
- (NSUInteger)numberOfPageViews;

/*
 *获取指定索引上的页面视图
 */
- (UIView *)pageViewForIndex:(NSUInteger) index;

/*
 *当前显示页面的的索引,有页面时默认为0，无页面时为-1，设置不会调用代理方法和KVO通知
 */
@property(nonatomic) NSInteger currentPageIndex;

/*
 *设置当前显示的页面索引，不会调用代理的方法和KVO通知
 */
- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL) animated;

/*
 *当页面数大于2，且该属性为YES时可以循环切换界面，默认为NO
 */
@property(nonatomic,getter = isCircleChangePage) BOOL circleChangePage;

/*
 *当页面数大于1，且该属性为YES时，按一定时间间隔自动切换页面,默认为NO
 */
@property(nonatomic,getter = isAnimating) BOOL  animating;

/*
 *自动切换页面时间间隔，默认为3秒
 */
@property(nonatomic) NSTimeInterval animationTime;

/*
 *自动切换页面运动的方向，默认为从右到左
 */
@property(nonatomic) PageChangeAnimationDirection animationDirection;

/*
 *代理
 */
@property(nonatomic,weak)   id<MyScrollPageDelegate>  delegate;

/*
 *数据源
 */
@property(nonatomic,weak)   id<MyScrollPageDataSource> dataSource;

/*
 *当轻击了某一页面会调用改方法，默认不做任何事
 *如果需要定制该操作，请在子类覆盖该操作
 */
- (void)didTapPageIndex:(NSUInteger)pageIndex;

/*
 *当切换到某一页时调用改方法默认不做任何事
 *如果需要定制该操作，请在子类覆盖该操作
 */
- (void)didChangeToPageIndex:(NSUInteger)pageIndex;

/*
 *重新加载数据
 */
- (void)reloadData;

/*
 *获取可复用的页面视图,如果没有可复用的，但注册了相关类，则会根据其初始化一个实例并返回
 */
- (id)reusePageView:(NSString *)reuseIdentifier;

/*
 *注册可复用页面视图的类
 */
- (void)registerPageViewClass:(Class) pageView_Class reuseIdentifier:(NSString *)reuseIdentifier;

@end


//----------------------------------------------------------

/*
 *数据源协议定义
 */
@protocol MyScrollPageDataSource

/*
 *返回页面大小
 */
- (CGSize)pageSizeForScrollPage:(MyScrollPage *)scorllPage;

/*
 *返回页面数目
 */
- (NSUInteger)numberOfPageInScrollPage:(MyScrollPage *)scorllPage;

/*
 *返回index索引上的页面视图
 */
- (UIView *)scorllPage:(MyScrollPage *)scorllPage pageViewForIndex:(NSUInteger)index;

@optional
/*
 *返回index索引上的标签文本
 */
- (NSString *)scorllPage:(MyScrollPage *)scorllPage titleForIndex:(NSUInteger)index;

/*
 *返回index索引上的标签视图，如果即返回了标签文本又返回了标签标签视图，优先显示视图
 */
- (UIView *)scorllPage:(MyScrollPage *)scorllPage titleViewForIndex:(NSUInteger)index;

@end


//----------------------------------------------------------

/*
 *协议定义
 */
@protocol MyScrollPageDelegate

@optional

/*
 *已改变到某一界面,index为界面索引
 */
- (void)scorllPage:(MyScrollPage *)scorllPage didChangeToPageAtIndex:(NSUInteger) index;

/*
 *已经轻击了某一页面,index为界面索引
 */
- (void)scorllPage:(MyScrollPage *)scorllPage didTapPageAtIndex:(NSUInteger) index;

@end





