//
//  GP_SwipeBackHelpView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-13.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SwipeBackHelpView.h"

//----------------------------------------------------------

@implementation GP_SwipeBackHelpView
{
    UIView      * _contentView;
    UIImageView * _handImageView;
    UIImageView * _rightArrowImageView;
    UILabel     * _textLabel;
}


- (id)initWithKey:(NSString *)key
{
    return [self initWithKey:key text:@"亲，向右横滑可以返回哟"];
}

- (id)initWithKey:(NSString *)key text:(NSString *)text
{
    self = [super initWithKey:key];
    
    if (self) {
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, (screenSize().height - 120.f) * 0.5f,screenSize().width, 120.f)];
        [self addSubview:_contentView];
        
        _rightArrowImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"help_right_arrow")];
        _rightArrowImageView.frame = CGRectMake(20.f, 0.f, CGRectGetWidth(_rightArrowImageView.bounds), CGRectGetHeight(_rightArrowImageView.bounds));
        [_contentView addSubview:_rightArrowImageView];
        
        _handImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"help_hand")];
        _handImageView.frame = CGRectMake(CGRectGetMaxX(_rightArrowImageView.frame), 15.f, CGRectGetWidth(_handImageView.bounds), CGRectGetHeight(_handImageView.bounds));
        [_contentView addSubview:_handImageView];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(_handImageView.frame) + 20.f, screenSize().width, 20.f)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:15.f];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.text = text;
        [_contentView addSubview:_textLabel];
    }
    
    return self;

}

- (void)startAnimation
{
    
    [_handImageView setAlpha:0.1f];
    _handImageView.frame = CGRectMake(CGRectGetMaxX(_rightArrowImageView.frame), 15.f, CGRectGetWidth(_handImageView.bounds), CGRectGetHeight(_handImageView.bounds));
 
    [_handImageView.layer removeAllAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.f];
    [UIView setAnimationRepeatCount:MAXFLOAT];
    
    [_handImageView setAlpha:1.f];
    [_handImageView setFrame:CGRectOffset(_handImageView.frame, screenSize().width - 2 * CGRectGetMaxX(_rightArrowImageView.frame) , 0.f)];
    
    [UIView commitAnimations];

}


@end
