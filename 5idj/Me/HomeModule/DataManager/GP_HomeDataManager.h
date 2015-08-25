//
//  GP_HomeDataManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//-------------------------------------------------

#import <Foundation/Foundation.h>

//-------------------------------------------------

@class GP_HomeDataManager;

//-------------------------------------------------

@protocol GP_HomeDataManagerDelegate

//获取数据成功
- (void)homeDataManager:(GP_HomeDataManager *)manager
        getHomeDataSuccessWithVideos:(NSArray *)videos
                          andModules:(NSArray *)modules;

//获取数据失败
- (void)homeDataManager:(GP_HomeDataManager *)manager getHomeDataFailWithError:(NSError *)error;

@end


//-------------------------------------------------

@interface GP_HomeDataManager : NSObject

//开始获取主页数据
- (void)startGetHomeData;

//取消获取主页数据
- (void)cancleGetHomeData;

//代理
@property(nonatomic, weak) id<GP_HomeDataManagerDelegate> delegate;

//是否正在获取数去
@property(nonatomic,readonly,getter = isGettingHomeData) BOOL gettingHomeData;

@end
