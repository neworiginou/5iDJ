//
//  GP_HomeHotFocusTableViewCell.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-11.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_HomeHotFocusVideosView.h"
#import "GP_LoadingIndicateView.h"

//----------------------------------------------------------

@interface GP_HomeHotFocusVideosView () <
                                         MyImageScrollPageDelegate,
                                         MyImageScrollPageDataSource
                                        >

@property(nonatomic,strong,readonly) GP_LoadingIndicateView * indicateView;

@end


@implementation GP_HomeHotFocusVideosView
{
    MyImageScrollPage * _imageScrollPage;
    
    NSArray * _hotFoucsVideoArray;
}

@synthesize indicateView = _indicateView;

- (id)initWithVideos:(NSArray *)videos
{
    if (self=[super initWithFrame:CGRectZero]) {
        
        //初始化图片滑动展示页面
        _imageScrollPage = [[MyImageScrollPage alloc] initWithStyle:MyScrollPageStyleBottom circle:YES];
        _imageScrollPage.backgroundColor      = [UIColor whiteColor];
        _imageScrollPage.delegate             = self;
        _imageScrollPage.dataSource           = self;
        _imageScrollPage.imageViewContentMode = UIViewContentModeScaleAspectFill;
        _imageScrollPage.titleTextFont        = [UIFont boldSystemFontOfSize:14.f];
        _imageScrollPage.titleBackgrounpColor = defaultBackIndicateColor;
        _imageScrollPage.placeholderImage     = ImageWithName(@"placeholder_big");
        [self addSubview:_imageScrollPage];
        
        //更新
        [self updateWithVideos:videos];
    }
    
    return self;
    
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    _imageScrollPage.pageIndicatorColor = self.tintColor;
}

- (GP_LoadingIndicateView *)indicateView
{
    if (!_indicateView) {
        _indicateView = [[GP_LoadingIndicateView alloc] initWithFrame:self.bounds];
        _indicateView.backgroundColor  = defaultCellBackgroundColor;
        _indicateView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indicateView];
    }
    
    return _indicateView;
}

- (void)updateWithVideos:(NSArray *)videos
{
    _hotFoucsVideoArray = videos;
    
    if (_hotFoucsVideoArray.count == 0) {
        [self.indicateView showNothingWiTitle:@"没有获取到任何内容" detailText:@"请稍后重新获取"];
        _imageScrollPage.hidden = YES;
    }else{
        [_indicateView hiddenView];
        _imageScrollPage.hidden = NO;
    }
    
    [_imageScrollPage reloadData];
}

- (CGSize)imageSizeForImageScrollPage:(MyImageScrollPage *)imageScrollPage
{
    return self.bounds.size;
}

- (NSUInteger)numberOfImageInImageScrollPage:(MyImageScrollPage *)imageScrollPage
{
    return _hotFoucsVideoArray.count;
}

- (NSString *)imageScrollPage:(MyImageScrollPage *)imageScrollPage imageURLForIndex:(NSUInteger)index
{
    return [(GP_Video *)_hotFoucsVideoArray[index] imageURL];
}

- (NSString *)imageScrollPage:(MyImageScrollPage *)imageScrollPage titleForIndex:(NSUInteger)index
{
    NSString * title = [(GP_Video *)_hotFoucsVideoArray[index] title];
    
    return  title ?: @"";
}

- (void)imageScrollPage:(MyImageScrollPage *)imageScrollPage didTapImageAtIndex:(NSUInteger)index
{
    SafeSendSelectVideoMsg(_videoDelegate,_hotFoucsVideoArray[index]);
}


@end
