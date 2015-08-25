//
//  MyLoadingIndicateView.h
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-28.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyIndicateView.h"

//----------------------------------------------------------

#define DefaultContextTag       -1
#define LoadingErrorContextTag  1000
#define NoNetworkContextTag     1001

//----------------------------------------------------------

@class MyLoadingIndicateView;

@protocol MyLoadingIndicateViewDelegate

@optional

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView;

@end

//----------------------------------------------------------

@interface MyLoadingIndicateView : MyIndicateView


@property(nonatomic,weak) id<MyLoadingIndicateViewDelegate> delegate;

//支持点击事件，默认为NO
@property(nonatomic) BOOL supportTapGesture;

//上下文标记
@property(nonatomic) NSInteger contextTag;

- (void)showLoadingStatusWithTitle:(NSString *)title detailText:(NSString *)detailText;

- (void)showLoadingErrorStatusWithTitle:(NSString *)title detailText:(NSString *)detailText;

- (void)showLoadingErrorStatusWithWithImage:(UIImage *)image
                                      title:(NSString *)title
                                 detailText:(NSString *)detailText;
- (void)showNoNetworkStatus;

- (void)showNoNetworkStatusWithImage:(UIImage *)image
                               title:(NSString *)title
                          detailText:(NSString *)detailText
               observerNetworkChange:(BOOL)observerNetworkChange;

- (void)showImageStatusWithImage:(UIImage  *)image
                           title:(NSString *)title
                      detailText:(NSString *)detailText;

- (void)showCustomViewStatusWithCustomView:(UIView *)customView
                                     title:(NSString *)title
                                detailText:(NSString *)detailText;


- (void)hiddenView;

@end
