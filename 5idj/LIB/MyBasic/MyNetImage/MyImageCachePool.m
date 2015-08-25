//
//  ImageCachePool.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyImageCachePool.h"
#import "MyPathManager.h"
#import "MacroDef.h"
#import "help.h"

//----------------------------------------------------------
@interface _ImageData : NSObject

+ (_ImageData *)dataWithImage:(UIImage *)image key:(NSString *)key;
- (id)initWithImage:(UIImage *)image key:(NSString *)key;

@property(nonatomic,strong,readonly) NSString * key;
@property(nonatomic,strong,readonly) UIImage  * image;

@end

//----------------------------------------------------------

@implementation _ImageData

+ (_ImageData *)dataWithImage:(UIImage *)image key:(NSString *)key
{
    return [[_ImageData alloc] initWithImage:image key:key];
}

- (id)initWithImage:(UIImage *)image key:(NSString *)key
{
    assert(image && key);
    
    if (self = [super init]) {
        _key = key;
        _image = image;
    }
    return self;
}

@end

////----------------------------------------------------------

@interface MyImageCachePool ()

//缓存文件夹的路径
@property(nonatomic,readonly,strong) NSString * imageCacheFileFolderPath;

//缓存区
@property(nonatomic,readonly,strong) NSCache  * cache;

//共享的文件缓存操作队列
+ (dispatch_queue_t)_shareImageFileCacheQueue;

//所有的缓存文件的总路径
+ (NSString *)_pathForAllCacheImageFilePath;

//获取为imageKey的图片的缓存图片路径
- (NSString *)_cacheImageFilePathForImageKey:(NSString *)imageKey;

//缓存图片到文件
- (void)_cacheImageToFile:(UIImage *)image imageKey:(NSString *)imageKey;

//缓存图片到内存
- (void)_cacheImage:(UIImage *)image key:(NSString *)key;

//删除文件缓存
- (void)_removeFileCacheForKey:(NSString *)key;

//收到内存警告通知
- (void)_didReceiveMemoryWarningNotification:(NSNotification *)notification;

@end

//----------------------------------------------------------

@implementation MyImageCachePool
{
    NSString * _fileFloderName;
}

@synthesize imageCacheFileFolderPath = _imageCacheFileFolderPath;
@synthesize cache = _cache;

#pragma mark - life circle

- (id)init
{
    return [self initWithCacheFileFloderName:nil];
}

- (id)initWithCacheFileFloderName:(NSString *)fileFloderName
{
    self = [super init];
    
    if (self) {
        
        _fileFloderName = [fileFloderName copy];
        _maxCapacity    = 10;
        
        //记录通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_didReceiveMemoryWarningNotification:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    _cache.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_didReceiveMemoryWarningNotification:(NSNotification *)notification
{
    [self clearCacheImageInMemory];
}


- (NSCache *)cache
{
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        _cache.delegate = self;
        [_cache setTotalCostLimit:self.maxCapacity * 1024];
    }
    
    return _cache;
}

#pragma mark - cache image handle

- (void)setMaxCapacity:(NSUInteger)maxCapacity
{
    if (_maxCapacity != maxCapacity) {
        _maxCapacity = MAX(1, maxCapacity) ;
        [_cache setTotalCostLimit:_maxCapacity * 1024];
    }
}


- (void)cacheImage:(UIImage *)image key:(NSString *)key cacheToFile:(BOOL)cacheToFile
{
    //存入内存
    [self _cacheImage:image key:key];
    
    if (cacheToFile) {
        //缓存图片到文件
        [self _cacheImageToFile:image imageKey:key];
    }else{
        //删除文件缓存
        [self _removeFileCacheForKey:key];
    }
}

- (void)removeCacheImageForKey:(NSString *)key removeFile:(BOOL)removeFile
{
    if (key) {
        
        //从内存删除删除
        [self.cache removeObjectForKey:key];
        
        if (removeFile) {
            
            //删除文件缓存
            [self _removeFileCacheForKey:key];
        }
    }
}

- (UIImage *)imageWithKey:(NSString *)key ignoreFileCache:(BOOL)ignoreFileCache
{
    if (key) {
        
       __block  UIImage * resultImage = [(_ImageData *)[self.cache objectForKey:key] image];
        
        if (!resultImage && !ignoreFileCache) {
            
            //同步从文件获取
            dispatch_sync([MyImageCachePool _shareImageFileCacheQueue], ^{
                
                NSString * filePath = [self _cacheImageFilePathForImageKey:key];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    resultImage = [UIImage imageWithContentsOfFile:filePath];
                }
            });
            
            //缓存图片到内存
            if (resultImage) {
                [self _cacheImage:resultImage key:key];
            }
        }
        
        return resultImage;
    }
    
    return nil;
}

- (void)clearCacheImageInMemory
{
    [self.cache removeAllObjects];
}

#pragma mark - file cache manager

+ (NSString *)_pathForAllCacheImageFilePath
{
    return [[[MyPathManager alloc] initWithType:MyPathTypeTemp andFileFolder:@"imageCache"] path];
}

- (NSString *)imageCacheFileFolderPath
{
//    return [[[MyPathManager alloc] initWithType:MyPathTypeTemp andFileFolder:@"imageCache"] pathForDirectory:_fileFloderName];
    
    if (!_imageCacheFileFolderPath) {
        _imageCacheFileFolderPath = [[[MyPathManager alloc] initWithType:MyPathTypeTemp andFileFolder:@"imageCache"] pathForDirectory:_fileFloderName.length ? _fileFloderName : @"defaultImageCache"];
    }
    
    return _imageCacheFileFolderPath;
}

- (void)cacheImageFileSize:(void (^)(long long))completeBlock
{
    folderSizeAtPath_asyn(self.imageCacheFileFolderPath,completeBlock);
}

+ (void)allCacheImageFileSize:(void (^)(long long))completeBlock
{
    folderSizeAtPath_asyn([self _pathForAllCacheImageFilePath],completeBlock);
}

- (void)clearCacheImageInFile:(void (^)())completeBlock
{
    dispatch_barrier_async([MyImageCachePool _shareImageFileCacheQueue], ^{
        
        //删除目录
        removeItemAtPath(self.imageCacheFileFolderPath, NO);
        
        //确保目录存在
        makeSrueDirectoryExist(self.imageCacheFileFolderPath);
        
        //主线程通知
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), completeBlock);
        }
    });
}

+ (void)clearAllCacheImageInFile:(void (^)())completeBlock
{
    dispatch_barrier_async([MyImageCachePool _shareImageFileCacheQueue], ^{
        
        //删除所有图片
        removeItemAtPath([self _pathForAllCacheImageFilePath], YES);
        
        //主线程通知
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), completeBlock);
        }
    });

}

- (void)clearAllCacheImage:(void(^)())completeBlock
{
    [self clearCacheImageInMemory];
    [self clearCacheImageInFile:completeBlock];
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    id<MyImageCachePoolDelegate> delegate = self.delegate;
    
    ifRespondsSelector(delegate, @selector(imageCachePool:willRemoveImage:andKey:)){
        
        //主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _ImageData *data = obj;
            [delegate imageCachePool:self willRemoveImage:data.image andKey:data.key];
        });
    }
}

+ (dispatch_queue_t)_shareImageFileCacheQueue
{
    static dispatch_queue_t shareImageFileCacheQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareImageFileCacheQueue = dispatch_queue_create("ImageCachePool.shareImageFileCacheQueue",DISPATCH_QUEUE_CONCURRENT);
    });
    
    return shareImageFileCacheQueue;
}

- (void)_cacheImage:(UIImage *)image key:(NSString *)key
{
    if (image == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"image不能为nil"
                                        userInfo:nil];
    }
    
    if (key == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"key不能为nil"
                                        userInfo:nil];
    }
    
    CGImageRef imageRef = image.CGImage;
    
    //获取图片所占比特数
    size_t bytesSize = CGImageGetBitsPerPixel(imageRef) * CGImageGetWidth(imageRef) * CGImageGetHeight(imageRef);
    
    //获取储存图片的花费，即占多少kb(>>13 == /(8 * 1024))
    NSUInteger cost = bytesSize >> 13;
    cost = MAX(1, cost);
    
    //存入
    [self.cache setObject:[_ImageData dataWithImage:image key:key] forKey:key cost:cost];
}


- (NSString *)_cacheImageFilePathForImageKey:(NSString *)imageKey
{
    assert(imageKey);
    
    return [self.imageCacheFileFolderPath stringByAppendingPathComponent:[hashStrWithStr(imageKey, HashFuncType_MD5) stringByAppendingPathExtension:@"jpg"]];
}

- (void)_cacheImageToFile:(UIImage *)image imageKey:(NSString *)imageKey
{
    dispatch_barrier_async([MyImageCachePool _shareImageFileCacheQueue], ^{
    
        //写入文件
        [UIImageJPEGRepresentation(image, 1.0f) writeToFile:[self _cacheImageFilePathForImageKey:imageKey]
                                                 atomically:YES];
    });
}

- (void)_removeFileCacheForKey:(NSString *)key
{
    dispatch_barrier_async([MyImageCachePool _shareImageFileCacheQueue], ^{
        
        //删除数据
        [[NSFileManager defaultManager] removeItemAtPath:[self _cacheImageFilePathForImageKey:key]
                                                   error:nil];
    });
}

@end
