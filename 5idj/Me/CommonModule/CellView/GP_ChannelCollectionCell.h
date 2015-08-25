//
//  GP_ChannelCollectionCell.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-6.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicImageAndTitleCell.h"
#import "GP_Channel.h"

//----------------------------------------------------------

@interface GP_ChannelCollectionCell : GP_BasicImageAndTitleCell

- (void)updateWithChannel:(GP_Channel *)channel;

@end
