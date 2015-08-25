//
//  MyDataStoreManager.h
//  5idj
//
//  Created by Xuzhanya on 14-10-9.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//


//---------------------------------------------

#import <Foundation/Foundation.h>

//---------------------------------------------

@protocol MyDataStoreManagerDelegate;

//---------------------------------------------

//数据储存管理器,分节储存数据，具有文件缓存机制，收到内存警告时会清除所有内存上的数据，需要时在从缓存读取
@interface MyDataStoreManager : NSObject

//通过设计每一个数据数目初始化
- (id)initWithDesignSectionDatasCount:(NSUInteger)designSectionDatasCount
                   sectionsCountLimit:(NSUInteger)sectionsCountLimit
                            cacheName:(NSString *)cacheName NS_DESIGNATED_INITIALIZER;

//每个节设计的数据数目50
@property(nonatomic,readonly) NSUInteger designSectionDatasCount;

//在内存中的最大节个数限制，不强制，默认为20,为0代表没有限制
@property(nonatomic,readonly) NSUInteger sectionsCountLimit;

//缓存名字
@property(nonatomic,strong,readonly) NSString * cacheName;

//总数据个数
@property(nonatomic,readonly) NSUInteger totalDatasCount;

//添加数据到最后一节，如果最后一节数据大于了designSectionDatasCount，将创建一个新节加入剩余数据
- (void)addDatas:(NSArray *)datas;

//添加一个节的数据
- (void)addSection:(NSArray *)datas;

//向某一个节添加数据
- (void)addDatas:(NSArray *)datas atSection:(NSUInteger)section;

//移除节
- (void)removeSection:(NSUInteger)section;

//移除数据
- (void)removeDatasAtSection:(NSUInteger)section andIndexSet:(NSIndexSet *)indexSet;

//获取有多少节
- (NSUInteger)numberOfSections;

//获取某个节的数据个数
- (NSUInteger)numberOfDatasAtSection:(NSUInteger)section;

//获取某个节的数据
- (NSArray *)datasAtSection:(NSUInteger)section;

//获取在section节索引为index的数据
- (id)dataAtSection:(NSUInteger)section andIndex:(NSUInteger)index;

//代理
@property(nonatomic,weak) id<MyDataStoreManagerDelegate> delegate;

//是否自动清除数据当收到内存警告,默认为YES
@property(nonatomic) BOOL autoClearDataWhenReceiveMemoryWarning;

//删除内存上的数据
- (void)clearDataInMemeory;

//清除缓存，清除时要确保无使用cacheName的实例存在，否则会发生错误
+ (void)clearCacheFileForName:(NSString *)cacheName;

@end

//---------------------------------------------

typedef NS_ENUM(int,MyDataStoreManagerDataChangeType){
    MyDataStoreManagerDataChangeTypeAdd,
    MyDataStoreManagerDataChangeTypeRemove
};

@protocol MyDataStoreManagerDelegate <NSObject>

@optional

////添加了数据
//- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager
//    didAddDatasAtSection:(NSUInteger)section
//             andIndexSet:(NSIndexSet *)indexSet;

//改变了数据
- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager
 didChangeDatasAtSection:(NSUInteger)section
             andIndexSet:(NSIndexSet *)indexSet
              changeType:(MyDataStoreManagerDataChangeType)type;



//添加了节
//- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager
//           didAddSection:(NSUInteger)section;

//改变了节
- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager
           didChangeSection:(NSUInteger)section
              changeType:(MyDataStoreManagerDataChangeType)type;

@end


@interface MyDataStoreManager (IndexPath)

- (id)dataAtIndexPath:(NSIndexPath *)indexPath;

- (void)removeDatasAtIndexPaths:(NSArray *)indexPaths;

@end
