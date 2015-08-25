//
//  GP_ServiceRequest.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-26.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//---------------------------------------

#import <Foundation/Foundation.h>

//---------------------------------------

/**
 * 服务类型
 */
typedef NS_ENUM(int, ServiceRequestSerivceType) {
    
    /** 获取主页热门视频 */
    ServiceRequestSerivceTypeGetHomeHotVideos,
    
    /** 获取主页模块 */
    ServiceRequestSerivceTypeGetHomeMoudlePages,
    
    /** 用户登录 */
    ServiceRequestSerivceTypeUserLogin,
    
    /** 用户注册 */
    ServiceRequestSerivceTypeUserRegister,
    
    /** 获取视频详情 */
    ServiceRequestSerivceTypeGetVideoDetail,
    
    /** 获取视频URL */
    ServiceRequestSerivceTypeGetVideoURL,
    
    /** 获取你喜欢的视频 */
    ServiceRequestSerivceTypeGetYouLikeVideos,
    
    /** 获取频道 */
    ServiceRequestSerivceTypeGetChannels,
    
    /** 获取频道视频 */
    ServiceRequestSerivceTypeGetChannelVideos,
    
    /** 获取视频筛选信息 */
    ServiceRequestSerivceTypeGetVideoFilterInfo,
    
    /** 搜索视频 */
    ServiceRequestSerivceTypeSearchVideos,
    
    /** 收藏视频 */
    ServiceRequestSerivceTypeCollectVideo,
    
    /** 获取收藏的视频 */
    ServiceRequestSerivceTypeGetCollectVideos,
    
    /** 获取相关视频 */
    ServiceRequestSerivceTypeGetAboutVideos,
    
    /** 频道内搜索视频 */
    ServiceRequestSerivceTypeSearchVideosInChannel
    
};

//---------------------------------------

@class GP_ServiceRequest;

//---------------------------------------

@protocol  GP_ServiceRequestDelegate

/**
 * 请求服务成功
 * @param serviceRequest serviceRequest为服务请求对象
 * @param type           type为服务类型
 * @param data           data为得到的数据对象
 */
- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest
           serviceType:(ServiceRequestSerivceType)type
    didSuccessRequestWithData:(id)data;

/**
 * 请求服务成功失败
 * @param serviceRequest serviceRequest为服务请求对象
 * @param type           type为服务类型
 * @param error          error为失败的错误
 */
- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest
           serviceType:(ServiceRequestSerivceType)type
    didFailRequestWithError:(NSError *)error;

@end

/** 获取成功的block */
typedef void (^ServiceRequestSuccessBlock)(ServiceRequestSerivceType type, id data);

/** 获取失败的block */
typedef void (^ServiceRequestFailBlock)(ServiceRequestSerivceType type, NSError * error);


//---------------------------------------


@interface GP_ServiceRequest : NSObject

/**
 * 获取热门视频
 */
- (void)startGetHomeHotVideos;

/**
 * 获取主页模块视频
 */
- (void)startGetHomeMoudlePages;

/**
 * 开始用户登录服务
 */
- (void)startUserLoginServiceWithUserName:(NSString *)userName password:(NSString *)password;

/**
 * 开始用户注册服务
 */
- (void)startUserRegisterServiceWithUserName:(NSString *)userName password:(NSString *)password;

/**
 * 开始获取视频详情服务
 */
- (void)startGetVideoDetailServiceWithVideoID:(NSInteger)videoID;

/**
 * 开始获取视频URL服务
 */
- (void)startGetVideoURLServiceWithVideoID:(NSInteger)videoID;

/**
 * 开始分页获取你喜欢的视频
 */
- (void)startGetYouLikeVideosServiceWithCurrentPage:(NSInteger)page andPageSize:(NSInteger)pageSize;

/**
 * 开始分页获取频道
 */
- (void)startGetChannelsServiceWithCurrentPage:(NSInteger)page andPageSize:(NSInteger)pageSize;

/**
 * 开始分页获取频道视频
 */
- (void)startGetChannelVideosServiceWithID:(NSInteger)channelID
                                  sortType:(NSInteger)sortType
                               currentPage:(NSInteger)page
                                  pageSize:(NSInteger)pageSize;

/**
 * 开始分页获取频道视频
 * @param channelID  channelID为频道ID
 * @param filterInfo filterInfo未筛选信息，包含类型，年份，地区等等
 * @param page       page为当前页面
 * @param pageSize   pageSize为每页数目
 */
- (void)startGetChannelVideosServiceWithID:(NSInteger)channelID
                                filterInfo:(NSDictionary *)filterInfo
                                  sortType:(NSInteger)sortType
                               currentPage:(NSInteger)page
                                  pageSize:(NSInteger)pageSize;


//获取视频筛选信息
- (void)startGetVideoFilterInfo;


/**
 * 开始分页搜索视频
 * @param keyword    keyword为搜索的关键字
 * @param filterInfo filterInfo未筛选信息，包含类型，年份，地区等等
 * @param page       page为当前页面
 * @param pageSize   pageSize为每页数目
 */
- (void)startSearchVideosServiceWithKeyword:(NSString *)keyword
                                 filterInfo:(NSDictionary *)filterInfo
                                currentPage:(NSInteger)page
                                   pageSize:(NSInteger)pageSize;

/**
 * 开始分页搜索视频
 * @param keyword    keyword为搜索的关键字
 * @param filterInfo filterInfo未筛选信息，包含类型，年份，地区等等
 * @param sortType   sortType为排序方式
 * @param page       page为当前页面
 * @param pageSize   pageSize为每页数目
 */
- (void)startSearchVideosServiceWithKeyword:(NSString *)keyword
                                 filterInfo:(NSDictionary *)filterInfo
                                   sortType:(NSInteger)sortType
                                currentPage:(NSInteger)page
                                   pageSize:(NSInteger)pageSize;

/**
 * 开始分页搜索频道内视频
 * @param keyword    keyword为搜索的关键字
 * @param channelID  channelID为频道ID
 * @param page       page为当前页面
 * @param pageSize   pageSize为每页数目
 */
- (void)startSearchVideosInChannelServiceWithKeyword:(NSString *)keyword
                                           channelID:(NSInteger)channelID
                                         currentPage:(NSInteger)page
                                            pageSize:(NSInteger)pageSize;


//收藏视频
- (void)startCollectVideoWithVideoID:(NSInteger)videoID
                                collect:(BOOL)isCollect;

//获取收藏的视频
- (void)startGetCollectVideosWithCurrentPage:(NSInteger)page
                                    pageSize:(NSInteger)pageSize;


//获取相关视频
- (void)startGetAboutVideosWithVideoID:(NSInteger)videoID
                           currentPage:(NSInteger)page
                              pageSize:(NSInteger)pageSize;


/**
 * 取消服务
 */
- (void)cancleService;

//是否在请求
@property(nonatomic,readonly,getter = isRequesting ) BOOL requesting;

/**
 * 代理
 */
@property(nonatomic,weak) id<GP_ServiceRequestDelegate> delegate;

/**
 * 成功的block
 */
@property(nonatomic,copy) ServiceRequestSuccessBlock successBlock;

/**
 * 失败的block
 */
@property(nonatomic,copy) ServiceRequestFailBlock    failBlock;

@end
