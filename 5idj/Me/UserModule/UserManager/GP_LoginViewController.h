//
//  GP_LoginViewController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-27.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicSubViewController.h"

//----------------------------------------------------------

@class GP_LoginViewController;

//----------------------------------------------------------

@protocol GP_LoginViewControllerDelegate

- (void)loginViewControllerDidSucceedLoginUser:(GP_LoginViewController *)loginViewController;

@end

//----------------------------------------------------------

@interface GP_LoginViewController : GP_BasicSubViewController

@property(nonatomic,weak) id<GP_LoginViewControllerDelegate> delegate;

@end
