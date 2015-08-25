//
//  GP_MainTabBarController.h
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-9.
//  Copyright (c) 2013年 xxxx. All rights reserved.
//

//----------------------------------------------------------

#import "MyTabBarController.h"
#import "GP_BasicViewController.h"

//----------------------------------------------------------

/*
 *该类为主TabBarController
 */
@interface GP_MainTabBarController : MyTabBarController

+ (GP_MainTabBarController *)mainTabBarControllerInstance;

+ (GP_BasicViewController *)currentSelectedMainViewController;

+ (GP_BasicViewController *)currentTopViewController;

@end

@interface UIViewController (GP_BasicViewController)

- (GP_BasicViewController *)currentTopViewController;

@end
