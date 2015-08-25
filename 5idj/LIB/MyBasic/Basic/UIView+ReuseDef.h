//
//  UIView+ReuseDef.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@interface UIView (ReuseDef)

/*
 *通过MyScrollPage的复用定义字符串初始化
 */
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

/*
 *返回MyScrollPage的复用定义字符串
 */
- (NSString *)reuseIdentifier;


@end
