//
//  MyDataStoreManager.m
//  5idj
//
//  Created by Xuzhanya on 14-10-9.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//---------------------------------------------

#import "MyDataStoreManager.h"
#import "help.h"
#import "MyPathManager.h"
#import "MacroDef.h"

//---------------------------------------------

static NSString * getCacheFileFolderPath(NSString * cacheName)
{
    return [[MyPathManager pathManagerWithFileFolder:@"MyDataStoreManagerCache"] pathForDirectory:cacheName];
}

static NSString * getCacheFilePath(NSString * cacheName,NSString * sectionID)
{
    cacheName = cacheName.length ? cacheName : @"defaultCache";
    
    return [getCacheFileFolderPath(cacheName) stringByAppendingPathComponent:sectionID];
}

//---------------------------------------------

@class _MyDataSection;

@protocol _MyDataSectionDelegate <NSObject>

- (void)dataSectionDidLoadInMemory:(_MyDataSection *)dataSection;

@end


//---------------------------------------------

@interface _MyDataSection : NSObject

- (id)initWithDesignDatasCount:(NSUInteger)designDatasCount cacheName:(NSString *)cacheName;

@property(nonatomic,readonly) NSUInteger datasCount;

- (void)addDatas:(NSArray *)datas;

- (void)removeDatasAtIndexSet:(NSIndexSet *)indexSet;

- (id)dataAtIndex:(NSUInteger)index;

- (void)removeDatasFromMemory;

//返回所有数据
- (NSArray *)datas;

//ID
@property(nonatomic,strong,readonly) NSString * ID;

//代理
@property(nonatomic,weak) id<_MyDataSectionDelegate> delegate;

@end

//---------------------------------------------

@implementation _MyDataSection
{
@private
    NSMutableArray * _datas;
    
    NSString * _cacheName;
    
    NSUInteger _designDatasCount;
}

@synthesize ID = _ID;

- (id)init
{
    return [self initWithDesignDatasCount:50 cacheName:nil];
}

- (id)initWithDesignDatasCount:(NSUInteger)designDatasCount cacheName:(NSString *)cacheName
{
    self = [super init];
    
    if(self){
        _cacheName = cacheName;
        _designDatasCount = designDatasCount;
    }
    
    return self;
}

#define CacheFilePath getCacheFilePath(_cacheName,[self ID])

- (void)dealloc
{
    if (_ID) {
        [[NSFileManager defaultManager] removeItemAtPath:CacheFilePath
                                                   error:NULL];
    }
}

- (NSMutableArray *)_datas
{
    if (!_datas) {
        
        _datas = [NSKeyedUnarchiver unarchiveObjectWithFile:CacheFilePath];
        
        if (!_datas) {
            _datas = [NSMutableArray arrayWithCapacity:_designDatasCount];
        }
        
        if (_datas.count != _datasCount) {
            @throw [[NSException alloc] initWithName:NSInternalInconsistencyException
                                              reason:@"临时的缓存数据丢失"
                                            userInfo:nil];
        }
        
        
        id<_MyDataSectionDelegate> delegate = self.delegate;
        ifRespondsSelector(delegate, @selector(dataSectionDidLoadInMemory:)){
            [delegate dataSectionDidLoadInMemory:self];
        }
        
    }
    
    return _datas;
}

- (NSString *)ID
{
    if(!_ID){
        _ID = getUniqueID();
    }
    
    return _ID;
}

- (void)addDatas:(NSArray *)datas
{
    if (datas.count == 0) {
        return;
    }
    
    NSMutableArray * __datas  = [self _datas];
    Protocol * codingProtocol = NSProtocolFromString(@"NSCoding");
    
    for (NSObject * data in datas) {
        
        //需遵循NSCoding协议
        if (![data conformsToProtocol:codingProtocol]) {
            @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"data必须遵循NSCoding协议"
                                        userInfo:nil];
        }
        
        [__datas addObject:data];
    }
    
    _datasCount = __datas.count;
}

- (void)removeDatasAtIndexSet:(NSIndexSet *)indexSet
{
    [[self _datas] removeObjectsAtIndexes:indexSet];
    
    _datasCount = [self _datas].count;
}

- (id)dataAtIndex:(NSUInteger)index
{
    return [self _datas][index];
}

- (void)removeDatasFromMemory
{
    if (_datas) {
        [NSKeyedArchiver archiveRootObject:_datas toFile:CacheFilePath];
        _datas = nil;
    }
}

- (NSArray *)datas
{
    return [NSArray arrayWithArray:[self _datas]];
}

@end

//---------------------------------------------


@interface MyDataStoreManager ()<NSCacheDelegate,_MyDataSectionDelegate>

@property(nonatomic,strong,readonly) NSMutableArray * sections;

@property(nonatomic,strong,readonly) NSCache * cache;

@end

//---------------------------------------------

@implementation MyDataStoreManager

@synthesize sections = _sections;
@synthesize cache    = _cache;

#pragma mark - life circle

- (id)init
{
    return [self initWithDesignSectionDatasCount:50
                              sectionsCountLimit:20
                                       cacheName:nil];
}

- (id)initWithDesignSectionDatasCount:(NSUInteger)designSectionDatasCount
                    sectionsCountLimit:(NSUInteger)sectionsCountLimit
                            cacheName:(NSString *)cacheName
{
    self = [super init];
    
    if (self) {
        _designSectionDatasCount = designSectionDatasCount;
        _sectionsCountLimit      = sectionsCountLimit;
        _cacheName               = [cacheName copy];
        
        self.autoClearDataWhenReceiveMemoryWarning = YES;
        
    }
    
    return self;
}

- (void)dealloc
{
    _cache.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)sections
{
    if (!_sections) {
        _sections = [NSMutableArray arrayWithCapacity:self.sectionsCountLimit];
    }
    
    return _sections;
}

- (NSCache *)cache
{
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        [_cache setCountLimit:self.sectionsCountLimit];
        _cache.delegate = self;
        
    }
    
    return _cache;
}

#pragma mark - data

- (_MyDataSection *)_createDataSectionWithDatas:(NSArray *)datas
{
    _MyDataSection  *dataSection = [[_MyDataSection alloc] initWithDesignDatasCount:self.designSectionDatasCount cacheName:self.cacheName];
    dataSection.delegate = self;
    [dataSection addDatas:datas];
    
    return dataSection;
}

- (void)_postAddSectionMessageWithSection:(NSUInteger)section
{
    assert(section == self.sections.count - 1);
    
    DebugLog(@"MyDataStoreManager",@"MyDataStoreManager add section %u",(unsigned int)section);
    
    [self _postChangeSectionMessageWithSection:section changeType:MyDataStoreManagerDataChangeTypeAdd];
}

- (void)_postRemoveSectionMessageWithSection:(NSUInteger)section
{
    DebugLog(@"MyDataStoreManager",@"MyDataStoreManager remove section %u",(unsigned int)section);
    
    [self _postChangeSectionMessageWithSection:section changeType:MyDataStoreManagerDataChangeTypeRemove];
}

- (void)_postChangeSectionMessageWithSection:(NSUInteger)section
                                  changeType:(MyDataStoreManagerDataChangeType)type
{
    id<MyDataStoreManagerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(dataStoreManager:didChangeSection:changeType:)){
        [delegate dataStoreManager:self
                  didChangeSection:section
                        changeType:type];
        
    }
}


- (void)_postAddDatasMessageWithSection:(NSUInteger)section andIndexSet:(NSIndexSet *)indexSet
{
    assert([indexSet indexGreaterThanOrEqualToIndex:[(_MyDataSection *)self.sections[section] datasCount]] == NSNotFound);
    
    DebugLog(@"MyDataStoreManager",@"MyDataStoreManager add datas at section %u and indexset %@",(unsigned int)section,indexSet);
    
    [self _postChangeDatasMessageWithSection:section
                                 andIndexSet:indexSet
                                  changeType:MyDataStoreManagerDataChangeTypeAdd];
}


- (void)_postRemoveDatasMessageWithSection:(NSUInteger)section andIndexSet:(NSIndexSet *)indexSet
{
     DebugLog(@"MyDataStoreManager",@"MyDataStoreManager remove datas at section %u and indexset %@",(unsigned int)section,indexSet);
    
    [self _postChangeDatasMessageWithSection:section
                                 andIndexSet:indexSet
                                  changeType:MyDataStoreManagerDataChangeTypeRemove];

}

- (void)_postChangeDatasMessageWithSection:(NSUInteger)section
                            andIndexSet:(NSIndexSet *)indexSet
                             changeType:(MyDataStoreManagerDataChangeType)type
{
    assert(section < self.sections.count);
    
    id<MyDataStoreManagerDelegate> delegate = self.delegate;
    ifRespondsSelector(delegate, @selector(dataStoreManager:didChangeDatasAtSection:andIndexSet:changeType:)){
        [delegate dataStoreManager:self
           didChangeDatasAtSection:section
                       andIndexSet:indexSet
                        changeType:type];
    }
}

- (void)addDatas:(NSArray *)datas
{
    //无元素
    if (datas.count == 0) {
        return;
    }
    
    _MyDataSection * lastDataSection = self.sections.lastObject;
    
    if (lastDataSection && (lastDataSection.datasCount < self.designSectionDatasCount || self.designSectionDatasCount == 0)) {
        
        NSUInteger addDatasCount = (self.designSectionDatasCount == 0) ? datas.count : self.designSectionDatasCount - lastDataSection.datasCount;
        addDatasCount = MIN(addDatasCount, datas.count);
        
        //添加数据
        if (addDatasCount != datas.count) {
            [self addDatas:[datas subarrayWithRange:NSMakeRange(0, addDatasCount)] atSection:self.sections.count - 1];
            datas = [datas subarrayWithRange:NSMakeRange(addDatasCount, datas.count - addDatasCount)];
        }else{
            [self addDatas:datas atSection:self.sections.count - 1];
            return;
        }
    }
    
    while (datas.count) {
        
        NSUInteger addDatasCount = self.designSectionDatasCount ? MIN(datas.count, self.designSectionDatasCount) : datas.count;
        
        if (addDatasCount != datas.count) {
            [self addSection:[datas subarrayWithRange:NSMakeRange(0, addDatasCount)]];
            datas = [datas subarrayWithRange:NSMakeRange(addDatasCount, datas.count - addDatasCount)];
        }else{
            [self addSection:datas];
            break;
        }
    }
    
}

- (void)addSection:(NSArray *)datas
{
    //无元素
    if (datas.count == 0) {
        return;
    }
    
    //添加数据
    [self.sections addObject:[self _createDataSectionWithDatas:datas]];
    
    //
    _totalDatasCount += datas.count;
    
    //发送消息
    [self _postAddSectionMessageWithSection:self.sections.count - 1];
}

- (void)addDatas:(NSArray *)datas atSection:(NSUInteger)section
{
    if (datas.count == 0) {
        return;
    }
    
    _MyDataSection * dataSection = self.sections[section];
    [dataSection addDatas:datas];
    
    _totalDatasCount += datas.count;
    
    [self _postAddDatasMessageWithSection:section andIndexSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(dataSection.datasCount - datas.count, datas.count)]];
}

- (void)removeSection:(NSUInteger)section
{
    _MyDataSection * dataSection = self.sections[section];
    [self.sections removeObjectAtIndex:section];
    
    _totalDatasCount -= dataSection.datasCount;
    
    [self _postRemoveSectionMessageWithSection:section];
}

- (void)removeDatasAtSection:(NSUInteger)section andIndexSet:(NSIndexSet *)indexSet
{
    if (indexSet.count == 0) {
        return;
    }
    
    _MyDataSection * dataSection = self.sections[section];
    [dataSection removeDatasAtIndexSet:indexSet];

    _totalDatasCount -= indexSet.count;
    
    //无元素了则删除节
    if (dataSection.datasCount == 0) {
        [self.sections removeObjectAtIndex:section];
        [self _postRemoveSectionMessageWithSection:section];
    }else{
        [self _postRemoveDatasMessageWithSection:section andIndexSet:indexSet];
    }
}


- (NSUInteger)numberOfSections
{
    return self.sections.count;
}

- (NSUInteger)numberOfDatasAtSection:(NSUInteger)section
{
    _MyDataSection * dataSection = self.sections[section];
    
    return [dataSection datasCount];
}

- (NSArray *)datasAtSection:(NSUInteger)section
{
    _MyDataSection * dataSection = self.sections[section];
    
    return [dataSection datas];
}

- (id)dataAtSection:(NSUInteger)section andIndex:(NSUInteger)index
{
    _MyDataSection * dataSection = self.sections[section];
    
    return [dataSection dataAtIndex:index];
}

- (void)dataSectionDidLoadInMemory:(_MyDataSection *)dataSection
{
    [self.cache setObject:dataSection forKey:dataSection.ID];
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    assert([obj isKindOfClass:[_MyDataSection class]]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [(_MyDataSection *)obj removeDatasFromMemory];
    });
}

+ (void)clearCacheFileForName:(NSString *)cacheName
{
    //删除数据
    [[NSFileManager defaultManager] removeItemAtPath:getCacheFileFolderPath(cacheName) error:nil];
}

- (void)clearDataInMemeory
{
    [_cache removeAllObjects];
}


- (void)setAutoClearDataWhenReceiveMemoryWarning:(BOOL)autoClearDataWhenReceiveMemoryWarning
{
    if (_autoClearDataWhenReceiveMemoryWarning != autoClearDataWhenReceiveMemoryWarning) {
        
        if (_autoClearDataWhenReceiveMemoryWarning) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        }
        
        _autoClearDataWhenReceiveMemoryWarning = autoClearDataWhenReceiveMemoryWarning;
        
        if (_autoClearDataWhenReceiveMemoryWarning) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didReceiveMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        }
    }
}

- (void)_didReceiveMemoryWarningNotification:(NSNotification *)notification
{
    [self clearDataInMemeory];
}


@end

@implementation MyDataStoreManager (IndexPath)

- (id)dataAtIndexPath:(NSIndexPath *)indexPath
{
    return [self dataAtSection:indexPath.section andIndex:indexPath.item];
}

- (void)removeDatasAtIndexPaths:(NSArray *)indexPaths
{
    for (NSIndexPath * indexPath in indexPaths) {
        
        if ([indexPath isKindOfClass:[NSIndexPath class]]) {
            [self removeDatasAtSection:indexPath.section andIndexSet:[NSIndexSet indexSetWithIndex:indexPath.item]];
        }else{
            @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                              reason:@"indexPaths数组内必须全为NSIndexPath及其子类的实例"
                                            userInfo:nil];
        }
    }
}

@end
