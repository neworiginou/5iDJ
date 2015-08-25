//
//  MyImageScrollPage.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-12.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyImageScrollPage.h"
#import "UIImageView+URL.h"
#import "MacroDef.h"

//----------------------------------------------------------

@interface MyImageScrollPage() <MyScrollPageDataSource,MyScrollPageDelegate>

/*
 *页面指示器视图
 */
@property(nonatomic,strong,readonly) UIView *pageIndicatorView;

/*
 *图像下载管理器
 */
@property(nonatomic,strong,readonly) MyImageDownLoadManager * imageDownLoadManager;

/*
 *布局页面指示器视图
 */
- (void)_layoutPageIndicatorView;

@end

//----------------------------------------------------------


@implementation MyImageScrollPage
{
    BOOL _isInitImageCount;
    
    NSUInteger _imageCount;
    NSInteger  _currentImageIndex;
   
    BOOL _hiddenPageIndicator;
 }

@synthesize delegate = __delegate;
@synthesize dataSource = __dataSource;
@synthesize imageDownLoadManager = _imageDownLoadManager;


- (id)initWithStyle:(MyScrollPageStyle)style circle:(BOOL)circle
{
    self = [super initWithStyle:style circle:circle];
    
    if (self) {
        
        self.animating = YES;
        super.dataSource = self;
        super.delegate = self;
        
        _isInitImageCount = YES;
        _imageCount = 0;
        _currentImageIndex = -1;
        
        super.hiddenPageIndicator = YES;
        
        _imageViewContentMode = UIViewContentModeScaleAspectFit;
    }
    
    return self;
}

- (void)dealloc
{
    [_imageDownLoadManager cancleAllDownLoadImage];
}

//-----------------------------------------------------

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _layoutPageIndicatorView];
    
}

- (void)_layoutPageIndicatorView
{
    NSUInteger imageCount = [self numberOfImage];
    
    if (!self.isHiddenPageIndicator ) {
        
        if (imageCount > 0) {
            
            self.pageIndicatorView.frame = CGRectMake((self.pageSize.width/imageCount) * _currentImageIndex, self.pageSize.height - 2.f, (self.pageSize.width/imageCount), 2.f);
            
            if (_pageIndicatorView.superview != self) {
                [self addSubview:_pageIndicatorView];
            }else{
                [self bringSubviewToFront:_pageIndicatorView];
            }
            
        }else{
            _pageIndicatorView.frame = CGRectZero;
        }
    }
}


//-----------------------------------------------------

@synthesize pageIndicatorView = _pageIndicatorView;

- (BOOL)isHiddenPageIndicator
{
    return _hiddenPageIndicator;
}

- (void)setHiddenPageIndicator:(BOOL)hiddenPageIndicator
{
    _hiddenPageIndicator = hiddenPageIndicator;
    
    _pageIndicatorView.hidden = _hiddenPageIndicator;
}

- (void)setPageIndicatorColor:(UIColor *)pageIndicatorColor
{
    super.pageIndicatorColor = pageIndicatorColor;
    _pageIndicatorView.backgroundColor = pageIndicatorColor;
}


- (UIView *)pageIndicatorView
{
    if (!_pageIndicatorView) {
        _pageIndicatorView = [[UIView alloc] init];
        _pageIndicatorView.hidden = self.isHiddenPageIndicator;
        _pageIndicatorView.userInteractionEnabled = NO;
        _pageIndicatorView.backgroundColor = self.pageIndicatorColor;
        
//        [self addSubview:_pageIndicatorView];
    }
    
    return _pageIndicatorView;
}


- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated
{
    [super setCurrentPageIndex:currentPageIndex animated:animated];
    
    _currentImageIndex = [self currentPageIndex] % [self numberOfImage];
}


//-----------------------------------------------------

- (MyImageDownLoadManager *)imageDownLoadManager
{
    //lazy init
    if (!_imageDownLoadManager) {
        
        //于UIImageView默认的图片下载共享同一图片缓存池
        _imageDownLoadManager = [[MyImageDownLoadManager alloc] initWithImageCachePool:[UIImageView shareImageDownLoadManager].imageCachePool concurrentCount:5 waitingCount:10];
    }
    
    return _imageDownLoadManager;
}

- (void)reloadData
{
    if (self.window) {
        _isInitImageCount = YES;
        _currentImageIndex = -1;
    }
    
    [super reloadData];
    
    //取消所有图片下载
    [_imageDownLoadManager cancleAllDownLoadImage];
}


#define ifHaveDataSel(_sel)                                     \
    id<MyImageScrollPageDataSource> dataSource = __dataSource;  \
    ifRespondsSelector(dataSource, _sel)

- (NSUInteger)numberOfImage
{
    if(_isInitImageCount){
        ifHaveDataSel(@selector(numberOfImageInImageScrollPage:)){
            _isInitImageCount = NO;
            _imageCount = [dataSource numberOfImageInImageScrollPage:self];
        }else{
            _imageCount = 0;
        }
    }
    
    return _imageCount;
}

#pragma mark - super delegate
- (CGSize)pageSizeForScrollPage:(MyScrollPage *)scorllPage
{
    ifHaveDataSel(@selector(imageSizeForImageScrollPage:)){
        return [dataSource  imageSizeForImageScrollPage:self];
    }
    
    return CGSizeZero;
}

- (NSUInteger)numberOfPageInScrollPage:(MyScrollPage *)scorllPage
{
    NSUInteger imageCount = [self numberOfImage];
    
    if(!self.isCircleChangePage){
        return imageCount;
    }else{
        return (imageCount == 0)? 0 :((imageCount == 1) ? 3 :((imageCount == 2) ? 4 : imageCount));
    }
}


- (UIView *)scorllPage:(MyScrollPage *)scorllPage pageViewForIndex:(NSUInteger)index
{
    static NSString *imageViewDef = @"imageViewDef";
    
    UIImageView *imageView = [scorllPage reusePageView:imageViewDef];
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithReuseIdentifier:imageViewDef];
        imageView.contentMode = _imageViewContentMode;
        imageView.clipsToBounds = YES;
        imageView.bounds = CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    }
    
    index %= [self numberOfImage];
    
    //首先尝试从数据源获取图片
    ifHaveDataSel(@selector(imageScrollPage:imageForIndex:)){
        UIImage * image = [dataSource imageScrollPage:self imageForIndex:index];
        
        if (image) {
            imageView.image = image;
            return imageView;
        }
    }
    
    NSString *imagePath = nil;
    
    //从图片名称获取
    ifRespondsSelector(dataSource, @selector(imageScrollPage:imageNameForIndex:)){
        NSString * imageName = [dataSource imageScrollPage:self imageNameForIndex:index];
        PathForResource(imagePath,imageName,nil);
    }
    
    NSString *imageURL = nil;
    
    if(!imagePath){
        //从图片路径获取
        ifRespondsSelector(dataSource, @selector(imageScrollPage:imagePathForIndex:)){
            imagePath = [dataSource imageScrollPage:self imagePathForIndex:index];
            
            if(imagePath){
                imageURL = [[[NSURL alloc] initFileURLWithPath:imagePath] absoluteString];
            }
        }
    }
    
    if(!imageURL){
        //从图片URL获取
        ifRespondsSelector(dataSource, @selector(imageScrollPage:imageURLForIndex:)){
            imageURL = [dataSource imageScrollPage:self imageURLForIndex:index];
        }
    }
    
    if (imageURL) {
        
        //设置图片
        [imageView setImageWithURL:imageURL
                  placeholderImage:self.placeholderImage
                  progressViewMode:self.placeholderImage ? ImageLoadProgressViewModeNone :
                                                           ImageLoadProgressViewModeIndeterminate
                    loadFailPolicy:ImageLoadFailPolicyAllPolicy
                    downLoadPolicy:ImageDownLoadPolicyDefault
              imageDownLoadManager:[self imageDownLoadManager]
                           success:nil
//                        ^(UIImageView * imageView,UIImage * image){
//                               
//                               UIImageView * tmpImageView = nil;
//                               
//                               if (self.placeholderImage) {
//                                   
//                                   tmpImageView = [[UIImageView alloc] initWithImage:self.placeholderImage];
//                                   tmpImageView.frame           = imageView.bounds;
//                                   tmpImageView.backgroundColor = self.backgroundColor;
//                                   tmpImageView.contentMode     = self.imageViewContentMode;
//                                   tmpImageView.clipsToBounds   = YES;
//                                   [imageView addSubview:tmpImageView];
//                               }else{
//                                   imageView.alpha = 0.f;
//                               }
//                               
//                               [UIView animateWithDuration:0.8f animations:^{
//                                   
//                                   imageView.alpha = 1.f;
//                                   tmpImageView.alpha = 0.f;
//                               } completion:^(BOOL finished){
//                                   
//                                   [tmpImageView removeFromSuperview];
//                               }];
//                           }
                           failure:nil];
        
    }else{
        [imageView cancleLoadURLImage:NO];
        imageView.image = nil;
    }
    
    
    return imageView;
}


- (NSString *)scorllPage:(MyScrollPage *)scorllPage titleForIndex:(NSUInteger)index
{
    index %= [self numberOfImage];
    
    ifHaveDataSel(@selector(imageScrollPage:titleForIndex:)){
        return [dataSource imageScrollPage:self titleForIndex:index];
    }
    
    return nil;
}

- (UIView *)scorllPage:(MyScrollPage *)scorllPage titleViewForIndex:(NSUInteger)index
{
    index %= [self numberOfImage];
    
    ifHaveDataSel(@selector(imageScrollPage:titleViewForIndex:)){
        return [dataSource imageScrollPage:self titleViewForIndex:index];
    }
    
    return nil;
}

- (void)scorllPage:(MyScrollPage *)scorllPage didTapPageAtIndex:(NSUInteger)index
{
    index %= [self numberOfImage];
    
    id<MyImageScrollPageDelegate> delegate = __delegate;
    ifRespondsSelector(delegate, @selector(imageScrollPage:didTapImageAtIndex:)){
        [delegate imageScrollPage:self didTapImageAtIndex:index];
    }
}

- (void)scorllPage:(MyScrollPage *)scorllPage didChangeToPageAtIndex:(NSUInteger)index
{
    index %= [self numberOfImage];
    
    //索引不一样
    if (index != _currentImageIndex) {
        
        _currentImageIndex = index;
        
        id<MyImageScrollPageDelegate> delegate = __delegate;
        ifRespondsSelector(delegate, @selector(imageScrollPage:didShowImageAtIndex:)){
            [delegate imageScrollPage:self didShowImageAtIndex:index];
        }
        
        [self _layoutPageIndicatorView];
    }

}


@end
