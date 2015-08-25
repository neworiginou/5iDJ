//
//  ImageDownLoadManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyImageCachePool.h"

//----------------------------------------------------------

//缓存策略

typedef  NS_OPTIONS(NSUInteger, ImageDownLoadPolicy) {
    ImageDownLoadPolicyNone          = 0,    //无策略
    ImageDownLoadPolicyUseLocalCache = 1,    //优先使用本地缓存
    ImageDownLoadPolicyCacheImage    = 2,    //图片下载结束后缓存图片
//    ImageDownLoadPolicyNoCancle      = 0x04,    //中途取消下载图片无效
    
    ImageDownLoadPolicyDefault        = (ImageDownLoadPolicyCacheImage       |
                                       ImageDownLoadPolicyUseLocalCache),
    
//    ImageDownLoadPolicyUseAll        = (ImageDownLoadPolicyCacheImage       |
//                                        ImageDownLoadPolicyUseLocalCache    |
//                                        ImageDownLoadPolicyNoCancle)
};

#define UseLocalCache(_policy) ((BOOL)((_policy) & ImageDownLoadPolicyUseLocalCache))
#define CacheImage(_policy)    ((BOOL)((_policy) & ImageDownLoadPolicyCacheImage))
//#define NoCancle(_policy)      ((BOOL)((_policy) & ImageDownLoadPolicyNoCancle))

#define ImageDownLoadNoNetReachableErrorCode 9920
#define ImageDownLoadDataErrorCode           9921


//----------------------------------------------------------

@class MyImageDownLoadManager;

@protocol MyImageDownLoadDelegate

/*
 *缓存策略，默认为0, 即又使用缓存又缓存图像
 */
//- (ImageDownLoadCachePolicyFlags)cachePolicyFlagsForImageDownLoadManager:(ImageDownLoadManager *)manager;

/*
 *下载图片成功
 */
- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager downloadSucceedForURL:(NSString *)url image:(UIImage *)image;

/*
 *下载图片失败
 */
- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager downloadFailedForURL:(NSString *)url error:(NSError *) error;

@optional

//接受过程
- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
                    imageURL:(NSString *)url
        didReceiveDataLength:(long long)receiveDataLength
          expectedDataLength:(long long)expectedDataLength
            receiveDataSpeed:(NSUInteger)speed;

@end

//----------------------------------------------------------

@interface MyImageDownLoadManager : NSObject //<MyImageCachePoolDelegate>

/**
 * 共享的图片缓存池
 */
+ (MyImageCachePool *)shareImageCachePool;


- (id)initWithConcurrentCount:(NSUInteger)concurrentCount
                waitingCount:(NSUInteger)waitingCount;

/**
 * 通过ImageCachePool和并行下载数目初始化
 * @param imageCachePool  imageCachePool为图片缓存池，为nil则使用共享缓存池
 * @param concurrentCount concurrentCount为最大的并行下载数目，默认为10
 * @param waitingCount   waitingCount为等待下载任务最大数目，如果等待队列超过此数目则会取消下载任务并发送下载错误消
 *                         息，默认为20
 */
- (id)initWithImageCachePool:(MyImageCachePool *)imageCachePool
             concurrentCount:(NSUInteger)concurrentCount
                waitingCount:(NSUInteger)waitingCount;


/**
 * 当前使用的图片缓存池
 */
@property(nonatomic,strong,readonly) MyImageCachePool *imageCachePool;

/**
 * 开始下载图片
 * @param delegate delegate为下载图片的代理
 * @param url      url为图片URL，为nil则直接发送下载错误消息
 * @param policy   policy未下载策略
 */
- (void)startDownLoadImage:(id<MyImageDownLoadDelegate>)delegate
                       URL:(NSString *)url
            downLoadPolicy:(ImageDownLoadPolicy)policy;

/**
 * 取消delegate的所有下载图片任务，参数意义见下
 */
- (void)cancleDownLoadImage:(id<MyImageDownLoadDelegate>)delegate
              forceToCancle:(BOOL)force;

/**
 * 取消下载图片任务
 * @param delegate delegate为下载图片的代理
 * @param url      url为图片URL，为nil则取消所有
 * @param force    force代表是否取消网络下载任务，为YES取消网络任务，为NO只是代理接收不到消息，还会下载图片
 */
- (void)cancleDownLoadImage:(id<MyImageDownLoadDelegate>)delegate
                        URL:(NSString *)url
              forceToCancle:(BOOL)force;

/**
 * 取消所有的图片下载任务
 */
- (void)cancleAllDownLoadImage;


@end
