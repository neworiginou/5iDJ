//
//  MyPushPopAnimatedTransitioning.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

#define PushPopAnimatedTypeLeft     0x0001
#define PushPopAnimatedTypeRight    0x0010
#define PushPopAnimatedTypePush     0x0100
#define PushPopAnimatedTypePop      0x1000

typedef NS_ENUM(NSUInteger, PushPopAnimatedType) {
    PushPopAnimatedTypeLeftPush  = PushPopAnimatedTypeLeft  | PushPopAnimatedTypePush,
    PushPopAnimatedTypeLeftPop   = PushPopAnimatedTypeLeft  | PushPopAnimatedTypePop,
    PushPopAnimatedTypeRightPush = PushPopAnimatedTypeRight | PushPopAnimatedTypePush,
    PushPopAnimatedTypeRightPop  = PushPopAnimatedTypeRight | PushPopAnimatedTypePop,
    
    PushPopAnimatedTypeNavigationPop  = PushPopAnimatedTypeRightPop,
    PushPopAnimatedTypeNavigationPush = PushPopAnimatedTypeLeftPush
};

//----------------------------------------------------------

@interface MyPushPopAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

- (id)initWithType:(PushPopAnimatedType)type;

- (id)initWithType:(PushPopAnimatedType)type animations:(void(^)(void))animations;

//类型
@property(nonatomic,readonly) PushPopAnimatedType type;

//动画时长，默认为0.4f;
@property(nonatomic) NSTimeInterval transitionDuration;

@end
