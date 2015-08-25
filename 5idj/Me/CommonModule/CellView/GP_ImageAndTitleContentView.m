//
//  GP_BasicImageAndTitleView.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-2.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ImageAndTitleContentView.h"

//----------------------------------------------------------

@implementation GP_ImageAndTitleContentView
{
    UIImageView * _imageView;
    UILabel     * _titleLabel;
    UILabel     * _briefLabel;
    
    CALayer     * _shadowLayer;
}

+ (CGRect)boundsForType:(GP_ImageAndTitleContentViewType)type
{
     CGSize imageViewSize = [self imageViewSize];
    
    return CGRectMake(0.f, 0.f, imageViewSize.width + 4 * ShadowRadius, imageViewSize.height + (type == GP_ImageAndTitleContentViewTypeChannel ? 35.f : 40.f) + 4 * ShadowRadius);
}

+ (CGFloat)scaleFactor
{
    return ((screenSize().width - 18.f) / 2 - 4 * ShadowRadius) / 145.f;
}

+ (CGSize)imageViewSize
{
    CGSize imageViewSize;
    
    CGFloat scaleFactor = [self scaleFactor];
    
    imageViewSize.width  = scaleFactor * 145.f;
    imageViewSize.height = scaleFactor * 90.f;
    
    return imageViewSize;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithType:GP_ImageAndTitleContentViewTypeVideo];
}

- (id)initWithType:(GP_ImageAndTitleContentViewType)type
{
    self = [super initWithFrame:[GP_ImageAndTitleContentView boundsForType:type]];
    
    if (self) {
        
        _type = type;
        
        CGSize imageViewSize = [[self class] imageViewSize];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2 * ShadowRadius, 2 * ShadowRadius, imageViewSize.width, imageViewSize.height)];
        _imageView.contentMode   = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _shadowLayer = [CALayer layer];
        _shadowLayer.frame = _imageView.frame;
        _shadowLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [_shadowLayer setShadowPath:[[UIBezierPath bezierPathWithRect:_shadowLayer.bounds] CGPath]];
        [_shadowLayer setShadowOpacity:1.f];
        [_shadowLayer setShadowOffset:CGSizeZero];
        [_shadowLayer setShadowRadius:ShadowRadius];
        [self.layer insertSublayer:_shadowLayer below:_imageView.layer];

        if (_type == GP_ImageAndTitleContentViewTypeChannel) {
            
            //标题
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * ShadowRadius, CGRectGetMaxY(_imageView.frame), imageViewSize.width, 35.f)];
            _titleLabel.numberOfLines = 2;
            _titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
            _titleLabel.textColor = defaultTitleTextColor;
            [self addSubview:_titleLabel];
        }else{
            
            //标题
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * ShadowRadius, CGRectGetMaxY(_imageView.frame) + 2, imageViewSize.width, 20.f)];
            _titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
            _titleLabel.textColor = defaultTitleTextColor;
            [self addSubview:_titleLabel];
            
            //简介
            _briefLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * ShadowRadius,CGRectGetMaxY(_titleLabel.frame), imageViewSize.width, 15.f)];
            _briefLabel.font = [UIFont systemFontOfSize:11.f];
            _briefLabel.textColor = defaultBodyTextColor;
            [self addSubview:_briefLabel];
        }
        
    }
    
    return self;
}


- (void)dealloc
{
    [_imageView cancleLoadURLImage:YES];
}


- (void)setBasicTitleAndImage:(GP_BasicTitleAndImage *)basicTitleAndImage
{
    if (_basicTitleAndImage != basicTitleAndImage) {
        _basicTitleAndImage = basicTitleAndImage;
        
        _titleLabel.text = basicTitleAndImage.title;
        _briefLabel.text = basicTitleAndImage.brief;
        
        [_imageView setImageWithURL:basicTitleAndImage.imageURL
                   placeholderImage:defaultPlaceholderImage
                   progressViewMode:ImageLoadProgressViewModeNone
                     loadFailPolicy:ImageLoadFailPolicyAllPolicy
                            success:defaultImageLoadSuccessBlock
//         ^(UIImageView * imageView,UIImage * image){
//                                CATransition * animation = [CATransition animation];
//                                [animation setDuration:1.f];
//                                [animation setType:kCATransitionFade];
//                                [imageView.layer addAnimation:animation forKey:@"FadeAnimation"];
//                            }
                            failure:nil];
    }
}





- (void)setHighlighted:(BOOL)highlighted
{
    if (_highlighted != highlighted) {
        _highlighted = highlighted;

        [_shadowLayer setShadowOffset:!highlighted ? CGSizeZero : CGSizeMake(ShadowRadius , -ShadowRadius)];

    }
}

- (CGRect)imageViewFrame
{
    return _imageView.frame;
}



@end
