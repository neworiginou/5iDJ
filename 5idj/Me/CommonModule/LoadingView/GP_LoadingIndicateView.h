//
//  GP_LoadingIndicateView.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-26.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

#define NoUserContextTag     1003
#define NothingContextTag    1004

//----------------------------------------------------------

@interface GP_LoadingIndicateView : MyLoadingIndicateView

- (void)showNoUserWiTitle:(NSString *)title;
- (void)showNoUserWiTitle:(NSString *)title detailText:(NSString *)detailText;

- (void)showNothingWiTitle:(NSString *)title;
- (void)showNothingWiTitle:(NSString *)title detailText:(NSString *)detailText;

@end
