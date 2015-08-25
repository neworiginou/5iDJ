//
//  MyAssetsManager.m
//  Bestone
//
//  Created by Xuzhanya on 14-6-4.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "MyAssetsManager.h"

@implementation MyAssetsManager

+ (ALAssetsLibrary *)shareAssetsLibrary
{
    static ALAssetsLibrary * _shareAssetsLibrary  = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareAssetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    
    
    return _shareAssetsLibrary;
}

+ (void)allAssetsGroupWithType:(MyAssetsGroupType)type
                inAssetsLibrary:(ALAssetsLibrary *)assetsLibary
                 completeBlock:(void (^)(NSArray *))completeBlock
                  failureBlock:(void (^)(NSError *))failureBlock
{
    
    assetsLibary = assetsLibary?: [self shareAssetsLibrary];
    
    completeBlock = [completeBlock copy];
    failureBlock = [failureBlock copy];
    
    NSMutableArray * assetsGroups = [NSMutableArray array];
  
   
    [assetsLibary enumerateGroupsWithTypes:ALAssetsGroupAll
                                usingBlock:^(ALAssetsGroup * assetsGroup,BOOL * stop){
                                    
                                    if (!assetsGroup) {
                                        
                                        //完成
                                        if (completeBlock) {
                                            completeBlock(assetsGroups);
                                        }
                                        
                                        return;
                                    }
                                    
                                    //设置过滤器
                                    switch (type) {
                                        case MyAssetsGroupTypeOnlyVideo:
                                            [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                                            break;
                                            
                                        case MyAssetsGroupTypeOnlyPhoto:
                                            [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                                            break;
                                            
                                        default:
                                            break;
                                    }
                                    
                                    //加入
                                    [assetsGroups addObject:assetsGroup];
                                }
                              failureBlock:^(NSError * error){
                                  
                                  if (failureBlock) {
                                      failureBlock(error);
                                  }
                              }];

}


+ (void)assetsGroupsForURLs:(NSSet *)urlSet
                       type:(MyAssetsGroupType)type
            inAssetsLibrary:(ALAssetsLibrary *)assetsLibary
              completeBlock:(void (^)(NSArray *))completeBlock
{
    assetsLibary = assetsLibary?: [self shareAssetsLibrary];
    
    completeBlock = [completeBlock copy];
    
    NSMutableArray * assetsGroups = [NSMutableArray array];
    
    if ([urlSet count] == 0) {
        completeBlock(assetsGroups);
    }else{
        
         __block NSUInteger completeCount = 0;
        
        for (NSURL * url in urlSet) {
            
            [assetsLibary groupForURL:url
                          resultBlock:^(ALAssetsGroup * assetsGroup){
                              
                              //设置类型
                              switch (type) {
                                  case MyAssetsGroupTypeOnlyVideo:
                                      [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                                      break;
                                      
                                  case MyAssetsGroupTypeOnlyPhoto:
                                      [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                                      break;
                                      
                                  default:
                                      break;
                              }
                              
                              [assetsGroups addObject:assetsGroup];
                              
                              if (++ completeCount == [urlSet count]) {
                                  //完成
                                  completeBlock(assetsGroups);
                            }
                              
                              
                          }
                         failureBlock:^(NSError * error){
                             
                             if (++ completeCount == [urlSet count]) {
                                 //完成
                                 completeBlock(assetsGroups);
                             }
                             
                         }];
        }
    }
}



+ (NSArray *)assetsInRange:(NSRange)range inAssetsGrounp:(ALAssetsGroup *)assetsGroup
{
    if (assetsGroup) {
        
        assert(range.location + range.length <= [assetsGroup numberOfAssets]);
        
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        NSMutableArray * asserts = [NSMutableArray arrayWithCapacity:range.length];
        
        [assetsGroup enumerateAssetsAtIndexes:indexSet options:0
                                   usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
                                       if (result) {
                                            [asserts addObject:result];
                                       }
                                   }];
        
        
        return asserts;
    }
    
    return nil;
}


@end
