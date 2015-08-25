//
//  MyAssetsManager.h
//  Bestone
//
//  Created by Xuzhanya on 14-6-4.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import "MyAssetsGrounp.h"

//资源组的类型
typedef NS_ENUM(NSInteger, MyAssetsGroupType)
{
    MyAssetsGroupTypeOnlyPhoto,    //只包含图片
    MyAssetsGroupTypeOnlyVideo,    //只包含视频
    MyAssetsGroupTypeAll           //都包含
};


//@class MyAsset,MyAssetsGrounp;


@interface MyAssetsManager : NSObject

+ (ALAssetsLibrary *)shareAssetsLibrary;

//获取特定类型的资源组
//+ (NSArray *)allAssetsGroupWithType:(MyAssetsGroupType)type error:(NSError * __autoreleasing *)error;

+ (void)allAssetsGroupWithType:(MyAssetsGroupType)type
               inAssetsLibrary:(ALAssetsLibrary *)assetsLibary
                 completeBlock:(void(^)(NSArray * assetsGroups)) completeBlock
                  failureBlock:(void (^)(NSError * error))failureBlock;

+ (NSArray *)assetsInRange:(NSRange)range inAssetsGrounp:(ALAssetsGroup *) assetsGroup;


+ (void)assetsGroupsForURLs:(NSSet *)urlSet
                       type:(MyAssetsGroupType)type
            inAssetsLibrary:(ALAssetsLibrary *)assetsLibary
              completeBlock:(void(^)(NSArray * assetsGroups)) completeBlock;
//               failureBlock:(void (^)(NSError * error))failureBlock;


//+ (BOOL)assetsGroup:(ALAssetsGroup *) assetsGroup containAsset:(NSURL *)assetURL;


//+ (ALAsset *)assetForURL:(NSURL *)url error:(NSError * __autoreleasing *)error;

@end
