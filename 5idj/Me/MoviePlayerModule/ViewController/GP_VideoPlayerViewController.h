//
//  GP_MoviePlayerViewController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-2-25.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicSubViewController.h"
#import "GP_Video.h"

//----------------------------------------------------------

@interface GP_VideoPlayerViewController : GP_BasicSubViewController

+ (instancetype)videoPlayerViewControllerWithWithVideo:(GP_Video *)video;

+ (UINavigationController *)videoPlayerViewControllerWithNavigationControllerForVideo:(GP_Video *)video;

- (id)initWithVideo:(GP_Video *)video;

@end
