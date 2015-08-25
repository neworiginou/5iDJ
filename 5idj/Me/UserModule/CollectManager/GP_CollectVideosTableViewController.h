//
//  GP_CollectVideosTableViewController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoDetailTableController.h"

//----------------------------------------------------------

@class GP_CollectVideosTableViewController;

//----------------------------------------------------------

@protocol GP_CollectVideosTableViewControllerDelegate <NSObject>

@optional

- (void)collectVideosTableViewControllerDidDeleteVideo:(GP_CollectVideosTableViewController *)collectVideosTableViewController;

@end

//----------------------------------------------------------

@interface GP_CollectVideosTableViewController : GP_VideoDetailTableController

@property(nonatomic,weak) id<GP_CollectVideosTableViewControllerDelegate> delegate;

@end
