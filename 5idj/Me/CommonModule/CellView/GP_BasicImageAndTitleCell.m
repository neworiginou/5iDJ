//
//  GP_BasicImageAndTitleCell.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-5.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicImageAndTitleCell.h"
#import "GP_ImageAndTitleContentView.h"

//----------------------------------------------------------

@implementation GP_BasicImageAndTitleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        
        _imageAndTitleContentView = [[GP_ImageAndTitleContentView alloc] initWithType:[[self class] imageAndTitleContentViewType]];
        [self.contentView addSubview:_imageAndTitleContentView];
        
//        self.backgroundColor = [UIColor redColor];
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [_imageAndTitleContentView setHighlighted:highlighted];
}

- (void)updateWithBasicTitleAndImage:(GP_BasicTitleAndImage *)basicTitleAndImage
{
    [_imageAndTitleContentView setBasicTitleAndImage:basicTitleAndImage];
}

+ (GP_ImageAndTitleContentViewType)imageAndTitleContentViewType
{
    return GP_ImageAndTitleContentViewTypeVideo;
}


+ (CGSize)cellSize
{
    return [GP_ImageAndTitleContentView boundsForType:[self imageAndTitleContentViewType]].size;
}


@end
