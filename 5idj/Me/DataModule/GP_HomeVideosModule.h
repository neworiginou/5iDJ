//
//  GP_HomeVideosModule.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-25.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicTitleAndImage.h"

//----------------------------------------------------------

@interface GP_HomeVideosModule : GP_BasicTitleAndImage

@property(nonatomic,strong) NSArray * videos;

@end

//----------------------------------------------------------

//选择协议定义
SelectProtocolDefine(HomeVideosModule, GP_HomeVideosModule)

#define  SafeSendSelectHomeVideosModuleMsg(_delegate,_videosModule)                 \
SafeSendSelectMsg(_delegate,_videosModule,HomeVideosModule)
