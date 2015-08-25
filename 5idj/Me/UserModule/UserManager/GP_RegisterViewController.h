//
//  GP_RegisterViewController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-27.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicSubViewController.h"

//----------------------------------------------------------

@class GP_RegisterViewController;

//----------------------------------------------------------

@protocol GP_RegisterViewControllerDelegate

- (void)registerViewController:(GP_RegisterViewController *)registerViewController didRegisterSuccessWithUserName:(NSString *)userName;

@end

//----------------------------------------------------------

@interface GP_RegisterViewController : GP_BasicSubViewController

@property(nonatomic,weak) id<GP_RegisterViewControllerDelegate> delegate;

@end
