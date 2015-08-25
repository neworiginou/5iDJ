//
//  GP_VideoCollectionCell.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-5.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicImageAndTitleCell.h"
#import "GP_Video.h"

//----------------------------------------------------------

@interface GP_VideoCollectionCell : GP_BasicImageAndTitleCell

- (void)updateWithVideo:(GP_Video *)video;

@end
