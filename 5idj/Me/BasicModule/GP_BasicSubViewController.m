//
//  GP_BasicSubViewController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicSubViewController.h"
#import "GP_SwipeBackHelpView.h"

//----------------------------------------------------------

@implementation GP_BasicSubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hiddenTabBarWhenViewDidAppear = YES;
    self.navigationInteractivePopEnable = YES;
    
    if ([self hasNavigationBar]) {
        //设置返回按钮
        [self.myNavigationItem setLeftBarButtonItem:self.backBarButtonItem];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    GP_SwipeBackHelpView * swipeBackHelpView = [[GP_SwipeBackHelpView alloc] initWithKey:@"HadShowSwipeBackHelpView" text:[self backHelpViewText]];
    [swipeBackHelpView show];
    
}

- (NSString *)backHelpViewText
{
    return @"亲，向右横滑可以返回哟";
}

//
//- (void)backBarButtonHandle
//{
//    [super backBarButtonHandle];
//    [self viewControllerWillPopFromNavigationController];
//}


//- (void)didPopByGesture
//{
////    [self viewControllerWillPopFromNavigationController];
//}

//- (void)viewControllerWillPopFromNavigationController
//{
//    
//}

- (BOOL)fullScreenModeIncludeTabBar
{
    return NO;
}



@end
