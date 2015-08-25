//
//  GP_BasicHelpView.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-13.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GP_BasicHelpView : UIView

+ (NSUserDefaults *)userDefaultsForHelpView;

- (id)initWithKey:(NSString *)key;

- (void)startAnimation;

- (void)show;

- (void)hidden;

@end
