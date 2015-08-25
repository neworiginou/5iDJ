//
//  MyTintTableViewCell.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-29.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyTintTableViewCell.h"
#include "MacroDef.h"

//----------------------------------------------------------

@implementation MyTintTableViewCell
{
    CALayer * _indicateLayer;
    CALayer * _separatorLineLayer;
    UIEdgeInsets _separatorInset;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _initialization];
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self _initialization];
}

- (void)_initialization
{
    _canShowTintView    = YES;
    _showSeparatorLine  = NO;
    _separatorLineColor = [UIColor grayColor];
    _tintColorAlpha     = 1.f;
    _separatorInset     = UIEdgeInsetsZero;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableArray * highlightedObjects = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (self.textLabel) {
        [highlightedObjects addObject:self.textLabel];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
    
    if (self.detailTextLabel) {
        [highlightedObjects addObject:self.detailTextLabel];
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
    }
    
    if (self.imageView) {
        [highlightedObjects addObject:self.imageView];
    }
    
    self.highlightedObjects = highlightedObjects;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_showSeparatorLine) {
        
        UIEdgeInsets separatorInset = _separatorInset;
        
        CGFloat onePiexlLength = PiexlToPoint(1);
        
        _separatorLineLayer.frame = CGRectMake(separatorInset.left, CGRectGetHeight(self.bounds) - onePiexlLength, CGRectGetWidth(self.bounds) - separatorInset.left - separatorInset.right, onePiexlLength);
    }
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset
{
    if (_showSeparatorLine) {
        _separatorInset = separatorInset;
        
        [self setNeedsLayout];
    }else{
        super.separatorInset = separatorInset;
    }
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    if (_indicateLayer) {
        _indicateLayer.backgroundColor = [self.tintColor colorWithAlphaComponent:_tintColorAlpha].CGColor;
    }
}

- (void)setTintColorAlpha:(CGFloat)tintColorAlpha
{
    if (_tintColorAlpha != tintColorAlpha) {
        _tintColorAlpha = tintColorAlpha;
        
        if (_indicateLayer) {
            _indicateLayer.backgroundColor = [self.tintColor colorWithAlphaComponent:_tintColorAlpha].CGColor;
        }
    }
}


- (void)setCanShowTintView:(BOOL)canShowTintView
{
    if (_canShowTintView != canShowTintView) {
        _canShowTintView = canShowTintView;
        
        if (!_canShowTintView) {
            [_indicateLayer removeFromSuperlayer];
        }
    }
}

- (void)setShowSeparatorLine:(BOOL)showSeparatorLine
{
    if (_showSeparatorLine != showSeparatorLine) {
        
        if (_showSeparatorLine) {
            [_separatorLineLayer removeFromSuperlayer];
        }
        
        _showSeparatorLine = showSeparatorLine;
        
        
        if (_showSeparatorLine) {
            
            if (!_separatorLineLayer) {
                _separatorLineLayer = [CALayer layer];
                _separatorLineLayer.actions = @{@"bounds":[NSNull null],@"positon":[NSNull null],@"backgroundColor":[NSNull null]};
                _separatorLineLayer.backgroundColor = self.separatorLineColor.CGColor;
            }
            
            [self.layer addSublayer:_separatorLineLayer];
            
            [self setNeedsLayout];
        }
    }
}

- (void)setSeparatorLineColor:(UIColor *)separatorLineColor
{
    _separatorLineColor = separatorLineColor;
    _separatorLineLayer.backgroundColor = _separatorLineColor.CGColor;
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.isHighlighted != highlighted && !self.isSelected) {
        [self showTintView:highlighted animated:animated];
    }
    
    [super setHighlighted:highlighted animated:animated];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.isSelected != selected) {
        
        if (selected || ! self.isHighlighted) {
            [self showTintView:selected animated:animated];
        }
    }
    
    [super setSelected:selected animated:animated];
}

- (void)showTintView:(BOOL)show animated:(BOOL)animated
{
    if (!_canShowTintView) {
        return;
    }
    
    for (NSObject * object in self.highlightedObjects) {
        if([object respondsToSelector:@selector(setHighlighted:)]){
            [(id)object setHighlighted:show];
        }
    }
    
    if (show) {
        
        if (!_indicateLayer) {
            
            _indicateLayer = [[CALayer alloc] init];
            _indicateLayer.backgroundColor = [self.tintColor colorWithAlphaComponent:_tintColorAlpha].CGColor;
            _indicateLayer.hidden = YES;
            
            _indicateLayer.actions = @{
                                       @"bounds":[NSNull null],
                                       @"position":[NSNull null]
                                       };
        }
        
        [self.contentView.superview.layer insertSublayer:_indicateLayer atIndex:0];
        _indicateLayer.frame = _indicateLayer.superlayer.bounds;
        
        
        [CATransaction begin];
        
        if (!animated) {
            [CATransaction setDisableActions:YES];
        }
        
        _indicateLayer.hidden = NO;
        
        [CATransaction commit];
        
    }else{
        
        [CATransaction begin];
        
        if (!animated) {
            [CATransaction setDisableActions:YES];
        }
        
        _indicateLayer.hidden = YES;
        
        [CATransaction commit];
        
    }
}



@end
