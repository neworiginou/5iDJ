//
//  GP_CacheManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "GP_CacheManager.h"

@implementation GP_CacheManager

+ (void)cacheFileSize:(void (^)(long long))completeBlock
{
    return  [MyImageCachePool allCacheImageFileSize:completeBlock];
}

+ (void)clearCacheFile:(void (^)())completeBlock
{
    [MyImageCachePool clearAllCacheImageInFile:completeBlock];
}

@end
