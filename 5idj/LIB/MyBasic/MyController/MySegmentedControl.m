//
//  MySegmentedControl.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-9-21.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MySegmentedControl.h"
#import "MacroDef.h"
#import "UIImage+Tint.h"

//----------------------------------------------------------

@interface MySegmentedControl ()

@property(nonatomic,strong,readonly) CALayer * selectedIndicatorLine;

//更新指示线
- (void)_updateSelectedIndicatorLine;

//高亮显示的index
@property(nonatomic) NSUInteger highlightedSectionIndex;


//KVO
- (void)_registerKVO;
- (void)_unregisterKVO;
- (NSArray *)_observableKeypaths;
- (void)_updateUIForKeypath:(NSString *)keyPath;

@end

//----------------------------------------------------------


@implementation MySegmentedControl

@synthesize selectedIndicatorLine = _selectedIndicatorLine;

#pragma mark - life circle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _commonInit];
    }
    
    return self;
}

- (id)initWithSectionTitles:(NSArray *)titles
{
    return [self initWithSectionTitles:titles images:nil selectedImages:nil];
}

- (id)initWithSectionImages:(NSArray *)images selectedImages:(NSArray *)selectedImages
{
    return [self initWithSectionTitles:nil images:images selectedImages:selectedImages];
}

- (id)initWithSectionTitles:(NSArray *)titles
                     images:(NSArray *)images
             selectedImages:(NSArray *)selectedImages
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        
        _sectionTitles = titles;
        _sectionImages = images;
        _sectionSelectedImages = selectedImages;
        
        [self _commonInit];
        [self sizeToFit];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self _commonInit];
}


- (void)_commonInit
{
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
    
    _showSeparatorLine = YES;
    _drawGradientSeparatorLine = YES;
    _autoAdjustImage   = YES;
    _selectedIndicatorLineWidth = 2.f;
    _separatorLineWidth = PiexlToPoint(1.f);
    _titleImageMargin = 2.f;
    _selectedIndicatorLineInset = UIEdgeInsetsZero;
    _selectedIndicatorLineInsetScale = UIEdgeInsetsZero;
    _separatorLineInset = UIEdgeInsetsZero;
    _separatorLineInsetScale = UIEdgeInsetsMake(.2f, 0.f, .2f, 0.f);
    _selectedSectionIndex = NoSelectedSectionIndex;
    _highlightedSectionIndex = NoSelectedSectionIndex;
    
    self.showSelectedIndicatorLine = YES;
    
    [self _registerKVO];
}

- (void)dealloc
{
    [self _unregisterKVO];
}

#pragma mark - KVO

- (NSArray *)_observableKeypaths
{
    return @[
             @"textFont",
             @"textColor",
             @"highlightedTextColor",
             @"selectedTextColor",
             @"showSeparatorLine",
             @"separatorLineWidth",
             @"drawGradientSeparatorLine",
             @"separatorLineColor",
             @"separatorLineInset",
             @"separatorLineInsetScale",
             @"selectedIndicatorLineColor",
             @"selectedIndicatorLineWidth",
             @"selectedIndicatorLineInset",
             @"selectedIndicatorLineInsetScale",
             @"sectionTitles",
             @"sectionImages",
             @"sectionSelectedImages",
             @"autoAdjustImage",
             @"titleImageMargin"
             ];
}

- (void)_registerKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)_unregisterKVO
{
    for (NSString * keyPath in [self _observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([NSThread isMainThread]) {
        [self _updateUIForKeypath:keyPath];
    }else{
        [self performSelectorOnMainThread:@selector(_updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    }
}

- (void)_updateUIForKeypath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"selectedIndicatorLineColor"]) {
        if (_selectedIndicatorLine) {
            _selectedIndicatorLine.backgroundColor = self.selectedIndicatorLineColor.CGColor;
        }
        return;
    }else if([keyPath isEqualToString:@"selectedIndicatorLineWidth"]  ||
             [keyPath isEqualToString:@"selectedIndicatorLineInset"] ||
             [keyPath isEqualToString:@"selectedIndicatorLineInsetScale"]){
        [self _updateSelectedIndicatorLine];
        return;
    }else if ([keyPath isEqualToString:@"sectionTitles"] ||
              [keyPath isEqualToString:@"sectionImages"] ||
              [keyPath isEqualToString:@"sectionSelectedImages"]){
        _selectedSectionIndex    = NoSelectedSectionIndex;
        _highlightedSectionIndex = NoSelectedSectionIndex;
        [self _updateSelectedIndicatorLine];
    }else if ([keyPath isEqualToString:@"highlightedTextColor"]){
        if (_highlightedSectionIndex == NoSelectedSectionIndex) {
            return;
        }
    }
    
    [self setNeedsDisplay];
}

#pragma mark - UI

- (UIFont *)textFont
{
    return _textFont ?: [UIFont systemFontOfSize:17.f];
}

- (UIColor *)textColor
{
    return _textColor ?: [UIColor blackColor];
}

- (UIColor *)separatorLineColor
{
    return _separatorLineColor ?: [UIColor blackColor];
}

- (UIColor *)selectedIndicatorLineColor
{
    return _selectedIndicatorLineColor ?: self.tintColor;
}

- (UIColor *)selectedTextColor
{
    return _selectedTextColor ?: self.tintColor;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    if (!_selectedIndicatorLineColor && _selectedIndicatorLine) {
        _selectedIndicatorLine.backgroundColor = self.selectedIndicatorLineColor.CGColor;
    }
    
    if (!_selectedTextColor) {
        [self setNeedsDisplay];
    }
}

- (CALayer *)selectedIndicatorLine
{
    if (!_selectedIndicatorLine) {
        _selectedIndicatorLine = [CALayer layer];
        _selectedIndicatorLine.actions = @{
                                           @"bounds":[NSNull null],
                                           @"position":[NSNull null],
                                           @"backgroundColor":[NSNull null]
                                           };
        _selectedIndicatorLine.backgroundColor = self.selectedIndicatorLineColor.CGColor;
    }
    
    return _selectedIndicatorLine;
}

- (void)setShowSelectedIndicatorLine:(BOOL)showSelectedIndicatorLine
{
    if (_showSelectedIndicatorLine != showSelectedIndicatorLine) {
        
        [_selectedIndicatorLine removeFromSuperlayer];
        
        _showSelectedIndicatorLine = showSelectedIndicatorLine;
        
        if (_showSelectedIndicatorLine) {
            [self.layer addSublayer:self.selectedIndicatorLine];
            
            [self _updateSelectedIndicatorLine];
        }
    }
}

- (void)_updateSelectedIndicatorLine
{
    if (self.showSelectedIndicatorLine) {
        
        if (self.selectedSectionIndex == NoSelectedSectionIndex) {
            self.selectedIndicatorLine.frame = CGRectZero;
        }else{
            CGRect selectedSectionRect = [self rectForSectionAtIndex:self.selectedSectionIndex];
            
            CGRect selectedIndicatorLineFrame;
            selectedIndicatorLineFrame.origin.x = CGRectGetMinX(selectedSectionRect) + CGRectGetWidth(selectedSectionRect) * self.selectedIndicatorLineInsetScale.left + self.selectedIndicatorLineInset.left;
            selectedIndicatorLineFrame.origin.y = CGRectGetHeight(selectedSectionRect) - self.selectedIndicatorLineWidth;
            selectedIndicatorLineFrame.size.height = 2.f;
            selectedIndicatorLineFrame.size.width  = CGRectGetWidth(selectedSectionRect) * (1 - self.selectedIndicatorLineInsetScale.left - self.selectedIndicatorLineInsetScale.right) - self.selectedIndicatorLineInset.left - self.selectedIndicatorLineInset.right;
            
            //宽度小于0
            if (selectedIndicatorLineFrame.size.width < 0) {
                selectedIndicatorLineFrame = CGRectZero;
            }
            
            self.selectedIndicatorLine.frame = selectedIndicatorLineFrame;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //更新
    [self _updateSelectedIndicatorLine];
}

#define SectionWidth(_sectionCount) ((_sectionCount) ? CGRectGetWidth(self.bounds) / (_sectionCount) : 0.f)

- (CGRect)rectForSectionAtIndex:(NSUInteger)index
{
    NSUInteger sectionCount = self.sectionCount;
    checkIndexAtRange(index, NSMakeRange(0, sectionCount));
    
    CGFloat sectionWidth = SectionWidth(sectionCount);
    return CGRectMake(index * sectionWidth, 0.f, sectionWidth, CGRectGetHeight(self.bounds));
}


- (CGSize)sizeThatFits:(CGSize)size
{
    //    CGSize intrinsicContentSize = [self intrinsicContentSize];
    //    return CGSizeMake(MAX(intrinsicContentSize.width, size.width), MAX(size.height, intrinsicContentSize.height));
    
    return [self intrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    CGSize maxSectionSize = CGSizeZero;
    NSUInteger sectionCount = self.sectionCount;
    
    for (NSUInteger index = 0; index < sectionCount; index ++) {
        CGSize sectionSize = [self _sectionSizeAtSection:index];
        //获取最大的一个section尺寸
        maxSectionSize.width = MAX(maxSectionSize.width, sectionSize.width);
        maxSectionSize.height = MAX(maxSectionSize.height, sectionSize.height);
    }
    
    return CGSizeMake(maxSectionSize.width * sectionCount * 1.25f, maxSectionSize.height);
}

- (CGSize)_titleSizeAtSection:(NSUInteger)section
{
    return TEXTSIZE([self titleForIndex:section], self.textFont)
}

- (CGSize)_imageSizeAtSection:(NSUInteger)section
{
    //获取图像
    UIImage * image = nil;
    if (section == self.selectedSectionIndex) {
        image = [self selectedImageForIndex:section];
        if (!image) image = [self imageForIndex:section];
    }else{
        image = [self imageForIndex:section];
    }
    
    //图像大小
    return image ? image.size : CGSizeZero;
}

- (CGSize)_sectionSizeAtSection:(NSUInteger)section
{
    CGSize titleSize = [self _titleSizeAtSection:section];
    CGSize imageSize = [self _imageSizeAtSection:section];
    
    if (titleSize.width && imageSize.width) {
        titleSize.width += self.titleImageMargin;
    }
    
    return CGSizeMake(titleSize.width + imageSize.width, MAX(titleSize.height, imageSize.height));
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    //填充背景色
    [self.backgroundColor setFill];
    UIRectFill(rect);
    
    NSUInteger sectionCount = self.sectionCount;
    CGFloat    sectionWidth = sectionCount ? CGRectGetWidth(rect) / sectionCount : 0.f;
    for (NSUInteger index = 0; index < sectionCount; index ++) {
        
        CGRect titleRect = CGRectZero,imageRect = CGRectZero;
        
        //文字大小
        CGSize titleSize = [self _titleSizeAtSection:index];
        
        //图像大小
        CGSize imageSize = [self _imageSizeAtSection:index];
        if (imageSize.height > CGRectGetHeight(rect)) {
            imageSize.width *= (CGRectGetHeight(rect) / imageSize.height);
        }
        
        //改变大小
        if (sectionWidth < imageSize.width) {
            imageSize.height *= (sectionWidth / imageSize.width);
            imageSize.width  = sectionWidth;
            titleSize = CGSizeZero;
        }else if (sectionWidth < imageSize.width + titleSize.width){
            titleSize.width = sectionWidth - imageSize.width;
        }
        
        //设置范围
        CGFloat offset = (sectionWidth - imageSize.width - titleSize.width) * 0.5f;
        
        imageRect.origin.x = offset + sectionWidth * index;
        imageRect.origin.y = (CGRectGetHeight(rect) - imageSize.height) * 0.5f;
        imageRect.size     = imageSize;
        
        titleRect.origin.x = CGRectGetMaxX(imageRect);
        titleRect.origin.y = (CGRectGetHeight(rect) - titleSize.height) * 0.5f;
        titleRect.size     = titleSize;
        
        if (CGRectGetWidth(titleRect) && CGRectGetWidth(imageRect)) {
            imageRect = CGRectOffset(imageRect, - self.titleImageMargin * 0.5f, 0.f);
            titleRect = CGRectOffset(titleRect,   self.titleImageMargin * 0.5f, 0.f);
        }
        
        //绘制标题
        [self _drawTitleForIndex:index atRect:titleRect];
        
        //绘制图像
        [self _drawImageForIndex:index atRect:imageRect];
        
        //绘制分割线
        if (self.showSeparatorLine && index != 0) {
            
            CGFloat startY = CGRectGetHeight(rect) * self.separatorLineInsetScale.top + self.separatorLineInset.top;
            CGFloat length = CGRectGetHeight(rect) * (1.f - self.separatorLineInsetScale.top - self.separatorLineInsetScale.bottom) - self.separatorLineInset.top - self.separatorLineInset.bottom;
            
            if (length > 0) {
                
                //绘制线
                CGRect lineRect = CGRectMake(sectionWidth * index, startY, self.separatorLineWidth, length);
                
                [self _drawSeparatorLineAtRect:lineRect];
            }
        }
    }
}

- (void)_drawTitleForIndex:(NSUInteger)index atRect:(CGRect)rect
{
    
    NSString * title = [self titleForIndex:index];
    
    if (title.length > 0) {
        
        UIColor * textColor = nil;
        
        if (index == self.selectedSectionIndex) {
            textColor = self.selectedTextColor;
        }else if (index == _highlightedSectionIndex){
            textColor = self.highlightedTextColor ?: [self.selectedTextColor colorWithAlphaComponent:0.5f];
        }else{
            textColor = self.textColor;
        }
        
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithString:title
                                                                       attributes:@{
                                                                                    NSFontAttributeName : self.textFont,
                                                                                    NSForegroundColorAttributeName :textColor
                                                                                    }];
        
        [attrStr drawInRect:rect];
        
    }
}

- (void)_drawImageForIndex:(NSUInteger)index atRect:(CGRect)rect
{
    if (index == self.selectedSectionIndex) {
        
        UIImage * image = [self selectedImageForIndex:index];
        
        //绘制调整后的图片
        if (!image) {
            if (self.autoAdjustImage) {
                [self _drawImage:[self imageForIndex:index] withTintColor:self.selectedTextColor atRect:rect];
            }else{
                [[self imageForIndex:index] drawInRect:rect];
            }
            
        }else{
            [image drawInRect:rect];
        }
        
    }else if (index == _highlightedSectionIndex && self.autoAdjustImage){
        //绘制调整后的图片
        [self _drawImage:[self imageForIndex:index]
           withTintColor:self.highlightedTextColor ?: [self.selectedTextColor colorWithAlphaComponent:0.5f]
                  atRect:rect];
    }else{
        [[self imageForIndex:index] drawInRect:rect];
    }
}

- (void)_drawImage:(UIImage *)image withTintColor:(UIColor *)tintColor atRect:(CGRect)rect
{
    
    [[image imageWithTintColor:tintColor] drawInRect:rect];
    
    //    if (image != nil) {
    //
    //        CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //
    //        CGContextSaveGState(currentContext);
    //
    //        CGContextTranslateCTM(currentContext, 0, CGRectGetMinY(rect));
    //        CGContextScaleCTM(currentContext, 1.f, -1.f);
    //        CGContextTranslateCTM(currentContext, 0, -CGRectGetMaxY(rect));
    //
    //        CGContextClipToMask(currentContext, rect, image.CGImage);
    //
    ////        UIColor
    //
    //        [self.backgroundColor setFill];
    //        UIRectFill(rect);
    //
    //        [tintColor setFill];
    //        UIRectFill(rect);
    //
    //        CGContextRestoreGState(currentContext);
    //
    //
    //    }
}


- (void)_drawSeparatorLineAtRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 保持住现在的context
    CGContextSaveGState(context);
    
    if (self.drawGradientSeparatorLine) {
        
        CGContextClipToRect(context, rect);// 截取对应的context
        
        CGColorRef startColor  = [self.separatorLineColor colorWithAlphaComponent:0.1f].CGColor;
        NSArray * cgColorArray = @[
                                   (__bridge id)startColor,
                                   (__bridge id)self.separatorLineColor.CGColor,
                                   (__bridge id)startColor
                                   ];
        
        //绘制渐变线
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)cgColorArray,NULL);
        CGColorSpaceRelease(rgb);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGGradientRelease(gradient);
        CGContextFillPath(context);
        
    }else{
        //绘制线
        CGContextSetStrokeColorWithColor(context, self.separatorLineColor.CGColor);
        CGContextSetLineWidth(context, CGRectGetWidth(rect));
        CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
        CGContextStrokePath(context);
    }
    
    // 恢复到之前的context
    CGContextRestoreGState(context);
}
- (void)_drawGradientLineAtRect:(CGRect)clipRect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);// 保持住现在的context
    CGContextClipToRect(context, clipRect);// 截取对应的context
    
    
    CGColorRef startColor  = [UIColor clearColor].CGColor;
    NSArray * cgColorArray = @[
                               (__bridge id)startColor,
                               (__bridge id)self.separatorLineColor.CGColor,
                               (__bridge id)startColor
                               ];
    
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    //    const CGFloat locations[] = {0.f,0.5f,1.f};
    
    CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)cgColorArray,NULL);
    CGColorSpaceRelease(rgb);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(clipRect), CGRectGetMinY(clipRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(clipRect), CGRectGetMaxY(clipRect));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    
    CGContextFillPath(context);
    CGContextRestoreGState(context);// 恢复到之前的context
}



#pragma mark - Selected Index

- (NSUInteger)sectionCount
{
    NSUInteger titlesCount = self.sectionTitles.count;
    NSUInteger imagesCount = self.sectionImages.count;
    
    return MAX(titlesCount, imagesCount);
}

- (NSString *)titleForIndex:(NSUInteger)index
{
    NSUInteger sectionCount = self.sectionCount;
    
    //核对范围
    checkIndexAtRange(index, NSMakeRange(0, sectionCount));
    
    if (index >= self.sectionTitles.count){
        return nil;
    }else{
        return self.sectionTitles[index];
    }
}

- (UIImage *)imageForIndex:(NSUInteger)index
{
    NSUInteger sectionCount = self.sectionCount;
    
    //核对范围
    checkIndexAtRange(index, NSMakeRange(0, sectionCount));
    
    if (index >= self.sectionImages.count){
        return nil;
    }else{
        return self.sectionImages[index];
    }
}

- (UIImage *)selectedImageForIndex:(NSUInteger)index
{
    NSUInteger sectionCount = self.sectionCount;
    
    //核对范围
    checkIndexAtRange(index, NSMakeRange(0, sectionCount));
    
    if (index >= self.sectionImages.count || index >= self.sectionSelectedImages.count){
        return nil;
    }else{
        return self.sectionSelectedImages[index];
    }
}

- (void)setSelectedSectionIndex:(NSUInteger)selectedSectionIndex
{
    [self setSelectedSectionIndex:selectedSectionIndex animated:NO];
}

- (void)setSelectedSectionIndex:(NSUInteger)selectedSectionIndex animated:(BOOL)animated
{
    NSUInteger sectionCount = self.sectionCount;
    
    //核对范围
    checkIndexAtRange(selectedSectionIndex, NSMakeRange(0, sectionCount));
    
    [self _setSelectedSectionIndex:selectedSectionIndex animated:animated notify:NO];
}

- (void)_setSelectedSectionIndex:(NSUInteger)selectedSectionIndex animated:(BOOL)animated notify:(BOOL)notify
{
    if (_selectedSectionIndex != selectedSectionIndex) {
        
        _selectedSectionIndex = selectedSectionIndex;
        
        
        if (animated) {
            
            CGPoint fromPosition = self.selectedIndicatorLine.position;
            [self _updateSelectedIndicatorLine];
            
            CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
            animation.duration  = 0.3f;
            animation.fromValue = [NSValue valueWithCGPoint:fromPosition];
            animation.toValue   = [NSValue valueWithCGPoint:self.selectedIndicatorLine.position];
            [self.selectedIndicatorLine addAnimation:animation forKey:@"animation"];
            
        }else{
            [self _updateSelectedIndicatorLine];
        }
        
        
        [self setNeedsDisplay];
        
        if (notify) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

#pragma mark - Touch

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (!enabled  && _highlightedSectionIndex != NoSelectedSectionIndex) {
        _highlightedSectionIndex = NoSelectedSectionIndex;
        [self setNeedsDisplay];
    }
}

- (NSUInteger)_sectionIndexForPoint:(CGPoint)point
{
    NSUInteger sectionIndex = NoSelectedSectionIndex;
    
    NSUInteger sectionCount = self.sectionCount;
    CGFloat sectionWidth = SectionWidth(sectionCount);
    
    if (sectionWidth) {
        
        NSInteger tmpIndex = floorf(point.x / sectionWidth);
        
        //在适合范围内
        if (0 <= tmpIndex && tmpIndex < sectionCount) {
            sectionIndex = tmpIndex;
        }
    }
    
    return sectionIndex;
    
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSUInteger sectionIndex = [self _sectionIndexForPoint:[touch locationInView:self]];
    
    if (_highlightedSectionIndex != sectionIndex && sectionIndex != self.selectedSectionIndex) {
        _highlightedSectionIndex = sectionIndex;
        
        [self setNeedsDisplay];
        
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_highlightedSectionIndex != NoSelectedSectionIndex) {
        
        CGRect highlightedSectionRect = [self rectForSectionAtIndex:_highlightedSectionIndex];
        
        if (CGRectContainsPoint(highlightedSectionRect, [touch locationInView:self])) {
            return YES;
        }else{//移出
            
            _highlightedSectionIndex = NoSelectedSectionIndex;
            [self setNeedsDisplay];
        }
    }
    
    return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_highlightedSectionIndex != NoSelectedSectionIndex) {
        [self _setSelectedSectionIndex:_highlightedSectionIndex animated:YES notify:YES];
        _highlightedSectionIndex = NoSelectedSectionIndex;
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    if (_highlightedSectionIndex != NoSelectedSectionIndex) {
        _highlightedSectionIndex = NoSelectedSectionIndex;
        
        [self setNeedsDisplay];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

@end
