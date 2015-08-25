//
//  Header.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#ifndef GamePlayerDemo_Header_h
#define GamePlayerDemo_Header_h

//===========================================================
//    API host
//===========================================================

/*
 *API的主URL
 */

//#define GP_API_MAIN_URL             @"http://119.97.131.73:18080"

#define GP_API_MAIN_URL             @"http://119.97.131.42:8080"

//===========================================================
//     通用参数定义
//===========================================================


//返回参数

//1.success,标记是否成功
#define GP_GP_SUCCESS               @"success"

//2.result,成功返回,包含结果,字典类型
#define GP_GP_RESULT                @"result"

//3.errorCode,失败返回,错误编码,Sting类型
#define GP_GP_ERRORCODE             @"errorCode"

//4.errorMessage,失败返回,错误信息,Sting类型
#define GP_GP_ERRORMESSAGE          @"errorMessage"

//5.packageSize,包大小,int类型
#define GP_GP_PACKAGESIZE           @"packageSize"

//6.totalSizes,总数,int类型
#define GP_GP_TOTALSIZES             @"totalSizes"


//===========================================================
//     数据类型定义
//===========================================================


////视频

//1.videoId,视频ID,int类型
#define GP_GP_VIDEO_ID          @"videoId"

//2.videoName,视频名字,String类型
#define GP_GP_VIDEO_NAME        @"videoName"

//3.videoImageUrl,视频图片URL,String类型
#define GP_GP_VIDEO_IMAGEURL    @"videoImageUrl"

//4.videoHits,视频点击量,int类型
#define GP_GP_VIDEO_HITS        @"videoHitCount"

//5.duration,视频长度,int类型，单位秒
#define GP_GP_VIDEO_DURATION    @"duration"

//6.videoDescription,视频描述,String类型
#define GP_GP_VIDEO_DESCRIPTION @"videoDescription"

//7.videoYear,视频年份,int类型
#define GP_GP_VIDEO_YEAR        @"videoYear"

//8.updateTime,视频更新时间,String类型
#define GP_GP_VIDEO_UPDATETIME  @"updateTime"

//9.videoAppraise,视频评分,float类型
#define GP_GP_VIDEO_APPRAISE    @"videoAppraise"

//10.videoType,视频类型,int类型
#define GP_GP_VIDEO_TYPE        @"videoType"

//10.videoType,视频类型,int类型
#define GP_GP_VIDEO_BRIEF       @"videoBriefDes"

////频道

//1.videoId,视频ID,int类型
#define GP_GP_CHANNEL_ID          @"channelId"

//2.videoName,视频名字,String类型
#define GP_GP_CHANNEL_NAME        @"channelName"

//3.videoImageUrl,视频图片URL,String类型
#define GP_GP_CHANNEL_IMAGEURL    @"channelImageUrl"


////视频筛选发送的参数信息

//1.type,类型id,int类型,0为全部
#define GP_SP_VIDEOS_TYPE              @"type"

//5.year,年份id,int类型，0为全部
#define GP_SP_VIDEOS_YEAR              @"year"

//6.area,地区id,int类型，0为全部
#define GP_SP_VIDEOS_AREA              @"area"

//7.sortType,排序类型,int类型，取值看下
#define GP_SP_VIDEOS_SORTTYPE          @"sortType"

//7.1.sortType = 好评(old)
#define GP_SP_VIDEOS_SORTTYPE_GOOD       1

//7.2.sortType = 热播(old)
#define GP_SP_VIDEOS_SORTTYPE_HOT        2

//7.3.sortType = 新上线(old)
#define GP_SP_VIDEOS_SORTTYPE_NEW        3

//7.4.sortType = 精彩赛事
#define GP_SP_VIDEOS_SORTTYPE_MATCH      1

//7.5.sortType = 特色节目
#define GP_SP_VIDEOS_SORTTYPE_PROGRAMME  2

//7.6.sortType = 其他视频
#define GP_SP_VIDEOS_SORTTYPE_OTHER      3




///返回的参数信息


//1.totalSizes,视频总数,int类型
#define GP_GP_VIDOES_TOTALSIZES         @"totalSizes"

//2.videos,包含视频视频数组，array类型
#define GP_GP_VIDOES_VIDOES             @"videos"




//===========================================================
//      API
//===========================================================

/*
 *1.登录
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_LOGIN          @"mobile/login"

//请求示例
//http://119.97.131.73:18080/mobile/login?userName=123&userPassword=123

//请求参数

//1.userName,用户名,String类型
#define GP_SP_LOGIN_USERNAME        @"userName"

//2.userPassword,密码,String类型
#define GP_SP_LOGIN_PASSWORD        @"userPassword"

//返回的数据：JSON

//数据的参数

//1.result.token,String类型
#define GP_GP_LOGIN_TOKEN            @"token"

//2.result.userImgUrl,用户头像URL,String类型
#define GP_GP_LOGIN_USERIMGURL       @"userImgUrl"

//3.result.userName,用户头名,String类型
#define GP_GP_LOGIN_USERNAME         @"userName"


//结果示例

//成功
//{
//  "result":{
//              "userImgUrl":"http://119.97.131.73/home/pic/userImg/001.png",
//              "token":"BQNGZMXO69F5KQF1GKLFUN3LOK98TU3J",
//              "userName":"hldw520"
//           },
//  "success":true
//}

//失败
//{
//    "errorMessage":"账号或密码错误!!",
//    "errorCode":"ERROR0001",
//    "success":false


//===========================================================

/*
 *2.注册
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_REGISTER               @"mobile/registerUser"


//请求参数

//1.userName,用户名,String类型
#define GP_SP_REGISTER_USERNAME              @"userName"

//2.userPassword,密码,String类型
#define GP_SP_REGISTER_PASSWORD             @"userPassword"


//返回的数据：JSON


//结果示例

//成功
//{
//  "success":true
//}

//失败
//{
//    "errorMessage":"账号或密码错误!!",
//    "errorCode":"ERROR0001",
//    "success":false
//}


//===========================================================

/*
 *3.获取首页轮播
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_GET_HOMEHOTPAGES             @"mobile/getHomeHotPages"

//请求示例
//http://119.97.131.73:18080/mobile/getHomeHotPages?currentPage=0&pageSize=10


//请求参数

//1.currentPage,当前页面,int类型
#define GP_SP_GET_HOMEHOTPAGES_CURRENTPAGE        @"currentPage"

//2.pageSize,页面没大小,int类型
#define GP_SP_GET_HOMEHOTPAGES_PAGESIZE           @"pageSize"


//返回的数据：JSON

//数据的参数

//1.result.totalSizes,视频总数,int类型
#define GP_GP_GET_HOMEHOTPAGES_TOTALSIZES         @"totalSizes"

//2.result.videos,包含视频视频数组，array类型
#define GP_GP_GET_HOMEHOTPAGES_VIDOES             @"videos"


//结果示例

//{
//    "result":{
//                "totalSizes":2,
//                "videos":[
//                            {
//                                "videoId":47,
//                                "videoName":"视频1",
//                                "videoImageUrl":"http://119.97.131.73/home/pic/C00F4E068F8C4AF54024BAA6A80EC9BD/908223799D3FA652613763EA3D3570C4/2011/8F14E45FCEEA167A5A36DEDD4BEA2543.png"
//                            },
//                            ...
//                            ...
//                          ]
//            },
//    "success":true,
//    "packageSize":100
//}


//===========================================================

/*
 *4.获取首页模块
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_GET_HOMEMODULEPAGES         @"mobile/getHomeModulePages"

//请求示例
//http://119.97.131.73:18080/mobile/getHomeModulePages?currentPage=0&pageSize=10


//请求参数

//1.currentPage,当前页面,int类型
#define GP_SP_GET_HOMEMODULEPAGES_CURRENTPAGE    @"currentPage"

//2.pageSize,页面没大小,int类型
#define GP_SP_GET_HOMEMODULEPAGES_PAGESIZE       @"pageSize"


//返回的数据：JSON

//数据的参数

//1.result[i].pageId,页面id,int类型
#define GP_GP_GET_HOMEMODULEPAGES_PAGE_ID        @"pageId"

//2.result[i].pageName,页面名称,String类型
#define GP_GP_GET_HOMEMODULEPAGES_PAGE_NAME      @"pageName"

//3.result[i].pageImage,页面图像URL,String类型
#define GP_GP_GET_HOMEMODULEPAGES_PAGE_IMAGE     @"pageImage"

//4.result[i].videos,包含视频视频数组，array类型
#define GP_GP_GET_HOMEMODULEPAGES_VIDOES         @"videos"


//结果示例
//{"result":[
//            {
//                "pageName":"模块1",
//                "pageId":23,
//                "videos":[
//                            {
//                              "videoId":47,
//                              "videoName":"视频1",
//                              "videoImageUrl":"http://119.97.131.73/home/pic/C00F4E068F8C4AF54024BAA6A80EC9BD/908223799D3FA652613763EA3D3570C4/2011/8F14E45FCEEA167A5A36DEDD4BEA2543.png"
//                            },
//                              ...
//                              ...
//                          ],
//                "pageImage":""
//            },
//             ...
//             ...
//           ],
//    "success":true,
//    "packageSize":100
//}


//===========================================================

/*
 *5.获取视频详情
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_GET_VIDEO_DETAILS       @"mobile/getVideoDetails"


//请求参数

//1.videoId,视频ID,int类型
#define GP_SP_GET_VIDEO_DETAILS_VIDEOID      @"videoId"

//返回的数据：JSON

//返回video数据

//结果示例

//成功
//{
//  "result":{
//              "videoHits":192,
//              "duration":3262,
//              "videoDescription":"\u80fd\u6297\u80fd\u8f93\u51fa\u7684\u4e4c\u9e26\r\n",
//              "videoYear":3,
//              "updateTime":"2014-05-22",
//              "videoAppraise":3.333333,
//              "videoName":"\u7b56\u58eb\u7edf\u9886",
//              "videoType":2
//          },
//  "success":true
//}

//失败
//{
//    "errorMessage":"。。。。。",
//    "errorCode":"ERROR0001",
//    "success":false
//}


//===========================================================


/*
 *6.获取视频地址
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_GET_VIDEO_URL         @"mobile/getVideoUrl"


//请求参数

//1.videoId,视频ID,int类型
#define GP_SP_GET_VIDEO_URL_VIDEOID        @"videoId"

//2.token,用户token（可选）,String类型
#define GP_SP_GET_VIDEO_URL_TOKEN          @"token"


//返回的数据：JSON

//返回数据参数

//1.result.url,成功返回,String类型
#define GP_GP_GET_VIDEO_URL_URL             @"url"


//结果示例

//成功
//{
//  "result":{
//              "url":"http://119.97.131.73:18080/mobile/video?vid=2FZ6SMF3WAOUS6M5TOEENBBMWKWHCASV"
//           },
//  "success":true
//}

//失败
//{
//    "errorMessage":"。。。。。",
//    "errorCode":"ERROR0001",
//    "success":false
//}


//===========================================================

/*
 *7.猜你喜欢接口
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_GET_YOULIKE_VIDEOS         @"mobile/guessYouLikeVideos"


//请求参数

//1.token,用户token,String类型
#define GP_SP_GET_YOULIKE_VIDEOS_TOKEN          @"token"

//2.currentPage,当前页面,int类型
#define GP_SP_GET_YOULIKE_VIDEOS_CURRENTPAGE    @"currentPage"

//3.pageSize,页面没大小,int类型
#define GP_SP_GET_YOULIKE_VIDEOS_PAGESIZE       @"pageSize"


//返回的数据：JSON

//返回数据参数

//1.result.totalSizes,视频总数,int类型
#define GP_GP_GET_YOULIKE_VIDEOS_TOTALSIZES         @"totalSizes"

//2.result.videos,包含视频视频数组，array类型
#define GP_GP_GET_YOULIKE_VIDEOS_VIDOES             @"videos"


//结果示例

//成功
//{
//  "result":{
//              "totalSizes":"5",
//              "videos":[
//                         {
//                           "hits":81,
//                           "duration":1505,
//                           "updateTime":"2014-05-22",
//                           "videoId":62,
//                           "videoName":"[\u5751\u7239\u5b9d\u5178]\u6cd5\u5916\u72c2\u5f92",
//                           "videoImageUrl":"http://119.97.131.73/home/pic/54838A6BBAE2A14B0FB0C7905F6A070A/908223799D3FA652613763EA3D3570C4/2012/90CF53C2BB2B4C7675716E5766CA85A7.jpg"
//                          },
//                        ...
//                       ]
//             }
//}


//失败
//{
//    "errorMessage":"。。。。。",
//    "errorCode":"ERROR0001",
//    "success":false
//}


//===========================================================

/*
 *8.获取频道列表
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_GET_CHANNELS            @"mobile/getChannels"


//请求参数

//1.currentPage,当前页面,int类型
#define GP_SP_GET_CHANNELS_CURRENTPAGE       @"currentPage"

//2.pageSize,页面没大小,int类型
#define GP_SP_GET_CHANNELS_PAGESIZE          @"pageSize"


//返回的数据：JSON

//返回数据参数

//1.result.totalSizes,频道总数,int类型
#define GP_GP_GET_CHANNELS_TOTALSIZES         @"totalSizes"

//2.result.videos,包含频道数据的数组，array类型
#define GP_GP_GET_CHANNELS_CHANNELS           @"channels"


//结果示例

//成功
//{
//  "result":{
//              "totalSizes":10,
//              "channels":[
//                           {
//                              "channelName":"\u82f1\u96c4\u8054\u76df",
//                              "channelId":30,
//                              "channelImageUrl":"http://119.97.131.73/home/pic/54838A6BBAE2A14B0FB0C7905F6A070A/54838A6BBAE2A14B0FB0C7905F6A070A.png"
//                            },
//                          ....
//                          ]
//            },
//  "success":true,
//  "packageSize":100
//}


//失败
//{
//    "errorMessage":"。。。。。",
//    "errorCode":"ERROR0001",
//    "success":false
//}

//===========================================================

/*
 *9.获取频道视频
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_GET_CHANNEL_VIDEOS_OLD        @"mobile/getChannelVideos"

//-----------------------------------------------------------
//  New Version
//-----------------------------------------------------------

//API的路径
#define GP_API_ROUTE_GET_CHANNEL_VIDEOS            @"mobile/getChannelVideosByNewCategory"



//请求参数

//1.channelId,频道ID,int类型
#define GP_SP_GET_CHANNEL_VIDEOS_CHANNEL_ID        @"channelId"

//2.currentPage,当前页面,int类型
#define GP_SP_GET_CHANNEL_VIDEOS_CURRENTPAGE       @"currentPage"

//3.pageSize,页面没大小,int类型
#define GP_SP_GET_CHANNEL_VIDEOS_PAGESIZE          @"pageSize"

//其它筛选信息见上


//返回的数据：JSON

//返回数据参数

//1.result.totalSizes,视频总数,int类型
#define GP_GP_GET_CHANNEL_VIDEOS_TOTALSIZES         @"totalSizes"

//2.result.videos,包含频道数据的数组，array类型
#define GP_GP_GET_CHANNEL_VIDEOS_VIDOES             @"videos"


//结果示例

//成功
//{
//  "result":{
//              "totalSizes":14,
//              "videos":[
//                          {
//                              "videoHitCount":"6",
//                              "videoId":74,
//                              "videoName":"[\u82f1\u96c4\u4ee3\u8a00\u4eba]9\u671f \u8336\u8bdd\u4f1a",
//                              "videoImageUrl":"http://119.97.131.73/home/pic/54838A6BBAE2A14B0FB0C7905F6A070A/908223799D3FA652613763EA3D3570C4/2014/C2F2E1B06DA6196965C210AD4ECF09B0.jpg"
//                          },
//                         ...
//                        ]
//             },
//  "success":true,
//  "packageSize":100
//}


//失败
//{
//    "errorMessage":"。。。。。",
//    "errorCode":"ERROR0001",
//    "success":false
//}

//===========================================================

/*
 *10.获取视频筛选信息
 *
 *请求方式：GET
 *
 */

//API的路径
#define GP_API_ROUTE_GET_VIDEO_FILTER_INFO_OLD    @"mobile/getVideoFilterInfo"


//请求参数

//无

//返回的数据：JSON

//返回数据参数

//1.id,筛选信息的id
#define GP_GP_FILTER_INFO_ID_OLD                 @"id"

//2.value,筛选信息的值
#define GP_GP_FILTER_INFO_VALUE_OLD              @"value"

//3.types,类型
#define GP_GP_FILTER_INFO_TYPES_OLD              @"types"

//4.years,年份,int类型，0为全部
#define GP_GP_FILTER_INFO_YEARS_OLD              @"years"

//5.areas,地区,int类型，0为全部
#define GP_GP_FILTER_INFO_AREAS_OLD              @"areas"


//-----------------------------------------------------------
//  New Version
//-----------------------------------------------------------

//API的路径
#define GP_API_ROUTE_GET_VIDEO_FILTER_INFO    @"mobile/getVideoFilterInfoByNewVersion"


//请求参数

//无

//返回的数据：JSON

//返回数据参数

//1.values,筛选信息的所有取值,array类型
#define GP_GP_FILTER_INFO_VALUES             @"values"

//1.1.values[].id,筛选信息的取值的id,number类型
#define GP_GP_FILTER_INFO_ID                 @"id"

//1.2.values[].value,筛选信息的取值,string类型
#define GP_GP_FILTER_INFO_VALUE              @"value"

//2.description,筛选信息的描述,string类型
#define GP_GP_FILTER_INFO_DESCRIPTION        @"description"

//3.key,筛选信息的对应的key,string类型
#define GP_GP_FILTER_INFO_KEY                @"key"


//===========================================================

/*
 *11.搜索视频
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_SEARCH_VIDEOS           @"mobile/searchVideos"


//请求参数

//1.keyword,搜索关键字,string类型
#define GP_SP_SEARCH_VIDEOS_KEYWORD          @"keyword"

//2.currentPage,当前页面,int类型
#define GP_SP_SEARCH_VIDEOS_CURRENTPAGE      @"currentPage"

//3.pageSize,页面没大小,int类型
#define GP_SP_SEARCH_VIDEOS_PAGESIZE         @"pageSize"

//其它筛选信息见上


//返回的数据：JSON

//返回数据参数

//1.result.totalSizes,视频总数,int类型
#define GP_GP_SEARCH_VIDEOS_TOTALSIZES       @"totalSizes"

//2.result.videos,包含视频数据的数组，array类型
#define GP_GP_SEARCH_VIDEOS_VIDOES           @"videos"


//===========================================================

/*
 *12.收藏或删除收藏视频
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_COLLECT_VIDEO           @"mobile/addOrRemoveVideoToCollect"


//请求参数

//1.videoId,,string类型
#define GP_SP_COLLECT_VIDEO_VIDEOID    @"videoId"

//2.currentPage
#define GP_SP_COLLECT_VIDEO_TOKEN      @"token"

//3.addOrRemove
#define GP_SP_COLLECT_VIDEO_ADDORMOVE  @"addOrRemove"

//其它筛选信息见上


////返回的数据：JSON
//
////返回数据参数
//
////1.result.totalSizes,视频总数,int类型
//#define GP_GP_SEARCH_VIDEOS_TOTALSIZES       @"totalSizes"
//
////2.result.videos,包含视频数据的数组，array类型
//#define GP_GP_SEARCH_VIDEOS_VIDOES           @"videos"

//===========================================================

/*
 *13.获取用户收藏的视频
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_GET_COLLECT_VIDEOS      @"mobile/getUserCollectVideos"


//请求参数

//1.token,
#define GP_SP_GET_COLLECT_VIDEOS_TOKEN            @"token"

//2.currentPage,当前页面,int类型
#define GP_SP_GET_COLLECT_VIDEOS_CURRENTPAGE      @"currentPage"

//3.pageSize,页面没大小,int类型
#define GP_SP_GET_COLLECT_VIDEOS_PAGESIZE         @"pageSize"

//其它筛选信息见上


//返回的数据：JSON

//返回数据参数

//1.result.totalSizes,视频总数,int类型
#define GP_GP_GET_COLLECT_VIDEOS_TOTALSIZES       @"totalSizes"

//2.result.videos,包含视频数据的数组，array类型
#define GP_GP_GET_COLLECT_VIDEOS_VIDOES           @"videos"


//===========================================================

/*
 *14.获取相关视频接口
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_GET_ABOUT_VIDEOS      @"mobile/getTopFiveOfTheChannel"


//请求参数

//1.vid,视频ID
#define GP_SP_GET_ABOUT_VIDEOS_VIDEO_ID         @"vid"

//2.currentPage,当前页面,int类型
#define GP_SP_GET_ABOUT_VIDEOS_CURRENTPAGE      @"currentPage"

//3.pageSize,页面没大小,int类型
#define GP_SP_GET_ABOUT_VIDEOS_PAGESIZE         @"pageSize"

//其它筛选信息见上


//返回的数据：JSON

//返回数据参数

//1.result.totalSizes,视频总数,int类型
#define GP_GP_GET_ABOUT_VIDEOS_TOTALSIZES       @"totalSizes"

//2.result.videos,包含视频数据的数组，array类型
#define GP_GP_GET_ABOUT_VIDEOS_VIDOES           @"videos"


//===========================================================

/*
 *15.频道内搜索视频接口
 *
 *请求方式：GET/POST
 *
 */

//API的路径
#define GP_API_ROUTE_SEARCH_VIDEOS_IN_CHANNEL      @"mobile/searchVideosInChannel"


//请求参数

//1.channelId,频道ID
#define GP_SP_SEARCH_VIDEOS_IN_CHANNEL_CHANNEL_ID       @"channelId"

//2.keyword,关键字
#define GP_SP_SEARCH_VIDEOS_IN_CHANNEL_KEYWORD          @"keyword"

//3.currentPage,当前页面,int类型
#define GP_SP_SEARCH_VIDEOS_IN_CHANNEL_CURRENTPAGE      @"currentPage"

//4.pageSize,页面没大小,int类型
#define GP_SP_SEARCH_VIDEOS_IN_CHANNEL_PAGESIZE         @"pageSize"

//其它筛选信息见上


//返回的数据：JSON

//返回数据参数

//1.result.totalSizes,视频总数,int类型
#define GP_GP_SEARCH_VIDEOS_IN_CHANNEL_TOTALSIZES       @"totalSizes"

//2.result.videos,包含视频数据的数组，array类型
#define GP_GP_SEARCH_VIDEOS_IN_CHANNEL_VIDOES           @"videos"



#endif
