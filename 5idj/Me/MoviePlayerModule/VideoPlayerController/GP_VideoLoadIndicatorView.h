//
//  GP_VideoLoadIndicatorView.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-18.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

typedef NS_ENUM(int, VideoLoadIndicatorViewStatus) {
    VideoLoadIndicatorViewStatusHidden,
    VideoLoadIndicatorViewStatusLoading,
    VideoLoadIndicatorViewStatusPlayButton
};

//----------------------------------------------------------

@class GP_VideoLoadIndicatorView;

//----------------------------------------------------------

@protocol GP_VideoLoadIndicatorViewDelegate<MyLoadingIndicateViewDelegate>

- (void)videoLoadIndicatorViewDidTapPlay:(GP_VideoLoadIndicatorView *)videoLoadIndicatorView;

@end

//----------------------------------------------------------

@interface GP_VideoLoadIndicatorView : MyLoadingIndicateView

@property(nonatomic,weak) id<GP_VideoLoadIndicatorViewDelegate> delegate;

- (void)showLoadingVideo;
- (void)showLoadingVideoURL;

- (void)showPlayButtonWithTitle:(NSString *)title;

- (void)showPlayErroWithTitle:(NSString *)title detailText:(NSString *)detailText;

//- (void)testTapButton;

@end
