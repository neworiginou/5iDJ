//
//  GP_ChannelCollectionCell.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-6.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ChannelCollectionCell.h"

//----------------------------------------------------------

@implementation GP_ChannelCollectionCell

- (void)updateWithChannel:(GP_Channel *)channel
{
    [super updateWithBasicTitleAndImage:channel];
}

+ (GP_ImageAndTitleContentViewType)imageAndTitleContentViewType
{
    return GP_ImageAndTitleContentViewTypeChannel;
}


@end
