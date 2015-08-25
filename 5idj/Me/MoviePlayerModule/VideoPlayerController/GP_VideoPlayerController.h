//
//  GP_VideoPlayerController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-2-27.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "GP_Video.h"

//----------------------------------------------------------

@protocol GP_VideoPlayerControllerDelegate;

//----------------------------------------------------------

@interface GP_VideoPlayerController :NSObject

//- (id)initWithVideo:(GP_Video *)video;

//视图
@property(nonatomic,strong,readonly) UIView * view;

//是否全屏显示，默认为NO,全屏显示状态下控制器不同
@property(nonatomic,getter = isFullScreen) BOOL fullScreen;

//代理
@property(nonatomic,weak) id<GP_VideoPlayerControllerDelegate> delegate;
//

//播放
- (void)playWithVideo:(GP_Video *)video;

//恢复
- (void)resume;

//暂停
- (void)pause;

//停止
- (void)stop;

@end

//----------------------------------------------------------

@protocol GP_VideoPlayerControllerDelegate

//选择了返回按钮
- (void)videoPlayerControllerDidTapBack:(GP_VideoPlayerController *)videoPlayerController;

//将要全屏或非全屏显示，返回NO取消
- (BOOL)videoPlayerController:(GP_VideoPlayerController *)videoPlayerController wantToFullScreenShow:(BOOL)fullScreenShow;

@end

//----------------------------------------------------------

