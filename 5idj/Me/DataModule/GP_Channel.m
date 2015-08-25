//
//  GP_Channel.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-27.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_Channel.h"
#import "GP_Video.h"

//----------------------------------------------------------

@implementation GP_Channel

- (id)initWithInfoDic:(NSDictionary *)info
{
    self = [super initWithID:[info[GP_GP_CHANNEL_ID] integerValue]
                       title:info[GP_GP_CHANNEL_NAME]
                    imageURL:info[GP_GP_CHANNEL_IMAGEURL]];

    return self;
}


@end
