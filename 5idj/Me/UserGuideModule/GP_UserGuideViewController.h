//
//  GP_UserGuideViewController.h
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-10.
//  Copyright (c) 2013年 hldw航. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@class GP_UserGuideViewController;

//----------------------------------------------------------


@protocol GP_UserGuideViewControllerDelegate

- (void)userGuideViewControllerWillHidden:(GP_UserGuideViewController *)viewController;

@end

//----------------------------------------------------------

@interface GP_UserGuideViewController : UIViewController

//显示
- (void)show;

//代理
@property(nonatomic, weak) id<GP_UserGuideViewControllerDelegate> delegate;

@end
