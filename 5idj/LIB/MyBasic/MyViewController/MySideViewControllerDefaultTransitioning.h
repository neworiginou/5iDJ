//
//  MySideViewControllerDefaultTransitioning.h
//  YHDemo
//
//  Created by Xuzhanya on 14-9-30.
//  Copyright (c) 2014年 hldw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MySideViewControllerAnimatedTransitioning;

@interface MySideViewControllerDefaultTransitioning : NSObject <MySideViewControllerAnimatedTransitioning>

//动画时长，默认为0.5f;
@property(nonatomic) NSTimeInterval transitionDuration;


@end
