//
//  GP_VideoPlayerTransting.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-14.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

#define A_TAN_1_4     0.244979
#define _2_A_TAN_1_4  0.489958

//----------------------------------------------------------

@interface GP_VideoPlayerTransting : NSObject < UIViewControllerAnimatedTransitioning>

- (id)initWithType:(PresentAnimatedTransitioningType)type;

@property(nonatomic,readonly) PresentAnimatedTransitioningType type;

//- (id)initWithNavigationControllerOperation:(UINavigationControllerOperation)operation;

@end
