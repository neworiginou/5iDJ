//
//  UIViewController+Instance.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "UIViewController+Instance.h"

@implementation UIViewController (Instance)

+ (instancetype)viewController
{
    NSString * nibFilePath = [[NSBundle mainBundle] pathForResource:NSStringFromClass([self class]) ofType:@"nib"];
    
    if (nibFilePath) {
        return [[self alloc] initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
    }
    
    return [self new];
}

@end
