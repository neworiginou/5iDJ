//
//  GP_ChannelSearchViewController.h
//  5idj
//
//  Created by Xuzhanya on 14/12/19.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import "GP_BasicSubViewController.h"
#import "GP_Channel.h"

@interface GP_ChannelSearchViewController : GP_BasicSubViewController

+ (GP_MainNavigationController *)navigationControllerWithChannel:(GP_Channel *)channel;

- (id)initWithChannel:(GP_Channel *)channel;

@end
