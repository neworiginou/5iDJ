//
//  GP_BasicViewController.m
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-9.
//  Copyright (c) 2013年 hldw航. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicMainViewController.h"
#import "GP_SwipeChangeTabHelpView.h"

//----------------------------------------------------------

@implementation GP_BasicMainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.memoryTabBarHiddenStatus = YES;
    self.tabBarInteractiveEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    
    if ((float)rand() / RAND_MAX > 0.5f) {
        GP_SwipeChangeTabHelpView * swipeChangeTabHelpView = [[GP_SwipeChangeTabHelpView alloc] initWithKey:@"HadShowSwipeChangeTabHelpView"];
        
        [swipeChangeTabHelpView show];
    }
}




@end

