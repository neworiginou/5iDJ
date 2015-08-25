//
//  GP_SearchHistoryManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import "GP_HistorySearchKeyword.h"

//----------------------------------------------------------

typedef NS_ENUM(NSInteger, SearchHistoryManagerChangeType) {
    SearchHistoryManagerChangeTypeInsert,
    SearchHistoryManagerChangeTypeDelete,
    SearchHistoryManagerChangeTypeMove,
    SearchHistoryManagerChangeTypeUpdate
};

UIKIT_EXTERN NSString * const SearchHistoryManagerWillChangeNotification;
UIKIT_EXTERN NSString * const SearchHistoryManagerChangeSectionNotification;
UIKIT_EXTERN NSString * const SearchHistoryManagerChangeSearchKeywordNotification;
UIKIT_EXTERN NSString * const SearchHistoryManagerDidChangeNotification;

UIKIT_EXTERN NSString * const SearchHistoryManagerChangeTypeInfoKey;
UIKIT_EXTERN NSString * const SearchHistoryManagerChangeSectionInfoKey;
UIKIT_EXTERN NSString * const SearchHistoryManagerChangeIndexPathInfoKey;
UIKIT_EXTERN NSString * const SearchHistoryManagerNewIndexPathInfoKey;


//----------------------------------------------------------

#define SearchHistoryManagerDomin @"SearchHistoryManagerDomin"
#define SearchHistoryMigrateDataErrorCode  1000

//----------------------------------------------------------

@interface GP_SearchHistoryManager : NSObject

//数据迁移
+ (void)migrateDataWithCompletedBlock:(void(^)(NSError * error))completedBlock;

+ (GP_SearchHistoryManager *)shareManager;

//添加搜索关键字
- (void)addSearchKeyword:(NSString *)keyword;

//删除搜索关键字
- (BOOL)removeHistorySearchKeyword:(GP_HistorySearchKeyword *)keyword error:(NSError **)error;

//删除所有的搜索历史
- (void)removeAllHistorySearchKeywords;


- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfSearchKeywordsAtSection:(NSUInteger)section;
- (GP_HistorySearchKeyword *)searchKeywordsAtIndexPath:(NSIndexPath *)indexPath;

@end
