//
//  GP_CacheManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * 缓存管理
 */
@interface GP_CacheManager : NSObject

/**
 * 获取缓存文件大小
 * @return 缓存文件的大小，单位是byte
 */
+ (void)cacheFileSize:(void(^)(long long)) completeBlock;

/**
 * 清空缓存文件
 */
+ (void)clearCacheFile:(void(^)()) completeBlock;


@end
