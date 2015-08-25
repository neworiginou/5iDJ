//
//  ImageCachePool.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@class MyImageCachePool;

//----------------------------------------------------------

@protocol MyImageCachePoolDelegate

@optional

/**
 * 缓存池将要从内存移除标识为key图片
 */
- (void)imageCachePool:(MyImageCachePool *)pool willRemoveImage:(UIImage *)image andKey:(NSString *)key;

@end

//----------------------------------------------------------

/**
 * 图片缓存池,支持内存与文件双缓存
 */
@interface MyImageCachePool : NSObject <NSCacheDelegate>

/**
 * 通过文件缓存的文件夹名初始化
 * @param fileFloderName fileFloderName文件缓存的文件夹名，该参数为nil则使用默认的“imageCache”
 */
- (id)initWithCacheFileFloderName:(NSString *)fileFloderName;

/**
 * 缓存图片
 * @param image image为需要缓存的图片,不能为nil，否则将抛出异常
 * @param key key为缓存图片的key,唯一标识一个图片,不能为nil，否则将抛出异常。
 *            如果有相同key的图片存在，则会替换该图片，并删除文件缓存
 * @param cacheToFile cacheToFile指示是否缓存到文件
 */
- (void)cacheImage:(UIImage *)image key:(NSString *)key cacheToFile:(BOOL)cacheToFile;

/**
 * 移除缓存图片
 * @param key key为缓存图片的key，key为nil将不做任何事
 * @param removeFile removeFile指示是否删除文件缓存
 */
- (void)removeCacheImageForKey:(NSString *)key removeFile:(BOOL)removeFile;

/**
 * 获取缓存的缓存图片
 * @param key key为缓存图片的key
 * @param ignoreFileCache ignoreFileCache指示是否忽略文件缓存
 * @return 返回标记为key的缓存图片，不存在则返回nil
 */
- (UIImage *)imageWithKey:(NSString *)key ignoreFileCache:(BOOL)ignoreFileCache;


/**
 * 内存缓存最大允许的容量，单位是M，最小为1M,默认为10M
 */
@property(nonatomic) NSUInteger maxCapacity;


/**
 * 清空缓存在内存上的图片
 */
- (void)clearCacheImageInMemory;

/**
 * 获取当前缓存池的图片文件的缓存的大小
 * @param completeBlock completeBlock为统计完成后调用的block
 */
- (void)cacheImageFileSize:(void(^)(long long))completeBlock;

/**
 * 清空当前缓存池的图片文件缓存
 * @param completeBlock completeBlock为删除完毕后调用的block
 */
- (void)clearCacheImageInFile:(void(^)())completeBlock;

/**
 * 获取所有图片文件缓存的大小
 * @param completeBlock completeBlock为统计完成后调用的block
 */
+ (void)allCacheImageFileSize:(void(^)(long long))completeBlock;

/**
 * 清空所有缓存池的图片文件缓存
 * @param completeBlock completeBlock为删除完毕后调用的block
 */
+ (void)clearAllCacheImageInFile:(void(^)())completeBlock;

/**
 * 清空所有图片，内存和文件
  * @param completeBlock completeBlock为删除完毕后调用的block
 */
- (void)clearAllCacheImage:(void(^)())completeBlock;


/**
 * 代理
 */
@property(nonatomic,weak) id<MyImageCachePoolDelegate> delegate;

@end
