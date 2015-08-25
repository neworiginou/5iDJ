//
//  GP_HomeVideosModule.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-25.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_HomeVideosModule.h"
#import "GP_Video.h"

//----------------------------------------------------------

@implementation GP_HomeVideosModule

- (id)initWithInfoDic:(NSDictionary *)info
{
    
    self = [super initWithID:[info[GP_GP_GET_HOMEMODULEPAGES_PAGE_ID] integerValue]
                       title:info[GP_GP_GET_HOMEMODULEPAGES_PAGE_NAME]];
    
    if (self) {
        _videos = [GP_Video dataArrayWithInfoArray:info[GP_GP_GET_HOMEMODULEPAGES_VIDOES]];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _videos = [aDecoder decodeObjectForKey:@"_videos"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_videos forKey:@"_videos"];
}



@end
