//
//  GP_BasicImageAndTitleCell.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-5.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "GP_ImageAndTitleContentView.h"

//----------------------------------------------------------

@class GP_BasicTitleAndImage;

//----------------------------------------------------------

@interface GP_BasicImageAndTitleCell : UICollectionViewCell

+ (CGSize)cellSize;

+ (GP_ImageAndTitleContentViewType)imageAndTitleContentViewType;

@property(nonatomic,strong,readonly) GP_ImageAndTitleContentView * imageAndTitleContentView;

- (void)updateWithBasicTitleAndImage:(GP_BasicTitleAndImage *)basicTitleAndImage;


@end
