//
//  BT_ShowBottomButton.m
//  Bestone
//
//  Created by Xuzhanya on 14-5-21.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "MyButton.h"

@interface MyButton()

@property(nonatomic,readonly,strong) NSMutableDictionary * backgrounpColorDic;

- (void)_updateBackgroundColor;

@end


@implementation MyButton

@synthesize backgrounpColorDic = _backgrounpColorDic;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBackgroundColor:self.backgroundColor forState:self.state];
}


- (NSMutableDictionary *)backgrounpColorDic
{
    if (!_backgrounpColorDic) {
        _backgrounpColorDic = [NSMutableDictionary dictionary];
        
    }
    
    return _backgrounpColorDic;
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (self.isHighlighted != highlighted) {
        
        [super setHighlighted:highlighted];
        
        [self _updateBackgroundColor];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    if (self.enabled != enabled) {
     
        [super setEnabled:enabled];
        
        [self _updateBackgroundColor];
    }
}

- (void)setSelected:(BOOL)selected
{
    if (self.isSelected != selected) {
        
        [super setSelected:selected];
        
        [self _updateBackgroundColor];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    backgroundColor = backgroundColor ?: [UIColor clearColor];
    
    [self.backgrounpColorDic setObject:backgroundColor forKey:[NSNumber numberWithInteger:state]];
    
    if (state == self.state) {
        [self _updateBackgroundColor];
    }
    
}

- (UIColor *)backgroundColorForState:(UIControlState)state
{
    
    if (state != UIControlStateNormal) {
        
        UIColor * backgroundColor = [self.backgrounpColorDic objectForKey:[NSNumber numberWithUnsignedInteger:state]];
        
        if (backgroundColor) {
            return backgroundColor;
        }
    }
    
    
    UIColor * backgroundColor = [self.backgrounpColorDic objectForKey:[NSNumber numberWithUnsignedInteger:UIControlStateNormal]];
    
    return backgroundColor ?: [UIColor clearColor];

}

- (void)_updateBackgroundColor
{
    [super setBackgroundColor:[self backgroundColorForState:self.state]];
}


@end
