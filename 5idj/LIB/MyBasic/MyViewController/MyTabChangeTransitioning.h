//
//  MyTabChangeTransitioning.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-12.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, TabChangeDirection) {
    TabChangeDirectionPrev,
    TabChangeDirectionNext
};

typedef NS_ENUM(int, MyTabChangeTransitioningType) {
    MyTabChangeTransitioningTypeRotation,
    MyTabChangeTransitioningTypeTranslation
};

@interface MyTabChangeTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

- (id)initWithTabChangeDirection:(TabChangeDirection)direction;

- (id)initWithTabChangeDirection:(TabChangeDirection)direction
                            type:(MyTabChangeTransitioningType)type
                       animation:(void(^)())animation;

//动画时长，默认为0.4f;
@property(nonatomic) NSTimeInterval transitionDuration;

@end


