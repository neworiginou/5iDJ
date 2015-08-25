//
//  GP_ServiceRequest.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-26.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ServiceRequest.h"
#import "GP_HomeVideosModule.h"
#import "GP_VideoFilterInfo.h"
#import "GP_HTTPRequest.h"
#import "GP_Channel.h"
#import "GP_Video.h"

//----------------------------------------------------------

@interface GP_ServiceRequest()<GP_HTTPRequestDelegate>

- (void)_sendSuccessMsgWithData:(id)data;

@end

//----------------------------------------------------------

@implementation GP_ServiceRequest
{
    //请求
    GP_HTTPRequest           * _httpRequest;
    
    //类型
    ServiceRequestSerivceType  _type;
}

- (void)startGetHomeHotVideos
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetHomeHotVideos;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_HOMEHOTPAGES
                                                       path:nil
                                             queryArguments:@{
                                                GP_SP_GET_HOMEHOTPAGES_CURRENTPAGE : @0,
                                                GP_SP_GET_HOMEHOTPAGES_PAGESIZE    : @10
                                            }];
    
    _httpRequest.delegate = self;
    
    //开始请求
    [_httpRequest startRequest];
}

- (void)startGetHomeMoudlePages
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetHomeMoudlePages;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_HOMEMODULEPAGES
                                                       path:nil
                                             queryArguments:@{
                                                GP_SP_GET_HOMEMODULEPAGES_CURRENTPAGE : @0,
                                                GP_SP_GET_HOMEMODULEPAGES_PAGESIZE    : @10
                                            }];
    
    _httpRequest.delegate = self;
    
    //开始请求
    [_httpRequest startRequest];
}

- (void)startUserLoginServiceWithUserName:(NSString *)userName password:(NSString *)password
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeUserLogin;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_LOGIN
                                                       path:nil
                                              bodyArguments:@{
                                                GP_SP_LOGIN_USERNAME : userName ,
                                                GP_SP_LOGIN_PASSWORD : password
                                            }];
    
    _httpRequest.delegate = self;
    
    //开始请求
    [_httpRequest startRequest];
    
}

- (void)startUserRegisterServiceWithUserName:(NSString *)userName password:(NSString *)password
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeUserRegister;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_REGISTER
                                                       path:nil
                                              bodyArguments:@{
                                                GP_SP_REGISTER_USERNAME : userName ,
                                                GP_SP_REGISTER_PASSWORD : password
                                            }];
    
    _httpRequest.delegate = self;
    
    //开始请求
    [_httpRequest startRequest];

}

- (void)startGetVideoDetailServiceWithVideoID:(NSInteger)videoID
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetVideoDetail;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_VIDEO_DETAILS
                                                       path:nil
                                             queryArguments:@{
                                                GP_SP_GET_VIDEO_DETAILS_VIDEOID : @(videoID)
                                            }];
    
    _httpRequest.delegate = self;
    
    [_httpRequest startRequest];
}

- (void)startGetVideoURLServiceWithVideoID:(NSInteger)videoID
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetVideoURL;
    
    NSMutableDictionary * queryArguments = [NSMutableDictionary dictionaryWithObject:@(videoID)
                                                                              forKey:GP_SP_GET_VIDEO_URL_VIDEOID];
    
    if ([GP_UserManager currentUser]) {
        [queryArguments setObject:[GP_UserManager currentUser].token
                           forKey:GP_SP_GET_VIDEO_URL_TOKEN];
    }
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_VIDEO_URL
                                                       path:nil
                                             queryArguments:queryArguments];
    
    _httpRequest.delegate = self;
    
    [_httpRequest startRequest];
}

- (void)startGetYouLikeVideosServiceWithCurrentPage:(NSInteger)page andPageSize:(NSInteger)pageSize
{
    GP_User * currentUser = [GP_UserManager currentUser];
    
    if (!currentUser) {
        @throw [NSException exceptionWithName:@"方法调用错误" reason:@"该服务需要用户登录" userInfo:nil];
    }
    
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetYouLikeVideos;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_YOULIKE_VIDEOS
                                                       path:nil
                                             queryArguments:@{
                                                GP_SP_GET_YOULIKE_VIDEOS_TOKEN       : currentUser.token,
                                                GP_SP_GET_YOULIKE_VIDEOS_CURRENTPAGE : @(page),
                                                GP_SP_GET_YOULIKE_VIDEOS_PAGESIZE    : @(pageSize)
                                            }];
    
    _httpRequest.delegate =self;
    
    [_httpRequest startRequest];
}

- (void)startGetChannelsServiceWithCurrentPage:(NSInteger)page andPageSize:(NSInteger)pageSize
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetChannels;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_CHANNELS
                    path:nil queryArguments:@{
                            GP_SP_GET_CHANNELS_CURRENTPAGE : @(page),
                            GP_SP_GET_CHANNELS_PAGESIZE    : @(pageSize)
                    }];
    
    _httpRequest.delegate = self;
    
    [_httpRequest startRequest];
}

- (void)startGetChannelVideosServiceWithID:(NSInteger)channelID
                                  sortType:(NSInteger)sortType
                               currentPage:(NSInteger)page
                                  pageSize:(NSInteger)pageSize
{

    [self startGetChannelVideosServiceWithID:channelID
                                  filterInfo:nil
                                    sortType:sortType
                                 currentPage:page
                                    pageSize:pageSize];
}

- (void)startGetChannelVideosServiceWithID:(NSInteger)channelID
                                filterInfo:(NSDictionary *)filterInfo
                                  sortType:(NSInteger)sortType
                               currentPage:(NSInteger)page
                                  pageSize:(NSInteger)pageSize
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetChannelVideos;
    
    //查询信息
    NSMutableDictionary  * queryInfo = [NSMutableDictionary dictionaryWithCapacity:filterInfo.count + 3];
    [queryInfo addEntriesFromDictionary:filterInfo];
    [queryInfo setObject:@(sortType)  forKey:GP_SP_VIDEOS_SORTTYPE];
    [queryInfo setObject:@(channelID) forKey:GP_SP_GET_CHANNEL_VIDEOS_CHANNEL_ID];
    [queryInfo setObject:@(page)      forKey:GP_SP_GET_CHANNEL_VIDEOS_CURRENTPAGE];
    [queryInfo setObject:@(pageSize)  forKey:GP_SP_GET_CHANNEL_VIDEOS_PAGESIZE];
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_CHANNEL_VIDEOS
                                                       path:nil
                                             queryArguments:queryInfo];
    
    _httpRequest.delegate = self;
    
    [_httpRequest startRequest];
}

- (void)startGetVideoFilterInfo
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetVideoFilterInfo;
    
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_VIDEO_FILTER_INFO
                                                       path:nil
                                             queryArguments:nil];
    
    
    _httpRequest.delegate = self;
    
    [_httpRequest startRequest];
}

- (void)startSearchVideosServiceWithKeyword:(NSString *)keyword
                                 filterInfo:(NSDictionary *)filterInfo
                                currentPage:(NSInteger)page
                                   pageSize:(NSInteger)pageSize
{
    [self startSearchVideosServiceWithKeyword:keyword
                                   filterInfo:filterInfo
                                     sortType:0
                                  currentPage:page
                                     pageSize:pageSize];
}

- (void)startSearchVideosServiceWithKeyword:(NSString *)keyword
                                 filterInfo:(NSDictionary *)filterInfo
                                   sortType:(NSInteger)sortType
                                currentPage:(NSInteger)page
                                   pageSize:(NSInteger)pageSize
{
    if (keyword.length == 0) {
        @throw [NSException exceptionWithName:@"参数错误" reason:@"搜索的keyword不能为nil" userInfo:nil];
    }
    
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeSearchVideos;
    
    //查询信息
    NSMutableDictionary  * queryInfo = [NSMutableDictionary dictionaryWithCapacity:filterInfo.count + 4];
    [queryInfo addEntriesFromDictionary:filterInfo];
    [queryInfo setObject:@(sortType) forKey:GP_SP_VIDEOS_SORTTYPE];
    [queryInfo setObject:keyword     forKey:GP_SP_SEARCH_VIDEOS_KEYWORD];
    [queryInfo setObject:@(page)     forKey:GP_SP_SEARCH_VIDEOS_CURRENTPAGE];
    [queryInfo setObject:@(pageSize) forKey:GP_SP_SEARCH_VIDEOS_PAGESIZE];
    
    //开始请求
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_SEARCH_VIDEOS
                                                       path:nil
                                             queryArguments:queryInfo];
    
    _httpRequest.delegate = self;
    
    [_httpRequest startRequest];
}

- (void)startSearchVideosInChannelServiceWithKeyword:(NSString *)keyword
                                           channelID:(NSInteger)channelID
                                         currentPage:(NSInteger)page
                                            pageSize:(NSInteger)pageSize
{
    if (keyword.length == 0) {
        @throw [NSException exceptionWithName:@"参数错误" reason:@"搜索的keyword不能为nil" userInfo:nil];
    }
    
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeSearchVideosInChannel;
    
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_SEARCH_VIDEOS_IN_CHANNEL
                                                       path:nil
                                             queryArguments:@{
                                            GP_SP_SEARCH_VIDEOS_IN_CHANNEL_KEYWORD     : keyword,
                                            GP_SP_SEARCH_VIDEOS_IN_CHANNEL_CHANNEL_ID  : @(channelID),
                                            GP_SP_SEARCH_VIDEOS_IN_CHANNEL_CURRENTPAGE : @(page),
                                            GP_SP_SEARCH_VIDEOS_IN_CHANNEL_PAGESIZE    : @(pageSize)
                                                }];
    
    _httpRequest.delegate = self;
    
    [_httpRequest startRequest];
}


- (void)startCollectVideoWithVideoID:(NSInteger)videoID collect:(BOOL)isCollect
{
    GP_User * currentUser = [GP_UserManager currentUser];
    
    if (!currentUser) {
        @throw [NSException exceptionWithName:@"方法调用错误" reason:@"该服务需要用户登录" userInfo:nil];
    }
    
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeCollectVideo;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_COLLECT_VIDEO
                                                       path:nil
                                             queryArguments:@{
                                                GP_SP_COLLECT_VIDEO_TOKEN     : currentUser.token,
                                                GP_SP_COLLECT_VIDEO_VIDEOID   : @(videoID),
                                                GP_SP_COLLECT_VIDEO_ADDORMOVE : isCollect ? @1:@0
                                            }];
    
    
    _httpRequest.delegate = self;
    
    [_httpRequest startRequest];
    
}

- (void)startGetCollectVideosWithCurrentPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    GP_User * currentUser = [GP_UserManager currentUser];
    
    if (!currentUser) {
        @throw [NSException exceptionWithName:@"方法调用错误" reason:@"该服务需要用户登录" userInfo:nil];
    }
    
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetCollectVideos;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_COLLECT_VIDEOS
                                                       path:nil
                                             queryArguments:@{
                                                GP_SP_GET_COLLECT_VIDEOS_TOKEN       : currentUser.token,
                                                GP_SP_GET_COLLECT_VIDEOS_CURRENTPAGE : @(page),
                                                GP_SP_GET_COLLECT_VIDEOS_PAGESIZE    : @(pageSize)
                                            }];

    
    _httpRequest.delegate = self;
    
    [_httpRequest startRequest];
    
}

- (void)startGetAboutVideosWithVideoID:(NSInteger)videoID
                           currentPage:(NSInteger)page
                              pageSize:(NSInteger)pageSize;
{
    [self cancleService];
    
    _type = ServiceRequestSerivceTypeGetAboutVideos;
    
    _httpRequest = [[GP_HTTPRequest alloc] initWithAPIRoute:GP_API_ROUTE_GET_ABOUT_VIDEOS
                                                       path:nil
                                             queryArguments:@{
                                                GP_SP_GET_ABOUT_VIDEOS_VIDEO_ID    : @(videoID),
                                                GP_SP_GET_ABOUT_VIDEOS_CURRENTPAGE : @(page),
                                                GP_SP_GET_ABOUT_VIDEOS_PAGESIZE    : @(pageSize)
                                            }];
    
    _httpRequest.delegate  = self;
    
    [_httpRequest startRequest];
}


- (void)cancleService
{
    [_httpRequest cancleRequest];
    
    _httpRequest = nil;
}

- (BOOL)isRequesting
{
    return [_httpRequest isRequesting];
}

- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didFailedRequestWithError:(NSError *)error
{
    //block
    if (_failBlock) {
        _failBlock(_type,error);
    }
    
    id<GP_ServiceRequestDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(serviceRequest:serviceType:didFailRequestWithError:)){
        [delegate serviceRequest:self serviceType:_type didFailRequestWithError:error];
    }
}

- (void)httpRequest:(id<MyHTTPRequestProtocol>)netRequest didSuccessRequestWithDataObject:(id)dataObject
{
    switch (_type) {
        case ServiceRequestSerivceTypeGetVideoDetail:
        case ServiceRequestSerivceTypeUserRegister:
        case ServiceRequestSerivceTypeCollectVideo:
            
            [self _sendSuccessMsgWithData:dataObject];
            break;
            
        case ServiceRequestSerivceTypeGetVideoURL:
        {
            NSString * videoURL = dataObject[GP_GP_GET_VIDEO_URL_URL];
            
            [self _sendSuccessMsgWithData:[NSURL URLWithString:videoURL]];
            
        }
            
            break;
        
        case ServiceRequestSerivceTypeUserLogin:
        {
            GP_User * user = [[GP_User alloc] initWithInfoDic:dataObject];
            [self _sendSuccessMsgWithData:user];
        }
            break;
            
        case ServiceRequestSerivceTypeGetHomeHotVideos:
        {
            //初始化视频
            NSArray * resultVideos = [GP_Video dataArrayWithInfoArray:dataObject[GP_GP_GET_HOMEHOTPAGES_VIDOES]];
            
            [self _sendSuccessMsgWithData:resultVideos];
        }
            break;
        
        case ServiceRequestSerivceTypeGetHomeMoudlePages:
        {
            //初始化模块
            NSArray * resultModules = [GP_HomeVideosModule dataArrayWithInfoArray:dataObject];
            
            [self _sendSuccessMsgWithData:resultModules];
        }
            break;
            
        case ServiceRequestSerivceTypeGetChannels:
        {
            //初始化频道
            NSArray * resultChannels = [GP_Channel dataArrayWithInfoArray:dataObject[GP_GP_GET_CHANNELS_CHANNELS]];
            
            NSDictionary * result = @{GP_GP_GET_CHANNELS_CHANNELS : resultChannels,
                                      GP_GP_GET_CHANNELS_TOTALSIZES : dataObject[GP_GP_GET_CHANNELS_TOTALSIZES]
                                      };
            
            [self _sendSuccessMsgWithData:result];

        }
            break;
        
        case ServiceRequestSerivceTypeGetYouLikeVideos:
        case ServiceRequestSerivceTypeGetChannelVideos:
        case ServiceRequestSerivceTypeSearchVideos:
        case ServiceRequestSerivceTypeGetCollectVideos:
        case ServiceRequestSerivceTypeGetAboutVideos:
        case ServiceRequestSerivceTypeSearchVideosInChannel:
        {
            //初始化视频
            NSArray * resultVideos = [GP_Video dataArrayWithInfoArray:dataObject[GP_GP_VIDOES_VIDOES]];
            
            NSDictionary * result = @{
                                        GP_GP_VIDOES_VIDOES : resultVideos,
                                        GP_GP_VIDOES_TOTALSIZES : dataObject[GP_GP_VIDOES_TOTALSIZES]
                                      };
        
            [self _sendSuccessMsgWithData:result];
        }
            break;
            
        case ServiceRequestSerivceTypeGetVideoFilterInfo:
        {
            NSArray * videoFilterInfo = [GP_VideoFilterInfo videoFiltersWithDataInfos:dataObject];
            
            [self _sendSuccessMsgWithData:videoFilterInfo];
        }
            
            break;
    }
}

- (void)_sendSuccessMsgWithData:(id)data
{
    if (_successBlock) {
        _successBlock(_type, data);
    }
    
    id<GP_ServiceRequestDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(serviceRequest:serviceType:didSuccessRequestWithData:)){
        [delegate serviceRequest:self serviceType:_type didSuccessRequestWithData:data];
    }
}




@end
