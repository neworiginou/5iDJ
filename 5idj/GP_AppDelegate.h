//
//  GP_AppDelegate.h
//  GamePlayerDemo
//
//  Created by hldw航 on 13-12-8.
//  Copyright (c) 2013年 hldw航. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@class GP_Video;
@class GP_Channel;

//----------------------------------------------------------

@interface GP_AppDelegate : MyAppDelegate

+ (void)sendPlayVideoEvent:(GP_Video *)video duration:(NSTimeInterval)playDuration;

+ (void)sendViewChannelEvent:(GP_Channel *)channel;


@end
