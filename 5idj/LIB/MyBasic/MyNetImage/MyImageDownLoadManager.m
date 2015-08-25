//
//  ImageDownLoadManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyImageDownLoadManager.h"
#import "MyHTTPRequest.h"
#import "MacroDef.h"

//----------------------------------------------------------

@interface _ImageDownLoadTask : NSObject

- (id)initWithImageURL:(NSString *)URL
              delegate:(id<MyImageDownLoadDelegate>)delegate
        downLoadPolicy:(ImageDownLoadPolicy)policy;


@property(nonatomic,strong,readonly) NSString *imageURL;
@property(nonatomic,strong,readonly) MyHTTPRequest * httpRequest;
//@property(nonatomic,strong,readonly) URLConnectionManager *urlConnectionManager;
@property(nonatomic,strong,readonly) NSMutableSet *delegateSet;

//缓存策略
@property(nonatomic) ImageDownLoadPolicy policy;

@end

//----------------------------------------------------------

@implementation _ImageDownLoadTask

- (id)initWithImageURL:(NSString *)URL
              delegate:(id<MyImageDownLoadDelegate>)delegate
        downLoadPolicy:(ImageDownLoadPolicy)policy
{
    if (self = [super init]) {
        _imageURL = URL;
//        _urlConnectionManager = [[URLConnectionManager alloc] init];
        _httpRequest = [[MyHTTPRequest alloc] initWithURL:URL];
        
        _delegateSet = [NSMutableSet set];
        if (delegate) {
            [_delegateSet addObject:delegate];
        }
        
        _policy = policy;
    }
    
    return self;
}

@end

@class _ImageDownLoadTaskWaitingPool;

@protocol _ImageDownLoadWaitingPoolDelegate

//将要删除此案在任务
- (void)imageDownLoadWaitingPool:(_ImageDownLoadTaskWaitingPool *)waitingPool
                   didRemoveTask:(_ImageDownLoadTask *)imageDownLoadTask;

@end


//图片下载等待池
@interface _ImageDownLoadTaskWaitingPool : NSObject

- (id)initWithWaitingCount:(NSUInteger)waitingCount;

- (void)addTaskWithURL:(NSString *)url
              delegate:(id<MyImageDownLoadDelegate>)delegate
        downLoadPolicy:(ImageDownLoadPolicy)policy;

- (_ImageDownLoadTask *)nextImageDownLoadTask;

@property(nonatomic,weak) id<_ImageDownLoadWaitingPoolDelegate> delegate;

@end

@implementation _ImageDownLoadTaskWaitingPool
{
    //URL到数据的映射表
    NSMutableDictionary *_URLToTaskMap;
    
    NSMutableArray      *_waitingTaskArray;
    
    NSUInteger           _waitingCount;
}

- (id)init
{
    return [self initWithWaitingCount:20];
}

- (id)initWithWaitingCount:(NSUInteger)waitingCount
{
    self = [super init];
    
    if (self) {
        _URLToTaskMap = [NSMutableDictionary dictionaryWithCapacity:waitingCount];
        _waitingTaskArray = [NSMutableArray arrayWithCapacity:waitingCount];
        
        _waitingCount = waitingCount;
    }
    
    return self;
}


- (void)addTaskWithURL:(NSString *)url
              delegate:(id<MyImageDownLoadDelegate>)delegate
        downLoadPolicy:(ImageDownLoadPolicy)policy
{
    _ImageDownLoadTask * imageDownLoadTask = [_URLToTaskMap objectForKey:url];
    
    if (imageDownLoadTask) {
        [_waitingTaskArray removeObjectIdenticalTo:imageDownLoadTask];
    }else{
        
        [self _tryRemoveTask];
        
        imageDownLoadTask = [[_ImageDownLoadTask alloc] initWithImageURL:url
                                                                delegate:delegate
                                                          downLoadPolicy:policy];
        [_URLToTaskMap setObject:imageDownLoadTask forKey:url];
        
        
    }
    
    [_waitingTaskArray addObject:imageDownLoadTask];
    
    [self _tryRemoveTask];
}

- (void)_tryRemoveTask
{
    if (_waitingTaskArray.count >= _waitingCount) {
        
        NSInteger index = 0;
        
        for (_ImageDownLoadTask * task in _waitingTaskArray) {
            
            if (task.delegateSet.count == 0) {
                
                break;
            }
            
            index ++ ;
        }
        
        if (index == _waitingTaskArray.count) {
            index = _waitingTaskArray.count ? 0.f : -1.f;
        }
        
        if (index >= 0) {
            
            _ImageDownLoadTask * task = _waitingTaskArray[index];
            
            //删除数据
            [_waitingTaskArray removeObjectAtIndex:index];
            [_URLToTaskMap removeObjectForKey:task.imageURL];
            
            //通知代理
            [self.delegate imageDownLoadWaitingPool:self didRemoveTask:task];
        }
    }
}

- (_ImageDownLoadTask *)nextImageDownLoadTask
{
    if (_waitingTaskArray.count) {
        
        _ImageDownLoadTask * imageDownLoadTask = _waitingTaskArray.lastObject;
        
        //删除数据
        [_waitingTaskArray removeLastObject];
        [_URLToTaskMap removeObjectForKey:imageDownLoadTask.imageURL];
        
        return imageDownLoadTask;
    }
    
    return nil;
}

@end


//----------------------------------------------------------

@interface MyImageDownLoadManager () <MyHTTPRequestDelegate,_ImageDownLoadWaitingPoolDelegate>

//添加下载任务
- (void)_addImageDownLoadTaskWithURL:(NSString *)url
                            delegate:(id<MyImageDownLoadDelegate>)delegate
                      downLoadPolicy:(ImageDownLoadPolicy)policy;

//开始下载任务
- (void)_startImageDownLoadTask:(_ImageDownLoadTask *)imageDownLoadTask;


//开始下一个下载任务从等待池
- (void)_startNextImageDownLoadTaskFromWaitingPool;


@end


//----------------------------------------------------------


@implementation MyImageDownLoadManager
{
    //同时下载的最大容量
    NSUInteger           _concurrentCount;
    
    //URL到数据的映射表
    NSMutableDictionary *_URLToTaskMap;
    
    //代理到数据的映射表
    NSMutableDictionary *_delegateToTaskDicMap;
    
    //URL连接管理到数据的映射表
//    NSMutableDictionary *_URLConnectionManagerToTaskMap;
    
    //URL连接管理到数据的映射表
    NSMutableDictionary *_httpRequestToTaskMap;
    
    //等待池
    _ImageDownLoadTaskWaitingPool   * _waitingPool;
}


@synthesize imageCachePool = _imageCachePool;

+ (MyImageCachePool *)shareImageCachePool
{
    static MyImageCachePool *shareImageCachePool = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareImageCachePool = [[MyImageCachePool alloc] init];
    });
        
    return shareImageCachePool;
                  
}

- (id)init
{
    return [self initWithImageCachePool:nil concurrentCount:10 waitingCount:20];
}

- (id)initWithConcurrentCount:(NSUInteger)concurrentCount waitingCount:(NSUInteger)waitingCount;
{
    return [self initWithImageCachePool:nil concurrentCount:concurrentCount waitingCount:waitingCount];
}

- (id)initWithImageCachePool:(MyImageCachePool *)imageCachePool
             concurrentCount:(NSUInteger)concurrentCount
                waitingCount:(NSUInteger)waitingCount
{
    if (concurrentCount == 0) {
        
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"并行下载图片的最大数目不能为0"
                                        userInfo:nil];
    }
    
    if (self = [super init]) {
        
        _URLToTaskMap                   = [NSMutableDictionary dictionaryWithCapacity:concurrentCount];
        _delegateToTaskDicMap           = [NSMutableDictionary dictionaryWithCapacity:concurrentCount];
        _httpRequestToTaskMap           = [NSMutableDictionary dictionaryWithCapacity:concurrentCount];
        _concurrentCount                = concurrentCount;
        _imageCachePool                 = imageCachePool;
        
        _waitingPool = [[_ImageDownLoadTaskWaitingPool alloc] initWithWaitingCount:waitingCount];
        _waitingPool.delegate = self;
    }
    
    return self;

}

- (MyImageCachePool *)imageCachePool
{
    if (!_imageCachePool) {
        _imageCachePool = [MyImageDownLoadManager shareImageCachePool];
    }
    
    return _imageCachePool;
}

- (void)dealloc
{
    //取消所有任务
    [self cancleAllDownLoadImage];
}

//发送下载成功消息
#define SendDownLoadSucceedMsg(_delegate,_image,_url)                                            \
do {                                                                                             \
    ifRespondsSelector(_delegate, @selector(imageDownLoadManager:downloadSucceedForURL:image:))  \
        [_delegate imageDownLoadManager:self downloadSucceedForURL:_url image:_image];           \
}while(0)

//发送下载失败消息
#define SendDownLoadFailedMsg(_delegate,_url,_error)                                             \
do {                                                                                             \
    ifRespondsSelector(_delegate, @selector(imageDownLoadManager:downloadFailedForURL:error:))   \
        [_delegate imageDownLoadManager:self downloadFailedForURL:_url error:_error];            \
} while (0)

//下载图片错误的构造
#define DownLoadImageError(_code,_description)  ERROR(@"DownLoadImageDomin",_code,_description)

- (void)startDownLoadImage:(id<MyImageDownLoadDelegate>)delegate
                       URL:(NSString *)url
            downLoadPolicy:(ImageDownLoadPolicy)policy
{
    if (!url) {
        //发送错误消息
        SendDownLoadFailedMsg(delegate,url,DownLoadImageError(0,@"URL为空"));
        return;
    }
    
    //是否使用本地缓存
    BOOL useLocalCache = UseLocalCache(policy);

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __block UIImage *resultImage = nil;
        
        if (useLocalCache) {
            resultImage = [self.imageCachePool imageWithKey:url ignoreFileCache:NO];
        }
        
        NSURL * requestURL = nil;
        
        //如果是文件URL，直接加载
        if (!resultImage && [(requestURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) isFileURL]) {
            
            //直接读取
            resultImage = [UIImage imageWithContentsOfFile:requestURL.path];
            
            //直接读取失败，用名字读取
            if(!resultImage){
                resultImage = [UIImage imageNamed:[requestURL.pathComponents lastObject]];
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            //从文件缓存加载成功
            if (resultImage) {
                
                //缓存到内存池
                if (CacheImage(policy) && ![self.imageCachePool imageWithKey:url ignoreFileCache:YES]) {
                    [self.imageCachePool cacheImage:resultImage key:url cacheToFile:YES];
                }
                
                //发送消息给代理
                SendDownLoadSucceedMsg(delegate,resultImage,url);
                
            }else {
                
                //添加下载任务
                [self _addImageDownLoadTaskWithURL:url delegate:delegate downLoadPolicy:policy];
            }
        });
    });
}


- (void)_addImageDownLoadTaskWithURL:(NSString *)url
                            delegate:(id<MyImageDownLoadDelegate>)delegate
                        downLoadPolicy:(ImageDownLoadPolicy)policy
{
    
    //先尝试从存在的下载数据表中获取
    _ImageDownLoadTask *imgaeDownLoadTask = [_URLToTaskMap objectForKey:url];
    
    //已存的任务
    if (imgaeDownLoadTask) {
        
        imgaeDownLoadTask = [[_ImageDownLoadTask alloc] initWithImageURL:url
                                                                delegate:delegate
                                                          downLoadPolicy:policy];
        
        [self _startImageDownLoadTask:imgaeDownLoadTask];
        
    }else{
        
        //加入等待池
        [_waitingPool addTaskWithURL:url delegate:delegate downLoadPolicy:policy];
        
        //开始下一个等待任务
        [self _startNextImageDownLoadTaskFromWaitingPool];
        
    }
}

- (void)_startImageDownLoadTask:(_ImageDownLoadTask *)imageDownLoadTask
{
    if (!imageDownLoadTask) {
        return;
    }
    
    _ImageDownLoadTask * tmpImageDownLoadTask = [_URLToTaskMap objectForKey:imageDownLoadTask.imageURL];
    
    BOOL isNew = NO;
    
    if (!tmpImageDownLoadTask) {
        
        isNew = YES;
        tmpImageDownLoadTask = imageDownLoadTask;
        
        //新的下载任务
        [_URLToTaskMap setObject:tmpImageDownLoadTask forKey:tmpImageDownLoadTask.imageURL];
        [_httpRequestToTaskMap setObject:tmpImageDownLoadTask forKey:NSNumberWithPointer(tmpImageDownLoadTask.httpRequest)];
        
    }else{
        
        //已存在只需更改协议和代理集合
        
        tmpImageDownLoadTask.policy |= imageDownLoadTask.policy;
        
        for (id delegate in imageDownLoadTask.delegateSet) {
            [tmpImageDownLoadTask.delegateSet addObject:delegate];
        }
    }
    
    for (id delegate in imageDownLoadTask.delegateSet) {
        
        //新的代理数据加入
        NSNumber * delegateKey = NSNumberWithPointer(delegate);
        NSMutableDictionary* taskDic = [_delegateToTaskDicMap objectForKey:delegateKey];
        
        if (!taskDic) {
            taskDic = [NSMutableDictionary dictionary];
            [_delegateToTaskDicMap setObject:taskDic forKey:delegateKey];
        }
        
        [taskDic setObject:tmpImageDownLoadTask forKey:NSNumberWithPointer(tmpImageDownLoadTask)];
    }
    
    if (isNew) {
        
        //开始请求
        [tmpImageDownLoadTask.httpRequest setDelegate:self];
        [tmpImageDownLoadTask.httpRequest startRequest];
    }

}

- (void)_startNextImageDownLoadTaskFromWaitingPool
{
    if (_URLToTaskMap.count < _concurrentCount) {
        
        _ImageDownLoadTask * imageDownLoadTask  = [_waitingPool nextImageDownLoadTask];
        
        //开始下载任务
        if (imageDownLoadTask) {
            [self _startImageDownLoadTask:imageDownLoadTask];
        }
    }
    
}

//移除下载数据
#define RemoveDownLoadTask(downLoadTask)                                                        \
{                                                                                               \
    [_httpRequestToTaskMap removeObjectForKey:NSNumberWithPointer(downLoadTask.httpRequest)];   \
    [_URLToTaskMap removeObjectForKey:downLoadTask.imageURL];                                   \
}



- (void)cancleDownLoadImage:(id<MyImageDownLoadDelegate>)delegate forceToCancle:(BOOL)force
{
    [self cancleDownLoadImage:delegate URL:nil forceToCancle:force];
}

- (void)cancleDownLoadImage:(id<MyImageDownLoadDelegate>)delegate
                        URL:(NSString *)url
              forceToCancle:(BOOL)force
{
    NSNumber * delegateKey = NSNumberWithPointer(delegate);
    NSMutableDictionary * taskDic = [_delegateToTaskDicMap objectForKey:delegateKey];
    
    if (taskDic) {
        
        for (_ImageDownLoadTask  *downLoadTask in taskDic.allValues) {
            
            if (url == nil || [downLoadTask.imageURL isEqualToString:url]) {
            
                [downLoadTask.delegateSet removeObject:delegate];
                
                if (force && downLoadTask.delegateSet.count == 0) {
                    [downLoadTask.httpRequest cancleRequest];
//                    [downLoadTask.urlConnectionManager cancleConnection:self];
                    RemoveDownLoadTask(downLoadTask);
                }
                
                [taskDic removeObjectForKey:NSNumberWithPointer(downLoadTask)];
                
                if (url != nil) {
                    break;
                }
            }
        }
        
        if (taskDic.count == 0) {
            [_delegateToTaskDicMap removeObjectForKey:delegateKey];
        }
    }
}

- (void)cancleAllDownLoadImage
{
    //取消任务
    for (_ImageDownLoadTask *downLoadTask in _URLToTaskMap.allValues) {
        [downLoadTask.httpRequest cancleRequest];
    }
    
    //清除数据
    [_delegateToTaskDicMap removeAllObjects];
    [_URLToTaskMap removeAllObjects];
    [_httpRequestToTaskMap removeAllObjects];
}

//移除代理的下载数据映射表中的数据
#define RemoveDownLoadTaskForDelegate(downLoadTask,delegate)                                    \
{                                                                                               \
    NSNumber * delegateKey = NSNumberWithPointer(delegate);                                     \
    NSMutableDictionary* taskDic = [_delegateToTaskDicMap objectForKey:delegateKey];            \
    [taskDic removeObjectForKey:NSNumberWithPointer(downLoadTask)];                             \
    if (taskDic.count == 0) {                                                                   \
        [_delegateToTaskDicMap removeObjectForKey:delegateKey];                                 \
    }                                                                                           \
}


- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didSuccessRequestWithData:(NSData *)data
{
    _ImageDownLoadTask  *downLoadTask = [_httpRequestToTaskMap objectForKey:NSNumberWithPointer(request)];

    if (downLoadTask) {
        
        UIImage *resultImage = [UIImage imageWithData:data];
        
        if (!resultImage) {
            
            [self httpRequest:request didFailedRequestWithError:DownLoadImageError(ImageDownLoadDataErrorCode,@"获取的图片数据不合法")];
            return;
        }
        
        //缓存图片
        if(CacheImage(downLoadTask.policy)){
            [self.imageCachePool cacheImage:resultImage key:downLoadTask.imageURL cacheToFile:YES];
        }
        
        for (id<MyImageDownLoadDelegate> delegate in downLoadTask.delegateSet) {
            //发送成功消息
            SendDownLoadSucceedMsg(delegate, resultImage, downLoadTask.imageURL);
            
            RemoveDownLoadTaskForDelegate(downLoadTask,delegate);
        }
        
        RemoveDownLoadTask(downLoadTask);
        
        //从等待队列开始下一个任务
        [self _startNextImageDownLoadTaskFromWaitingPool];
    }

}



- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didFailedRequestWithError:(NSError *)error
{
    _ImageDownLoadTask  *downLoadTask = [_httpRequestToTaskMap objectForKey:NSNumberWithPointer(request)];

    if (downLoadTask) {
        
        NSError  *downLoadError = DownLoadImageError(error.code, DescriptionWithError(error));
        
        for (id<MyImageDownLoadDelegate> delegate in downLoadTask.delegateSet) {
            //发送失败消息
            SendDownLoadFailedMsg(delegate, downLoadTask.imageURL, downLoadError);
            
            RemoveDownLoadTaskForDelegate(downLoadTask,delegate);
        }
        
        RemoveDownLoadTask(downLoadTask);
        
        //从等待队列开始下一个任务
        [self _startNextImageDownLoadTaskFromWaitingPool];
    }

}

- (void)httpRequest:(id<MyHTTPRequestProtocol>)request
        didReceiveDataLength:(long long)receiveDataLength
          expectedDataLength:(long long)expectedDataLength
            receiveDataSpeed:(NSUInteger)speed
{
    _ImageDownLoadTask  *downLoadTask = [_httpRequestToTaskMap objectForKey:NSNumberWithPointer(request)];

    if(downLoadTask){
        
        for (id<MyImageDownLoadDelegate> delegate in downLoadTask.delegateSet) {
            
            ifRespondsSelector(delegate, @selector(imageDownLoadManager:imageURL:didReceiveDataLength:expectedDataLength:receiveDataSpeed:)){
                [delegate imageDownLoadManager:self
                                      imageURL:downLoadTask.imageURL
                          didReceiveDataLength:receiveDataLength
                            expectedDataLength:expectedDataLength
                              receiveDataSpeed:speed];
            }
        }
    }

}

- (void)imageDownLoadWaitingPool:(_ImageDownLoadTaskWaitingPool *)waitingPool
                   didRemoveTask:(_ImageDownLoadTask *)imageDownLoadTask
{
    for (id<MyImageDownLoadDelegate> delegate in imageDownLoadTask.delegateSet) {
        SendDownLoadFailedMsg(delegate, imageDownLoadTask.imageURL, DownLoadImageError(0,@"由于图片下载任务过多，下载请求被取消。"));
    }
}

@end
