//
//  GP_PlayControllerView.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-18.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

//typedef NS_ENUM(NSUInteger, PCVStatus) {
//    PCVStatusFullScreen,  //全屏
//    PCVStatusUnFullScreen //非全屏
//};

//----------------------------------------------------------

//播放按钮的状态
typedef NS_ENUM(NSUInteger, PCVPlayButtonStatus){
    PCVPlayButtonStatusPlay,//播放
    PCVPlayButtonStatusPause//暂停
};

//----------------------------------------------------------

@class GP_PlayControllerView;

//----------------------------------------------------------

@protocol PlayControllerViewDelegate

//正在缩放
- (void)playControllerView:(GP_PlayControllerView *)playControllerView changingScaleFactor:(float)scale;
//结束缩放
- (void)playControllerView:(GP_PlayControllerView *)playControllerView endChangeScaleFactor:(float)scale;
//取消
- (void)playControllerViewCancleChangeScaleFactor:(GP_PlayControllerView *)playControllerView;

- (void)playControllerView:(GP_PlayControllerView *)playControllerView willChangePlayDuration:(NSTimeInterval)playDuration;
- (void)playControllerViewDidTapPlayButton:(GP_PlayControllerView *)playControllerView;
- (void)playControllerViewDidTapZoomButton:(GP_PlayControllerView *)playControllerView;
- (void)playControllerViewDidTapBackButton:(GP_PlayControllerView *)playControllerView;
- (void)playControllerViewDidChangeScalingMode:(GP_PlayControllerView *)playControllerView;


@end

//----------------------------------------------------------

@interface GP_PlayControllerView : UIView

////类型，全屏和非全屏两种类型
//@property(nonatomic) PCVStatus status;

@property(nonatomic) NSTimeInterval videoDuration;
@property(nonatomic) NSTimeInterval playDuration;
@property(nonatomic) NSTimeInterval loadDuration;

//是否全屏显示
@property(nonatomic) BOOL fullScreenShow;

//设置标题
- (void)setTitle:(NSString *)title;

//设置播放按钮状态
- (void)setPlayButtonStatus:(PCVPlayButtonStatus)playButtonStatus;

//开始控制播放
- (void)startControlPlay;

//结束控制播放
- (void)endControlPlay;

//代理
@property(nonatomic,weak) id<PlayControllerViewDelegate> delegate;

@end
