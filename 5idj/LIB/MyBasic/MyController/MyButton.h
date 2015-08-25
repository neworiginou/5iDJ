//
//  BT_ShowBottomButton.h
//  Bestone
//
//  Created by Xuzhanya on 14-5-21.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyButton : UIButton

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

- (UIColor *)backgroundColorForState:(UIControlState)state;

@end
