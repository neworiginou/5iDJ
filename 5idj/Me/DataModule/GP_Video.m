//
//  GP_HotFoucsVideo.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-25.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_Video.h"

//----------------------------------------------------------

@implementation GP_Video

//@synthesize description = _description;

- (id)initWithInfoDic:(NSDictionary *)info
{
    self = [super initWithID:[info[GP_GP_VIDEO_ID] integerValue]
                       title:info[GP_GP_VIDEO_NAME]
                    imageURL:info[GP_GP_VIDEO_IMAGEURL]
                       brief:info[GP_GP_VIDEO_BRIEF]
            ];
    
    if (self) {
        
        id hits      = info[GP_GP_VIDEO_HITS];
        _hits        = ([hits respondsToSelector:@selector(integerValue)]) ? [hits integerValue] : 0;
        _updateTime  = info[GP_GP_VIDEO_UPDATETIME];
        _duration    = [info[GP_GP_VIDEO_DURATION] integerValue];
    }
    
    return self;
}
- (void)updateDeatilInfo:(NSDictionary *)infoDic
{
    _updateTime     = infoDic[GP_GP_VIDEO_UPDATETIME];
    _descriptionStr = infoDic[GP_GP_VIDEO_DESCRIPTION];
    _duration       = [infoDic[GP_GP_VIDEO_DURATION] integerValue];
    _appraise       = [infoDic[GP_GP_VIDEO_APPRAISE] floatValue];
    _year           = infoDic[GP_GP_VIDEO_YEAR];
    _type           = infoDic[GP_GP_VIDEO_TYPE];
    id hits         = infoDic[GP_GP_VIDEO_HITS];
    _hits           = ([hits respondsToSelector:@selector(integerValue)]) ? [hits integerValue] : 0;
    
}

- (NSString *)description
{
    return _descriptionStr;
}

- (BOOL)hadUpdateDeatilInfo
{
    return _descriptionStr != nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _hits = [aDecoder decodeIntegerForKey:@"_hits"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeInteger:_hits forKey:@"_hits"];
    
}

- (NSString *)hitsString
{
    if (_hits < 10000) {
        return [NSString stringWithFormat:@"%li",(long)_hits];
    }else if (_hits < 10000000){
        return [NSString stringWithFormat:@"%.01f万",(float)_hits / 10000];
    }else if (_hits < 10000000){
        return [NSString stringWithFormat:@"%li百万",(long)_hits / 1000000];
    }else if (_hits < 100000000){
        return [NSString stringWithFormat:@"%li千万",(long)_hits / 10000000];
    }else{
        return [NSString stringWithFormat:@"%li亿",  (long)_hits / 100000000];
    }
}


@end
