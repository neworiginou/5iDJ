//
//  GP_MainNavigationController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "GP_MainNavigationController.h"


@implementation GP_MainNavigationController
{
    MyNavigationTransitioningDelegate * _transitioningDelegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _transitioningDelegate = [[MyNavigationTransitioningDelegate alloc] initWithNavigationController:self];
    
    self.navigationBarHidden = YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}


@end
