//
//  GP_SwipeChangeTabHelpView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-13.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SwipeChangeTabHelpView.h"

//----------------------------------------------------------

@implementation GP_SwipeChangeTabHelpView
{
    UIView      * _contentView;
    UIImageView * _handImageView;
    UIImageView * _leftArrowImageView;
    UIImageView * _rightArrowImageView;
}


- (id)initWithKey:(NSString *)key
{
    return [self initWithKey:key text:@"亲，左右滑动试试看"];
}

- (id)initWithKey:(NSString *)key text:(NSString *)text
{
    self = [super initWithKey:key];
    
    if (self) {
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, (screenSize().height - 120.f) * 0.5f,screenSize().width, 120.f)];
        [self addSubview:_contentView];
        
        //左箭头
        _leftArrowImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"help_right_arrow")];
        _leftArrowImageView.frame = CGRectMake(20.f, 0.f, CGRectGetWidth(_leftArrowImageView.bounds), CGRectGetHeight(_leftArrowImageView.bounds));
        _leftArrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        [_contentView addSubview:_leftArrowImageView];
        
        //手
        _handImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"help_hand")];
        _handImageView.frame = CGRectMake(CGRectGetMaxX(_leftArrowImageView.frame), 15.f, CGRectGetWidth(_handImageView.bounds), CGRectGetHeight(_handImageView.bounds));
        [_contentView addSubview:_handImageView];
        
        //右箭头
        _rightArrowImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"help_right_arrow")];
        _rightArrowImageView.frame = CGRectMake(screenSize().width - CGRectGetMaxX(_leftArrowImageView.frame), 0.f,CGRectGetWidth(_rightArrowImageView.bounds), CGRectGetHeight(_rightArrowImageView.bounds));
        [_contentView addSubview:_rightArrowImageView];
        
        
        UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(_handImageView.frame) + 20.f, screenSize().width, 20.f)];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:15.f];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.text = text;
        [_contentView addSubview:textLabel];
    }
    
    return self;
}

- (void)startAnimation
{
    _handImageView.frame = CGRectMake(CGRectGetMaxX(_leftArrowImageView.frame), 15.f, CGRectGetWidth(_handImageView.bounds), CGRectGetHeight(_handImageView.bounds));
    
    [_handImageView.layer removeAllAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.f];
    [UIView setAnimationRepeatCount:MAXFLOAT];
    [UIView setAnimationRepeatAutoreverses:YES];
    
    [_handImageView setFrame:CGRectOffset(_handImageView.frame, screenSize().width - 2 * CGRectGetMaxX(_leftArrowImageView.frame) - 40.f , 0.f)];
    
    [UIView commitAnimations];
}



@end
