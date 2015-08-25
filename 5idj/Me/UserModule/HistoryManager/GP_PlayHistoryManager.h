//
//  GP_HistoryManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-4.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "GP_VideoPlayRecord.h"

//----------------------------------------------------------
//兼容老版本
//-------------------------
@interface GP_HistroyVideoRecord : NSObject <NSCoding>

@property(nonatomic,readonly)        NSInteger         ID;
@property(nonatomic,strong,readonly) NSString        * title;
@property(nonatomic,strong,readonly) NSString        * imageURL;
@property(nonatomic,readonly)        NSTimeInterval    playDate;
@property(nonatomic,readonly)        NSTimeInterval    playDuration;
@property(nonatomic,readonly)        BOOL              playFinish;

- (GP_Video *)toVideo;


@end

@interface GP_VideoPlayRecord (GP_HistroyVideoRecord)

- (void)setValuesWithHistroyVideoRecord:(GP_HistroyVideoRecord *)record;

@end


//----------------------------------------------------------

typedef NS_ENUM(NSInteger, PlayHistoryManagerChangeType) {
    PlayHistoryManagerChangeTypeInsert,
    PlayHistoryManagerChangeTypeDelete,
    PlayHistoryManagerChangeTypeMove,
    PlayHistoryManagerChangeTypeUpdate
};

UIKIT_EXTERN NSString * const PlayHistoryManagerWillChangeNotification;
UIKIT_EXTERN NSString * const PlayHistoryManagerChangeRecordNotification;
UIKIT_EXTERN NSString * const PlayHistoryManagerChangeSectionNotification;
UIKIT_EXTERN NSString * const PlayHistoryManagerDidChangeNotification;
UIKIT_EXTERN NSString * const PlayHistoryManagerDidReloadNotification;
//UIKIT_EXTERN NSString * const PlayHistoryManagerEmptyStatusChangeNotification;

UIKIT_EXTERN NSString * const PlayHistoryManagerChangeTypeInfoKey;
UIKIT_EXTERN NSString * const PlayHistoryManagerChangeSectionInfoKey;
UIKIT_EXTERN NSString * const PlayHistoryManagerChangeIndexPathInfoKey;
UIKIT_EXTERN NSString * const PlayHistoryManagerNewIndexPathInfoKey;

//----------------------------------------------------------

#define PlayHistoryManagerDomin @"PlayHistoryManagerDomin"
#define PlayHistoryMigrateDataErrorCode  1000

//----------------------------------------------------------

@interface GP_PlayHistoryManager : NSObject

//数据迁移
+ (void)migrateDataWithCompletedBlock:(void(^)(NSError * error))completedBlock;

+ (GP_PlayHistoryManager *)defaultManager;

//添加播放记录
- (void)addRecord:(GP_Video *)video playDuration:(NSTimeInterval)playDuration playFinish:(BOOL)finished;

//
- (GP_VideoPlayRecord *)recordForVideo:(GP_Video *)video;

//清除记录
- (BOOL)removeRecord:(GP_VideoPlayRecord *)record error:(NSError **)error;

//清空所有记录
- (void)removeAllRecodes;


//记录的总数
- (BOOL)isEmpty;
//

- (NSString *)titleAtSection:(NSUInteger)section;

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRecordAtSection:(NSUInteger)section;
- (GP_VideoPlayRecord *)recordAtIndexPath:(NSIndexPath *)indexPath;

@end

