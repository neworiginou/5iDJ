//
//  MyDimissAnimatedTransitioning.h
//  5idj
//
//  Created by Xuzhanya on 14/10/23.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PresentAnimatedTransitioningType) {
    PresentAnimatedTransitioningTypePresent,
    PresentAnimatedTransitioningTypeDismiss
};

@interface MyPresentAnimatedTransitioning : NSObject < UIViewControllerAnimatedTransitioning >

- (id)initWithType:(PresentAnimatedTransitioningType)type;
- (id)initWithType:(PresentAnimatedTransitioningType)type animations:(void(^)(void))animations;

//类型
@property(nonatomic,readonly) PresentAnimatedTransitioningType type;

//动画时长，默认为0.4f;
@property(nonatomic) NSTimeInterval transitionDuration;

@end
