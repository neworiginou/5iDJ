//
//  GP_Channel.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-27.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicTitleAndImage.h"

//----------------------------------------------------------

@interface GP_Channel : GP_BasicTitleAndImage

//@property(nonatomic,strong) NSArray * videos;

@end

//----------------------------------------------------------

//选择协议定义
SelectProtocolDefine(Channel, GP_Channel)

#define SafeSendSelectChannelMsg(_delegate,_channel) \
SafeSendSelectMsg(_delegate,_channel,Channel)
