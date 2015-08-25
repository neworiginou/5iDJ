//
//  GP_VideoFilterInfoCell.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoFilterInfoCell.h"

//----------------------------------------------------------


@interface GP_VideoFilterInfoContentView : UIView

@property(nonatomic,strong) GP_VideoFilterInfo * videoFilterInfo;

- (void)updateView;

- (CATextLayer *)textLayerAtIndex:(NSUInteger)index;

- (NSInteger)indexForPoint:(CGPoint)point;

- (CGRect)frameForIndex:(NSUInteger)index;

@end

//----------------------------------------------------------


@implementation GP_VideoFilterInfoContentView
{
    NSMutableArray  * _textLayerArray;
    
    NSInteger         _highlightIndex;
    
    CALayer         * _selectLayer;
    
    CALayer         * _highlightLayer;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        CGFloat cornerRadius = AspectScaleLenght(2.f);
        
        self.layer.borderWidth  = PiexlToPoint(1);
        self.layer.borderColor  = defaultLineColor.CGColor;
        self.layer.cornerRadius = cornerRadius;
        
        self.backgroundColor = defaultCellBackgroundColor;
        
        _textLayerArray = [NSMutableArray array];
        _highlightIndex = NoSelectIndex;
        
        _selectLayer = [CALayer layer];
        _selectLayer.cornerRadius = cornerRadius;
        _selectLayer.backgroundColor = [self.tintColor colorWithAlphaComponent:0.7f].CGColor;
    
        _highlightLayer = [CALayer layer];
        _highlightLayer.cornerRadius = cornerRadius;
        _highlightLayer.backgroundColor = [self.tintColor colorWithAlphaComponent:0.4f].CGColor;
        
        //去除移动的动画
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
        _highlightLayer.actions = newActions;
    }
    
    return self;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    _selectLayer.backgroundColor = [self.tintColor colorWithAlphaComponent:0.7f].CGColor;
    _highlightLayer.backgroundColor = [self.tintColor colorWithAlphaComponent:0.4f].CGColor;
    
}


- (void)layoutSubviews
{
    [self updateView];
}


- (void)setVideoFilterInfo:(GP_VideoFilterInfo *)videoFilterInfo
{
    if (_videoFilterInfo != videoFilterInfo) {
        _videoFilterInfo = videoFilterInfo;
        _highlightIndex  = NoSelectIndex;
        
        if (self.window) {
         
            [self updateView];
        }
    }
}

- (void)updateView
{
    //移除所有的视图
    self.layer.sublayers = nil;
    
    NSUInteger count = _videoFilterInfo.valuesCount;
    
    if (count == 0) {
        return;
    }

    _selectLayer.frame = CGRectZero;
    [self.layer addSublayer:_selectLayer];
    
    _highlightLayer.frame = CGRectZero;
    _highlightLayer.hidden = YES;
    [self.layer addSublayer:_highlightLayer];
    
    //一行三个视图
    CGFloat width = CGRectGetWidth(self.bounds) / 3;
    CGFloat height = CGRectGetHeight(self.bounds) / ceilf(count / 3.f);
    
    
    //线的layer
    CALayer *lineLayer = [[CALayer alloc] init];
    lineLayer.frame    = self.bounds;
    [self.layer addSublayer:lineLayer];
    
    //渐变色
    
    CGColorRef startColor = [defaultLineColor colorWithAlphaComponent:0.1f].CGColor;
    
    NSArray *colors  = @[
                         (__bridge id)startColor,
                         (__bridge id)defaultLineColor.CGColor,
                         (__bridge id)startColor
                        ];
    
    
    CGFloat  onePiexlLength = PiexlToPoint(1);
    UIFont * font = [UIFont systemFontOfSize:AspectScaleLenght(15.f)];
    
    for (NSUInteger index = 0 ; index < count; ++ index) {
        
        NSUInteger  row  = index % 3;
        NSUInteger  line = index / 3;
        
        //文字大小
        NSString * text = [_videoFilterInfo valueAtIndex:index];
        CGSize textSize = TEXTSIZE(text, font);
        
        //文字高度
        CGFloat textHeight = textSize.height;
        textHeight = MIN(textHeight, height);
        
        CATextLayer * textLayer = [self textLayerAtIndex:index];
        textLayer.frame = CGRectMake(width * row , height * line + (height - textHeight) * 0.5f , width, textHeight);
        textLayer.string = text;
        
        //设置高亮显示
        [self _setHighlight:(index == _highlightIndex || index == _videoFilterInfo.selectValueIndex)
               forTextLayer:textLayer];
        
        [self.layer addSublayer:textLayer];
        
        if (row != 2) {
            
            CAGradientLayer * gradientLayer = [[CAGradientLayer alloc] init];
            gradientLayer.frame  = CGRectMake(width * (row + 1), (line + 0.2f) * height, onePiexlLength, height * 0.6f);
            gradientLayer.colors = colors;
            [lineLayer addSublayer:gradientLayer];
        }
        
        if (line != ceilf(count / 3.f) - 1) {
            
            CAGradientLayer * gradientLayer = [[CAGradientLayer alloc] init];
            gradientLayer.frame = CGRectMake(width * (row + 0.2f), (line + 1) * height, 0.6f * width, onePiexlLength);
            gradientLayer.colors     = colors;
            gradientLayer.startPoint = CGPointMake(0.f, .5f);
            gradientLayer.endPoint   = CGPointMake(1.f, .5f);
            [lineLayer addSublayer:gradientLayer];
        }
        
        if (index == _videoFilterInfo.selectValueIndex) {
            _selectLayer.frame = CGRectMake(width * row + 2.f, height * line + 2.f , width - 4.f, height - 4.f);
        }else if(index == _highlightIndex){
            _highlightLayer.hidden = NO;
            _highlightLayer.frame = CGRectMake(width * row + 2.f, height * line + 2.f , width - 4.f, height - 4.f);
        }
    }
    
}

- (CATextLayer *)textLayerAtIndex:(NSUInteger)index
{
    NSInteger needInitCount = index - _textLayerArray.count + 1;

    if (needInitCount > 0) {
        
        UIFont *font = [UIFont systemFontOfSize:AspectScaleLenght(15.f)];
        
        while (needInitCount -- > 0) {
            
            CATextLayer * textLayer = [[CATextLayer alloc] init];

            textLayer.font  = (__bridge CFTypeRef)font.fontName;
            textLayer.fontSize = font.pointSize;
            textLayer.alignmentMode = kCAAlignmentCenter;
            textLayer.truncationMode = kCATruncationEnd;
            textLayer.contentsScale = [UIScreen mainScreen].scale;

            [_textLayerArray addObject:textLayer];
        }
    }
    
    return _textLayerArray[index];
}

- (NSInteger)indexForPoint:(CGPoint)point
{
    NSUInteger count = _videoFilterInfo.valuesCount;
    
    if (count != 0) {
        
        //一行三个视图
        CGFloat width = CGRectGetWidth(self.bounds) / 3;
        CGFloat height = CGRectGetHeight(self.bounds) / ceilf(count / 3.f);
        
        NSInteger line = floorf(point.y / height);
        NSInteger row  = floorf(point.x / width);
        
        if (line >= 0 && row >= 0) {
            NSUInteger index = line * 3 + row;
            
            if (index < count) {
                return index;
            }
        }
    }

    return NoSelectIndex;
}

- (CGRect)frameForIndex:(NSUInteger)index
{
    
    NSUInteger count = _videoFilterInfo.valuesCount;
    
    if (count > index) {
        
        //一行三个视图
        CGFloat width = CGRectGetWidth(self.bounds) / 3;
        CGFloat height = CGRectGetHeight(self.bounds) / ceilf(count / 3.f);
        
        return CGRectMake(width * (index % 3), height * (index / 3), width, height);
    }
    
    return CGRectZero;
}

- (void)_setHighlight:(BOOL)highlight forTextLayer:(CATextLayer *)textLayer
{
    if (highlight) {
        textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    }else{
        textLayer.foregroundColor = defaultTitleTextColor.CGColor;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _highlightIndex = [self indexForPoint:[[touches anyObject] locationInView:self]];
    
    if (_highlightIndex != NoSelectIndex && _highlightIndex != _videoFilterInfo.selectValueIndex) {
        
        _highlightLayer.hidden = NO;
        _highlightLayer.frame = CGRectInset([self frameForIndex:_highlightIndex], 2.f, 2.f);
        
        [self _setHighlight:YES forTextLayer:[self textLayerAtIndex:_highlightIndex]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_highlightIndex != NoSelectIndex && _highlightIndex != _videoFilterInfo.selectValueIndex) {
        
        CGPoint point = [[touches anyObject] locationInView:self];
      
        CGRect frame = [self frameForIndex:_highlightIndex];
        
        if (CGRectContainsPoint(frame, point)){
            
            //原来有选择的
            if (_videoFilterInfo.selectValueIndex != NoSelectIndex) {
                [self _setHighlight:NO forTextLayer:[self textLayerAtIndex:_videoFilterInfo.selectValueIndex]];
            }
            
            _videoFilterInfo.selectValueIndex = _highlightIndex;
            _selectLayer.frame = CGRectInset(frame, 2.f, 2.f);
            
        }else{
            [self _setHighlight:NO forTextLayer:[self textLayerAtIndex:_highlightIndex]];
        }
    }
    
    _highlightLayer.hidden = YES;
    _highlightIndex = NoSelectIndex;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_highlightIndex != NoSelectIndex  && _highlightIndex != _videoFilterInfo.selectValueIndex) {
        
        [self _setHighlight:NO forTextLayer:[self textLayerAtIndex:_highlightIndex]];
    }
    
    _highlightLayer.hidden = YES;
    _highlightIndex = NoSelectIndex;
}

@end


//----------------------------------------------------------


@implementation GP_VideoFilterInfoCell
{
    GP_VideoFilterInfoContentView * _videoFilterInfoContentView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _videoFilterInfoContentView = [[GP_VideoFilterInfoContentView alloc] init];
        [self.contentView addSubview:_videoFilterInfoContentView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _videoFilterInfoContentView.frame = CGRectInset(self.contentView.frame, 5.f, 0.f);
}

- (void)updateWithVideoFilterInfo:(GP_VideoFilterInfo *)videoFilterInfo
{
    _videoFilterInfoContentView.videoFilterInfo = videoFilterInfo;
}
@end
