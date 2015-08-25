//
//  GP_HotFoucsVideo.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-25.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "GP_BasicTitleAndImage.h"

//----------------------------------------------------------

@interface GP_Video : GP_BasicTitleAndImage

//视频类型
@property(nonatomic,strong,readonly) NSString   *   type;

//视频描述
@property(nonatomic,strong,readonly) NSString   *   descriptionStr;

//视频年份
@property(nonatomic,strong,readonly) NSString   *   year;

//更新时间
@property(nonatomic,strong,readonly) NSString   *   updateTime;

//点击量，播放次数
@property(nonatomic,readonly)        NSInteger      hits;

//视频时长
@property(nonatomic,readonly)        NSTimeInterval duration;

//视频评分
@property(nonatomic,readonly)        float          appraise;

//更新详细信息
- (void)updateDeatilInfo:(NSDictionary *)infoDic;

//标记是否更新了详情信息
@property(nonatomic,readonly)         BOOL          hadUpdateDeatilInfo;


- (NSString *)hitsString;

@end

//----------------------------------------------------------


//选择协议定义
SelectProtocolDefine(Video, GP_Video)

#define  SafeSendSelectVideoMsg(_delegate,_video)    \
SafeSendSelectMsg(_delegate,_video,Video)

