//
//  GP_VideoDetailCell.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "GP_Video.h"

//----------------------------------------------------------

@interface GP_VideoDetailCell : MyTintTableViewCell

+ (CGFloat)cellHeight;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateWithVideo:(GP_Video *)video;

@end
