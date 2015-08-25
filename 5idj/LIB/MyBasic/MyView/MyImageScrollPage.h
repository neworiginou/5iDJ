//
//  MyImageScrollPage.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-12.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyScrollPage.h"

//----------------------------------------------------------

@protocol MyImageScrollPageDelegate,MyImageScrollPageDataSource;

//----------------------------------------------------------

/*
 *MyScrollPage风格
 */
typedef  NS_ENUM(int, MyImageScrollPageStyle)
{
    MyImageScrollPageStyleTop,               //该风格标题在顶端,页面控件在最底端，可以隐藏
    MyImageScrollPageStyleBottom             //该风格标题在顶端，页面控件隐藏
};


/*
 *该类实现了分页显示图片,支持图片名称，图片URL初始化图片，默认支持动作切换
 */
@interface MyImageScrollPage : MyScrollPage

/*
 *代理
 */
@property(nonatomic,weak) id<MyImageScrollPageDelegate> delegate;

/*
 *数据源
 */
@property(nonatomic,weak) id<MyImageScrollPageDataSource> dataSource;


/*
 *图片数目
 */
- (NSUInteger)numberOfImage;

/*
 *默认图片
 */
@property(nonatomic,strong) UIImage *placeholderImage;

//default is UIViewContentModeScaleAspectFit
@property(nonatomic) UIViewContentMode imageViewContentMode;

@end


//----------------------------------------------------------


@protocol MyImageScrollPageDelegate

@optional

/*
 *点击了索引为index的图像
 */
- (void)imageScrollPage:(MyImageScrollPage *)imageScrollPage didTapImageAtIndex:(NSUInteger) index;

/*
 *显示了索引为index的图像
 */
- (void)imageScrollPage:(MyImageScrollPage *)imageScrollPage didShowImageAtIndex:(NSUInteger) index;

@end


@protocol MyImageScrollPageDataSource

/*
 *返回图片大小
 */
- (CGSize)imageSizeForImageScrollPage:(MyImageScrollPage *)imageScrollPage;

/*
 *返回图片数目
 */
- (NSUInteger)numberOfImageInImageScrollPage:(MyImageScrollPage *)imageScrollPage;

@optional


/*
 *以下四个方法为获取图像的方法，如果响应了多个方法，调用优先级是image > imageName > imagePath > imageURL
 */
- (UIImage *)imageScrollPage:(MyImageScrollPage *)imageScrollPage imageForIndex:(NSUInteger)index;
- (NSString *)imageScrollPage:(MyImageScrollPage *)imageScrollPage imageURLForIndex:(NSUInteger)index;
- (NSString *)imageScrollPage:(MyImageScrollPage *)imageScrollPage imagePathForIndex:(NSUInteger)index;
- (NSString *)imageScrollPage:(MyImageScrollPage *)imageScrollPage imageNameForIndex:(NSUInteger)index;

/*
 *返回图片标题
 */
- (NSString *)imageScrollPage:(MyImageScrollPage *)imageScrollPage titleForIndex:(NSUInteger)index;

/*
 *返回图片标题视图
 */
- (UIView *)imageScrollPage:(MyImageScrollPage *)imageScrollPage titleViewForIndex:(NSUInteger)index;

@end




