//
//  GP_BasicImageAndTitleView.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-2.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicTitleAndImage.h"

//----------------------------------------------------------

//类型
typedef NS_ENUM(int, GP_ImageAndTitleContentViewType) {
    GP_ImageAndTitleContentViewTypeVideo,
    GP_ImageAndTitleContentViewTypeChannel
};

//----------------------------------------------------------

#define ShadowRadius 1.5f

//----------------------------------------------------------

@interface GP_ImageAndTitleContentView : UIView

+ (CGRect)boundsForType:(GP_ImageAndTitleContentViewType)type;

//缩放比例
+ (CGFloat)scaleFactor;

+ (CGSize)imageViewSize;

- (id)initWithType:(GP_ImageAndTitleContentViewType)type;

//- (void)setShowSelectedView:(BOOL)showSelectedView;

@property(nonatomic,readonly) GP_ImageAndTitleContentViewType type;

@property(nonatomic) BOOL highlighted;

//@property(nonatomic,getter = isSelected) BOOL selected;

@property(nonatomic,weak) id<SelectBasicTitleAndImageProtocol> selectDelegate;

@property(nonatomic,strong) GP_BasicTitleAndImage *basicTitleAndImage;

//图像的frame
- (CGRect)imageViewFrame;

@end
