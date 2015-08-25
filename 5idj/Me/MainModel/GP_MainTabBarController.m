//
//  GP_MainTabBarController.m
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-9.
//  Copyright (c) 2013年 xxxx. All rights reserved.
//

//----------------------------------------------------------

#import "GP_MainTabBarController.h"

//----------------------------------------------------------

@interface GP_MainTabBarController ()

- (UIImage *)selectionIndicatorImageWithColor:(UIColor *)color lineWith:(CGFloat)lineWidth;


@end

//----------------------------------------------------------

@implementation GP_MainTabBarController

+ (GP_MainTabBarController *)mainTabBarControllerInstance
{
    UIViewController * viewController = [[GP_AppDelegate appDelegate] window].rootViewController;
    
    if ([viewController isKindOfClass:[GP_MainTabBarController class]]) {
        return (GP_MainTabBarController *)viewController;
    }
    
    return nil;
}

+ (GP_BasicViewController *)currentSelectedMainViewController
{
    GP_MainTabBarController * mainTabBarController = [self mainTabBarControllerInstance];
    
    id selectedViewController = mainTabBarController.selectedViewController;
    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
        
        id viewController = [[selectedViewController viewControllers] firstObject];
        if ([viewController isKindOfClass:[GP_BasicViewController class]]) {
            return viewController;
        }
    }

    return nil;
}

+ (GP_BasicViewController *)currentTopViewController
{
    return [[self mainTabBarControllerInstance] currentTopViewController];
}

- (void)dealloc
{
    [self setObserveThemeColorChange:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置色调
    [self.tabBar setTintColor:[UIColor whiteColor]];
    
    //设置背景
    [self.tabBar setBackgroundImage:resizableImageWithColor(defaultDarkBarColor)];
    
    
    NSArray *viewControllerClassNameArray = @[
                                       @"GP_HomeViewController",
                                       @"GP_ChannelViewController",
                                       @"GP_UserViewController",
                                       @"GP_MoreViewController"
//                                       @"GP_SettingViewController"
                                       ];
    
    NSMutableArray *viewControllerArray=[NSMutableArray arrayWithCapacity:viewControllerClassNameArray.count];
    
    for (NSString *className in viewControllerClassNameArray) {
        
        UINavigationController *navigationController = [NSClassFromString(className) navigationController];
        
        //设置图片偏移量，使之居中
        navigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
        
        [viewControllerArray addObject:navigationController];
    }
    
    self.viewControllers = viewControllerArray;
    
    //改变主题颜色
    [self didChangeThemeColor];
    
    //观察改变
    [self setObserveThemeColorChange:YES];
    
}

- (void)didChangeThemeColor
{
    self.tabBar.selectionIndicatorImage = [self selectionIndicatorImageWithColor:[self currentThemeColor] lineWith:3.f];
}


- (UIImage *)selectionIndicatorImageWithColor:(UIColor *)color lineWith:(CGFloat)lineWidth
{
    
    NSUInteger viewControllersCount = self.viewControllers.count;
    
    if (viewControllersCount == 0) {
        return nil;
    }
    
    CGRect tabBarBounds = self.tabBar.bounds;
    
    CGRect tabBarItemBounds = CGRectMake(0.f, 0.f, CGRectGetWidth(tabBarBounds) /viewControllersCount, CGRectGetHeight(tabBarBounds));
    CGRect indicatorLineFrame = CGRectMake(0.f, CGRectGetHeight(tabBarItemBounds) - lineWidth, CGRectGetWidth(tabBarItemBounds), lineWidth);
    
    UIGraphicsBeginImageContextWithOptions(tabBarItemBounds.size, NO, 0.f);
    
    //背景
    UIColor * backgroundColor = [UIColor colorWithWhite:0.3f alpha:0.85f];
    [backgroundColor setFill];
    UIRectFill(tabBarItemBounds);
    
    //指示颜色
    [color setFill];
    UIRectFill(indicatorLineFrame);
    
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
      
    UIGraphicsEndImageContext();

    return resultImage;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([super tabBarController:tabBarController shouldSelectViewController:viewController]) {
        
        if (viewController == self.selectedViewController) {
            
            if ([viewController isKindOfClass:[UINavigationController class]]) {
                
                UIViewController * rootViewController = [(UINavigationController *)viewController topViewController];
                
                if ([rootViewController isKindOfClass:[GP_BasicViewController class]]) {
                    [(GP_BasicViewController *)rootViewController tryRefreshData];
                }
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}
@end

@implementation UIViewController (GP_BasicViewController)

- (GP_BasicViewController *)currentTopViewController
{
    id presentedViewController = self.presentedViewController;
    
    if (presentedViewController) {
        return [presentedViewController currentTopViewController];
    }else{
        
        if ([self isKindOfClass:[GP_BasicViewController class]]) {
            return (GP_BasicViewController *)self;
        }else if ([self isKindOfClass:[UINavigationController class]]){
            return [[(UINavigationController *)self topViewController] currentTopViewController];
        }else if ([self isKindOfClass:[UITabBarController class]]){
            return [[(UITabBarController *)self selectedViewController] currentTopViewController];
        }
    }
 
    return nil;
}

@end
