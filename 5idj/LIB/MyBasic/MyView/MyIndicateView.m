//
//  MyLoadingIndicateView.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-27.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyIndicateView.h"
#import "MacroDef.h"

//----------------------------------------------------------

@interface MyIndicateView ()

@property(nonatomic,strong,readonly) UIImageView  *imageView;

- (void)_init;
- (void)_setupLabels;
- (void)_updateIndicateView;

- (void)_registerForKVO;
- (void)_unregisterFromKVO;
- (NSArray *)_observableKeypaths;
- (void)_updateUIForKeypath:(NSString *)keyPath;

@end

//----------------------------------------------------------

@implementation MyIndicateView
{
    UIView * _contentView;
    UIView * _indicateView;
    
    UILabel * _titleLabel;
    UILabel * _detailLabel;
    
    BOOL      _ignoreFrameChange;
    
}

@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize imageView             = _imageView;


#pragma mark - life circle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        [self _init];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self _init];
}

- (void)_init
{
    self.backgroundColor  = [UIColor clearColor];
    self.style            = MyIndicateViewStyleActivityView;
    self.offsetValue      = CGPointZero;
    self.offsetScale      = CGPointZero;
    self.topMargin        = 10.f;
    self.bottomMargin     = 5.f;
    self.titleLabelFont   = [UIFont boldSystemFontOfSize:17.f];
    self.titleLabelColor  = [UIColor grayColor];
    self.detailLabelFont  = [UIFont systemFontOfSize:13.f];
    self.detailLabelColor = [UIColor lightGrayColor];
    
    //内容视图
    _contentView = [[UIView alloc] init];
    [self addSubview:_contentView];
    
    //标题视图
    [self _setupLabels];
    
    //标记视图
    [self _updateIndicateView];
    
    //注册KVO
    [self _registerForKVO];
    
}

- (void)dealloc
{
    [self _unregisterFromKVO];
}

- (void)_setupLabels
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.adjustsFontSizeToFitWidth = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = self.titleLabelFont;
    _titleLabel.textColor = self.titleLabelColor;
    [_contentView addSubview:_titleLabel];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.adjustsFontSizeToFitWidth = NO;
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.font = self.detailLabelFont;
    _detailLabel.textColor = self.detailLabelColor;
    _detailLabel.numberOfLines = NSIntegerMax;
    [_contentView addSubview:_detailLabel];
}


- (void)_updateIndicateView
{
    [_indicateView removeFromSuperview];
    
    switch (_style) {
        case MyIndicateViewStyleActivityView:
            _indicateView = self.activityIndicatorView;
            break;
            
        case MyIndicateViewStyleCustomView:
            _indicateView = self.customView;
            break;
            
        case MyIndicateViewStyleImageView:            
            _indicateView = self.imageView;
            break;
            
        default:
            _indicateView = nil;
            break;
    }
    
    [_contentView addSubview:_indicateView];
}

- (MyActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[MyActivityIndicatorView alloc] initWithStyle:MyActivityIndicatorViewStyleIndeterminate];
        _activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 50.f, 50.f);
        _activityIndicatorView.lineWidth = 1.5f;
        [_activityIndicatorView startAnimating];
        [_activityIndicatorView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return _activityIndicatorView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:self.image];
    }
    
    return _imageView;
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _ignoreFrameChange = YES;
    
    CGRect bounds = self.bounds;
    
    if (CGRectGetWidth(bounds) == 0 || CGRectGetHeight(bounds) == 0) {
        _contentView.frame = CGRectZero;
    }else{
        
        CGSize maxContentSize =CGSizeMake(
                                          CGRectGetWidth(bounds) *  (1.f - fabsf(self.offsetScale.x) - 2 *self.marginScale.width) -  fabsf(self.offsetValue.x),
                                          CGRectGetHeight(bounds) * (1.f - fabsf(self.offsetScale.y) - 2 *self.marginScale.height) - fabsf(self.offsetValue.y));
        maxContentSize.width  = ceil(maxContentSize.width);
        maxContentSize.height = ceil(maxContentSize.height);
        
        CGSize contentSize = CGSizeMake(maxContentSize.width, 0.f);
        
        //_indicateView
        if (_indicateView) {
            
            CGSize indicateViewSize = CGSizeZero;
            
            if (_style == MyIndicateViewStyleImageView) {
                indicateViewSize = self.image.size;
                
                if (indicateViewSize.width) {
                    
                    indicateViewSize.width  = MIN(indicateViewSize.width, contentSize.width);
                    indicateViewSize.height *= (indicateViewSize.width / self.image.size.width);
                    indicateViewSize.height = roundf(indicateViewSize.height);
                }
                
            }else{
                indicateViewSize = _indicateView.frame.size;
            }
            
            _indicateView.frame = CGRectMake((contentSize.width - indicateViewSize.width) * 0.5f, 0.f, indicateViewSize.width, indicateViewSize.height);
            
            contentSize.height += indicateViewSize.height;
        }
        
        
        CGSize titleLabelSize = TEXTSIZE(self.titleLabelText, self.titleLabelFont);
        titleLabelSize.height = ceilf(titleLabelSize.height);
        
        CGSize detailLabelSize = MULTILINE_TEXTSIZE(self.detailLabelText, self.detailLabelFont, CGSizeMake(contentSize.width, MAXFLOAT), _detailLabel.lineBreakMode);
        detailLabelSize.height = ceilf(detailLabelSize.height);

        //文字和指示视图高不为0有间隙
        if ((titleLabelSize.height || detailLabelSize.height) && contentSize.height) {
            contentSize.height += self.topMargin;
        }
        
        _titleLabel.frame = CGRectMake(0.f, contentSize.height, contentSize.width, titleLabelSize.height);
        contentSize.height += titleLabelSize.height;
        
        //加上间隙
        if (titleLabelSize.height && detailLabelSize.height) {
            contentSize.height += self.bottomMargin;
        }
        
        _detailLabel.frame = CGRectMake(0.f, contentSize.height, contentSize.width, detailLabelSize.height);
        contentSize.height += detailLabelSize.height;
        
        
        if (_style == MyIndicateViewStyleImageView && _indicateView && contentSize.height > maxContentSize.height) {
            
            CGFloat indicateViewHightInset = contentSize.height - maxContentSize.height;
            CGFloat indicateViewHight = CGRectGetHeight(_indicateView.frame);
            indicateViewHightInset = MIN(indicateViewHightInset, indicateViewHight);
            
            if (indicateViewHightInset > 0) {
                
                CGFloat indicateViewWidth = CGRectGetWidth(_indicateView.frame);
                
                indicateViewWidth *= ((indicateViewHight - indicateViewHightInset) / indicateViewHight);
                indicateViewWidth = roundf(indicateViewWidth);
                indicateViewHight  = indicateViewHight - indicateViewHightInset;
                
                _indicateView.frame = CGRectMake((contentSize.width - indicateViewWidth) * 0.5f, 0.f, indicateViewWidth,indicateViewHight);
                
                _titleLabel.frame = CGRectOffset(_titleLabel.frame, 0.f, - indicateViewHightInset);
                _detailLabel.frame = CGRectOffset(_detailLabel.frame, 0.f, - indicateViewHightInset);
                
                contentSize.height -= indicateViewHightInset;
            }
        }
        
        _contentView.bounds = CGRectMake(0.f, 0.f, contentSize.width, contentSize.height);
        _contentView.center = CGPointMake(CGRectGetMidX(bounds) * (1 + self.offsetScale.x) + self.offsetValue.x, CGRectGetMidY(bounds)* (1 + self.offsetScale.y) + self.offsetValue.y);
        
    }
    
    _ignoreFrameChange = NO;
}


#pragma mark - KVO

- (void)_registerForKVO
{
	for (NSString *keyPath in [self _observableKeypaths]) {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)_unregisterFromKVO
{
	for (NSString *keyPath in [self _observableKeypaths]) {
		[self removeObserver:self forKeyPath:keyPath];
	}
    
    [_activityIndicatorView removeObserver:self forKeyPath:@"frame"];
}

- (NSArray *)_observableKeypaths
{
	return @[
                @"style",
                @"offsetValue",
                @"offsetScale",
                @"marginScale",
                @"topMargin",
                @"bottomMargin",
                @"customView",
                @"titleLabelText",
                @"titleLabelFont",
                @"titleLabelColor",
                @"detailLabelText",
                @"detailLabelFont",
                @"detailLabelColor",
                @"progress",
                @"image"
            ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(_updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
	} else {
		[self _updateUIForKeypath:keyPath];
	}
}

- (void)_updateUIForKeypath:(NSString *)keyPath
{
	if ([keyPath isEqualToString:@"style"]) {
		[self _updateIndicateView];
	}else if ([keyPath isEqualToString:@"titleLabelText"]) {
		_titleLabel.text = self.titleLabelText;
	}else if ([keyPath isEqualToString:@"detailLabelText"]) {
		_detailLabel.text = self.detailLabelText;
	}else if ([keyPath isEqualToString:@"progress"]) {
		if ([_indicateView respondsToSelector:@selector(setProgress:)]) {
			[(id)_indicateView setProgress:self.progress];
		}
		return;
	}else if ([keyPath isEqualToString:@"image"]){
        
        if (_imageView) {
            
            _imageView.image = self.image;
            
            if (self.style != MyIndicateViewStyleImageView) {
                return;
            }
            
        }else{
            return;
        }
    }else if ([keyPath isEqualToString:@"customView"]){
        
        if (self.style == MyIndicateViewStyleCustomView) {
            [self _updateIndicateView];
        }else{
            return;
        }
    }else if ([keyPath isEqualToString:@"frame"]) {
        if (self.style != MyIndicateViewStyleActivityView || _ignoreFrameChange) {
            return;
        }
	}else if ([keyPath isEqualToString:@"offsetValue"] ||
              [keyPath isEqualToString:@"offsetScale"] ||
              [keyPath isEqualToString:@"topMargin"]   ||
              [keyPath isEqualToString:@"bottomMargin"]||
              [keyPath isEqualToString:@"marginScale"] ){
        //do nothing
    }else if ([keyPath isEqualToString:@"titleLabelFont"]) {
		_titleLabel.font = self.titleLabelFont;
	}else if ([keyPath isEqualToString:@"titleLabelColor"]) {
		_titleLabel.textColor = self.titleLabelColor;
        return;
	}else if ([keyPath isEqualToString:@"detailLabelFont"]) {
		_detailLabel.font = self.detailLabelFont;
	}else if ([keyPath isEqualToString:@"detailLabelColor"]) {
		_detailLabel.textColor = self.detailLabelColor;
        return;
	}
    
	[self setNeedsLayout];
}

@end
