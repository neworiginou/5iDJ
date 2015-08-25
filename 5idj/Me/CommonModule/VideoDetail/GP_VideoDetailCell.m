//
//  GP_VideoDetailCell.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoDetailCell.h"
#import "GP_ImageAndTitleContentView.h"

//----------------------------------------------------------

@implementation GP_VideoDetailCell
{
    UIImageView  * _imageView;
    UILabel      * _titleLabel;
    UILabel      * _updateTimeLabel;
    UILabel      * _timeLabel;
    UILabel      * _playTimesLabel;
}

+ (CGFloat)cellHeight
{
    return [GP_ImageAndTitleContentView imageViewSize].height + 20.f;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.tintColorAlpha  = .7f;
        self.showSeparatorLine = YES;
        
        CGSize imageViewSize = [GP_ImageAndTitleContentView imageViewSize];
        
        //image
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 10.f, imageViewSize.width, imageViewSize.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_imageView];
        
        
        CGFloat scale     = [GP_ImageAndTitleContentView scaleFactor];
        CGFloat lineSpace = scale * 5.f;
        CGFloat xOffset   = CGRectGetMaxX(_imageView.frame) + 5.f;
        CGFloat width     = screenSize().width - xOffset;
        
        //title
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 10.f + lineSpace, width, scale * 20.f)];
        _titleLabel.font = [UIFont systemFontOfSize:scale * 15.f];
        _titleLabel.textColor = defaultTitleTextColor;
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
        
        CGFloat startY = CGRectGetMaxY(_titleLabel.frame) + lineSpace;

   
#define InitLabel(_name)                                                                         \
{                                                                                                \
    _name = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, startY, width, scale * 15.f)];    \
    _name.font = [UIFont systemFontOfSize:scale * 12.f];                                         \
    _name.textColor = defaultBodyTextColor;                                                      \
    _name.highlightedTextColor = [UIColor whiteColor];                                           \
    [self.contentView addSubview:_name];                                                         \
    startY = CGRectGetMaxY(_name.frame) + lineSpace;                                             \
}
        
        InitLabel(_updateTimeLabel);
        InitLabel(_timeLabel);
        InitLabel(_playTimesLabel);
        
        self.highlightedObjects = @[_titleLabel,_playTimesLabel,_updateTimeLabel,_timeLabel];

    }
    
    return self;
}

- (void)dealloc
{
    [_imageView cancleLoadURLImage:YES];
}

- (void)updateWithVideo:(GP_Video *)video
{
    //设置信息
    _titleLabel.text      = video.title;
    _playTimesLabel.text  = [NSString stringWithFormat:@"播放：%@",[video hitsString]];
    _updateTimeLabel.text = [NSString stringWithFormat:@"更新：%@",video.updateTime];
    _timeLabel.text       = [NSString stringWithFormat:@"时长：%@",
                             moviePlayDurationFormatterString(video.duration,YES)];
    //设置图片
    [_imageView setImageWithURL:video.imageURL
               placeholderImage:defaultPlaceholderImage
               progressViewMode:ImageLoadProgressViewModeNone
                loadFailPolicy:ImageLoadFailPolicyAllPolicy
                        success:defaultImageLoadSuccessBlock
                        failure:nil];

}

@end
