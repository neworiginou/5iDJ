//
//  GP_VideoFilterInfoCell.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "GP_VideoFilterInfo.h"

//----------------------------------------------------------

@interface GP_VideoFilterInfoCell : UITableViewCell

- (void)updateWithVideoFilterInfo:(GP_VideoFilterInfo *)videoFilterInfo;

@end
