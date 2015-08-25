//
//  GP_HistoryManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-4.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//


//----------------------------------------------------------

#import "GP_PlayHistoryManager.h"
#import "NSDate+MyCategory.h"

//----------------------------------------------------------

@implementation GP_HistroyVideoRecord

- (id)initWithVideo:(GP_Video *)video playDuration:(NSTimeInterval)playDuration playFinish:(BOOL)finished
{
    self = [super init];
    
    if (self) {
        
        _ID           = video.ID;
        _title        = video.title;
        _imageURL     = video.imageURL;
        _playDuration = roundl(playDuration);
        _playFinish   = finished;
        _playDate     = [NSDate timeIntervalSinceReferenceDate];
        
    }
    
    return self;
}

- (GP_Video *)toVideo
{
    GP_Video * video = [[GP_Video alloc] initWithID:_ID title:_title imageURL:_imageURL];
    
    return video;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        
        _ID           = [aDecoder decodeIntegerForKey:@"_ID"];
        _title        = [aDecoder decodeObjectForKey :@"_title"];
        _imageURL     = [aDecoder decodeObjectForKey :@"_imageURL"];
        _playDuration = [aDecoder decodeDoubleForKey :@"_playDuration"];
        _playDate     = [aDecoder decodeDoubleForKey :@"_playDate"];
        _playFinish   = [aDecoder decodeBoolForKey   :@"_playFinish"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_ID           forKey:@"_ID"];
    [aCoder encodeObject :_title        forKey:@"_title"];
    [aCoder encodeObject :_imageURL     forKey:@"_imageURL"];
    [aCoder encodeDouble :_playDuration forKey:@"_playDuration"];
    [aCoder encodeDouble :_playDate     forKey:@"_playDate"];
    [aCoder encodeBool   :_playFinish   forKey:@"_playFinish"];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[GP_HistroyVideoRecord class]]) {
        return _ID == [(typeof(self))object ID];
    }
    
    return NO;
}

@end

//----------------------------------------------------------

@implementation GP_VideoPlayRecord (GP_HistroyVideoRecord)

- (void)setValuesWithHistroyVideoRecord:(GP_HistroyVideoRecord *)record
{
    if (record) {
        
        self.id           = [NSString stringWithFormat:@"%li",(long)record.ID];
        self.title        = record.title;
        self.imageURL     = record.imageURL;
        self.playDuration = [NSNumber numberWithDouble:record.playDuration];
        self.playDate     = [NSDate dateWithTimeIntervalSinceReferenceDate:record.playDate];
        self.playFinish   = [NSNumber numberWithBool:record.playFinish];
    }
}

@end


//----------------------------------------------------------

NSString * const PlayHistoryManagerWillChangeNotification        =
    @"PlayHistoryManagerWillChangeNotification";
NSString * const PlayHistoryManagerDidChangeNotification         =
    @"PlayHistoryManagerDidChangeNotification";
NSString * const PlayHistoryManagerChangeRecordNotification      =
    @"PlayHistoryManagerChangeRecordNotification";
NSString * const PlayHistoryManagerChangeSectionNotification     =
    @"PlayHistoryManagerChangeSectionNotification";
NSString * const PlayHistoryManagerDidReloadNotification         =
    @"PlayHistoryManagerDidReloadNotification";
//NSString * const PlayHistoryManagerEmptyStatusChangeNotification =
//    @"PlayHistoryManagerEmptyStatusChangeNotification";

NSString * const PlayHistoryManagerChangeTypeInfoKey      = @"PlayHistoryManagerChangeTypeInfoKey";
NSString * const PlayHistoryManagerChangeSectionInfoKey   = @"PlayHistoryManagerChangeSectionInfoKey";
NSString * const PlayHistoryManagerChangeIndexPathInfoKey = @"PlayHistoryManagerChangeIndexPathInfoKey";
NSString * const PlayHistoryManagerNewIndexPathInfoKey    = @"PlayHistoryManagerNewIndexPathInfoKey";

//----------------------------------------------------------

@interface GP_PlayHistoryManager () <NSFetchedResultsControllerDelegate>

@property(nonatomic,strong,readonly) NSManagedObjectModel * managedObjectModel;
@property(nonatomic,strong,readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property(nonatomic,strong,readonly) NSManagedObjectContext * managedObjectContext;

@property(nonatomic,strong,readonly) NSFetchedResultsController * todayRecordesFetchedResults;
@property(nonatomic,strong,readonly) NSFetchedResultsController * pastRecordesFetchedResults;

//今天日期
@property(nonatomic,strong,readonly) NSDate   * todayDate;

//节数目
@property(nonatomic,strong,readonly) NSNumber * sectionsCount;


@end

//----------------------------------------------------------

static GP_PlayHistoryManager * defautManager = nil;

//----------------------------------------------------------

@implementation GP_PlayHistoryManager

@synthesize managedObjectModel          = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;
@synthesize managedObjectContext        = _managedObjectContext;
@synthesize todayRecordesFetchedResults = _todayRecordesFetchedResults;
@synthesize pastRecordesFetchedResults  = _pastRecordesFetchedResults;
@synthesize todayDate                   = _todayDate;
@synthesize sectionsCount               = _sectionsCount;


+ (GP_PlayHistoryManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defautManager = [[super allocWithZone:nil] init];
    });
    
    return defautManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self defaultManager];
}

- (id)init
{
    if (defautManager) {
        return  defautManager;
    }
    
    self = [super init];
    
    return self;
}

#define HistoryRecordesFilePath() \
    [[[MyPathManager alloc] initWithFileFolder:@"HistoryRecord"] pathForFile:@"recordes.data"]


+ (void)migrateDataWithCompletedBlock:(void (^)(NSError *))completedBlock
{
    NSString * oldDataPath = HistoryRecordesFilePath();
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldDataPath]) {
        
        id data = [NSKeyedUnarchiver unarchiveObjectWithFile:oldDataPath];
        
        if ([data respondsToSelector:@selector(count)] && [data count] != 0) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                GP_PlayHistoryManager * defaultManager = [self defaultManager];
                
                if ([data isKindOfClass:[NSDictionary class]]) {
                    for (GP_HistroyVideoRecord * record in [data allValues]) {
                        [defaultManager _insertVideoPlayRecordWithHistroyVideoRecord:record];
                    }
                }else if ([data isKindOfClass:[NSArray class]]){
                    for (GP_HistroyVideoRecord * record in data) {
                        [defaultManager _insertVideoPlayRecordWithHistroyVideoRecord:record];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[NSFileManager defaultManager] removeItemAtPath:oldDataPath error:NULL];
                    
                    NSError * error = nil;
                    if (![[defaultManager managedObjectContext] save:&error]) {
                        
                        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                        [userInfo setValue:@"播放记录数据迁移发生错误,数据可能丢失" forKey:NSLocalizedDescriptionKey];
                        [userInfo setValue:error forKey:NSUnderlyingErrorKey];
                        error = [NSError errorWithDomain:PlayHistoryManagerDomin code:PlayHistoryMigrateDataErrorCode userInfo:userInfo];
                        
                        DebugLog(PlayHistoryManagerDomin,@"播放记录数据迁移失败.error = %@",error);
                    }
                    
                    if (completedBlock) {
                        completedBlock(error);
                    }
                });
            });
            
            return;
            
        }else{
            [[NSFileManager defaultManager] removeItemAtPath:oldDataPath error:NULL];
        }
        
    }
    
    if (completedBlock) {
        completedBlock(nil);
    }
}

- (void)_insertVideoPlayRecordWithHistroyVideoRecord:(GP_HistroyVideoRecord *)record
{
    if (record) {
        
        GP_VideoPlayRecord * playRecord = [NSEntityDescription insertNewObjectForEntityForName:@"GP_VideoPlayRecord" inManagedObjectContext:self.managedObjectContext];
        
        [playRecord setValuesWithHistroyVideoRecord:record];
    }
}



- (NSString *)_pathForDataBaseFile
{
    return [[MyPathManager pathManagerWithFileFolder:@"HistoryRecord"] pathForFile:@"VideoPlayHistory.splite"];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        
        NSString * modelPath = [[NSBundle mainBundle] pathForResource:@"GP_PlayRecordes" ofType:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL URLWithString:modelPath]];
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSURL * storeURL = [NSURL fileURLWithPath:[self _pathForDataBaseFile]];
        
        NSDictionary * option = @{NSMigratePersistentStoresAutomaticallyOption : @YES ,
                                  NSInferMappingModelAutomaticallyOption : @YES};
        
        NSError * error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:storeURL
                                                            options:option
                                                              error:&error]) {
            
            DebugLog(PlayHistoryManagerDomin,@"数据库打开失败.error = %@",error);
            
            //移除文件
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
            
            //抛出异常
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"数据库打开失败"
                                         userInfo:nil];
            
        }
        
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
    }
    
    return _managedObjectContext;
}

- (NSFetchRequest *)_createFetchRequest
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GP_VideoPlayRecord" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playDate"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    [fetchRequest setFetchBatchSize:20];
    
    return fetchRequest;
}


- (NSDate *)todayDate
{
    if (!_todayDate) {
        
        NSDate * currentDate = [NSDate date];
        _todayDate = [currentDate dateWithSameDay];
        
        //改变了天数则重新加载
        [self performSelector:@selector(_reoloadRecodes)
                   withObject:nil
                   afterDelay:SecPerDay - [currentDate timeIntervalSinceDate:_todayDate] + 1];
    }
    
    return _todayDate;
}

- (void)_reoloadRecodes
{
    _todayDate = nil;
    _todayRecordesFetchedResults.delegate = nil;
    _todayRecordesFetchedResults = nil;
    _pastRecordesFetchedResults.delegate = nil;
    _pastRecordesFetchedResults = nil;
    
    [self _postDidReloadNotification];
}

- (NSFetchedResultsController *)todayRecordesFetchedResults
{
    if (!_todayRecordesFetchedResults) {
        
        NSFetchRequest *fetchRequest = [self _createFetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playDate >= %@", self.todayDate];
        [fetchRequest setPredicate:predicate];
        
        [NSFetchedResultsController deleteCacheWithName:@"todayPlayHistoryCache"];
        _todayRecordesFetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"todayPlayHistoryCache"];
        _todayRecordesFetchedResults.delegate = self;
        
        NSError * error = nil;
        if (![_todayRecordesFetchedResults performFetch:&error]) {
            
            DebugLog(PlayHistoryManagerDomin, @"获取今日记录的查询错误.error = %@",error);
            showErrorMessage(nil, error, @"获取播放记录数据失败");
        }
    }
    
    return _todayRecordesFetchedResults;
}

- (NSFetchedResultsController *)pastRecordesFetchedResults
{
    if (!_pastRecordesFetchedResults) {
        
        NSFetchRequest *fetchRequest = [self _createFetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playDate < %@", self.todayDate];
        [fetchRequest setPredicate:predicate];
        
        [NSFetchedResultsController deleteCacheWithName:@"pastPlayHistoryCache"];
        _pastRecordesFetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"pastPlayHistoryCache"];
        _pastRecordesFetchedResults.delegate = self;
        
        NSError * error = nil;
        if (![_pastRecordesFetchedResults performFetch:&error]) {
            
            DebugLog(PlayHistoryManagerDomin, @"获取今日记录的查询错误.error = %@",error);
            showErrorMessage(nil, nil, @"获取播放记录数据失败");
        }
    }
    
    return _pastRecordesFetchedResults;
}

#define mark - data handel

- (void)addRecord:(GP_Video *)video playDuration:(NSTimeInterval)playDuration playFinish:(BOOL)finished
{
    if (video) {
        
        //存在删除，这里不能直接更新，会导致数据不正确
        GP_VideoPlayRecord * record = [self recordForVideo:video];
        if (record != nil) {
            [self.managedObjectContext deleteObject:record];
        }
        
        //生成记录
        record = [NSEntityDescription insertNewObjectForEntityForName:@"GP_VideoPlayRecord"
                                               inManagedObjectContext:self.managedObjectContext];
        [record setValuesWithVideo:video];
        [record setPlayDate:[NSDate date]];
        record.playDuration = @(playDuration);
        record.playFinish   = @(finished);
        
        
        NSError * error = nil;
        if (![self.managedObjectContext save:&error]) {
            DebugLog(PlayHistoryManagerDomin, @"添加播放记录失败.error = %@",error);
            showErrorMessage(nil, nil, @"添加播放记录失败");
        }
        
    }else{
        NSLog(@"addRecord方法，传入值为nil的video");
    }
}

- (BOOL)removeRecord:(GP_VideoPlayRecord *)record error:(NSError *__autoreleasing *)error
{
    if (record) {
        
        //删除
        [self.managedObjectContext deleteObject:record];
        
        NSError * tmpError = nil;
        if (![self.managedObjectContext save:&tmpError]) {
            
            DebugLog(PlayHistoryManagerDomin, @"删除播放记录失败.error = %@",tmpError);
            if (error) *error = tmpError;
            
            return NO;
        }
        
    }else{
        NSLog(@"removeRecord方法，传入值为nil的record");
    }
    
    return YES;
}

- (GP_VideoPlayRecord *)recordForVideo:(GP_Video *)video
{
    GP_VideoPlayRecord * record = nil;
    
    if (video) {
        
        NSFetchRequest * fetchRequest = [self _createFetchRequest];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id == %@",@(video.ID)];
        [fetchRequest setPredicate:predicate];
        
        NSError * error = nil;
        NSArray * recordes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            NSLog(@"查询记录失败,error = %@",error);
        }else{
            record = [recordes firstObject];
        }
        
    }else{
        NSLog(@"recordForVideo方法，传入值为nil的record");
    }
    
    return record;
}

- (void)removeAllRecodes
{    
    NSInteger sectionsCount = [self numberOfSections];
 
    if(sectionsCount != 0){
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(_reoloadRecodes)
                                                   object:nil];
        
        _todayDate = nil;
        _todayRecordesFetchedResults.delegate = nil;
        _todayRecordesFetchedResults = nil;
        _pastRecordesFetchedResults.delegate = nil;
        _pastRecordesFetchedResults = nil;
        _managedObjectContext = nil;
        
        //删除持续化储存
        NSURL * storeURL = [NSURL fileURLWithPath:[self _pathForDataBaseFile]];
        removePersistentStore(self.persistentStoreCoordinator,storeURL);
        _persistentStoreCoordinator = nil;
        
        [self _postWillChangeNotification];
        
        while ((-- sectionsCount) >= 0) {
            [self _postChangeSectionNotificationWithSection:sectionsCount
                                               changeType:PlayHistoryManagerChangeTypeDelete];
        }
        
        [self _postDidChangeNotification];
        
//        [self _postEmptyStatusChangeNotification];
        
//        //发送reloa消息
//        [self _postDidReloadNotification];
    }
}


#pragma mark - get data

#define ObjectsCountForFetchedResults(_fetchedResults) \
    [(id<NSFetchedResultsSectionInfo>)[[_fetchedResults sections] firstObject] numberOfObjects]

- (NSNumber *)sectionsCount
{
    if (!_sectionsCount) {
        
        NSUInteger sectionsCount = 0;
        if (ObjectsCountForFetchedResults(self.todayRecordesFetchedResults) != 0) {
            ++ sectionsCount;
        }
        if (ObjectsCountForFetchedResults(self.pastRecordesFetchedResults) != 0) {
            ++ sectionsCount;
        }
        
        _sectionsCount = @(sectionsCount);
    }

    return _sectionsCount;
}

- (NSUInteger)numberOfSections
{
    return [self.sectionsCount unsignedIntegerValue];
}

- (BOOL)isEmpty
{
    return [self numberOfSections] == 0;
}

- (NSFetchedResultsController *)_fetchedResultsControllerForSection:(NSUInteger)section
{
    NSUInteger sectionsCount = [self numberOfSections];
    checkIndexAtRange(section, NSMakeRange(0, sectionsCount));
    
    if (section == 0 && ObjectsCountForFetchedResults(self.todayRecordesFetchedResults)) {
        return self.todayRecordesFetchedResults;
    }else{
        return self.pastRecordesFetchedResults;
    }
}

- (NSUInteger)numberOfRecordAtSection:(NSUInteger)section
{
    return ObjectsCountForFetchedResults([self _fetchedResultsControllerForSection:section]);
}

- (GP_VideoPlayRecord *)recordAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController * fetchedResultsController = [self _fetchedResultsControllerForSection:indexPath.section];
    
    return [fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
}

- (NSString *)titleAtSection:(NSUInteger)section
{
    NSFetchedResultsController * fetchedResultsController = [self _fetchedResultsControllerForSection:section];
    return (fetchedResultsController == self.todayRecordesFetchedResults) ? @"今日" : @"以往";
}

#pragma mark - fetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self _postWillChangeNotification];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self _postDidChangeNotification];
    
//    if ([self sectionsCount]) {
//        [self _postEmptyStatusChangeNotification];
//    }
    
}

#if DEBUG

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    DebugLog(PlayHistoryManagerDomin, @"不可能调用该方法");
    assert(NO);
}

#endif

- (NSUInteger)_sectionForFechedResultsController:(NSFetchedResultsController *)controller
{
    //删除时需要返回被删除的一行，这种情况也满足
    if (controller == self.todayRecordesFetchedResults) {
        return 0;
    }else{
        return ObjectsCountForFetchedResults(self.todayRecordesFetchedResults) ? 1 : 0;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSUInteger section = [self _sectionForFechedResultsController:controller];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            
            if (ObjectsCountForFetchedResults(controller) == 1) {
                [self _postChangeSectionNotificationWithSection:section
                                                   changeType:PlayHistoryManagerChangeTypeInsert];
            }else{
                [self _postChangeRecordNotificationWithType:PlayHistoryManagerChangeTypeInsert
                                              atIndexPath:nil
                                             newIndexPath:[NSIndexPath indexPathForItem:newIndexPath.item inSection:section]];
            }
            
            break;
        
        case NSFetchedResultsChangeDelete:
            
            if (ObjectsCountForFetchedResults(controller)) {
                [self _postChangeRecordNotificationWithType:PlayHistoryManagerChangeTypeDelete
                                              atIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:section]
                                             newIndexPath:nil];
            }else{
                [self _postChangeSectionNotificationWithSection:section
                                                   changeType:PlayHistoryManagerChangeTypeDelete];
            }
            
            break;
            
        case NSFetchedResultsChangeMove:
            
            [self _postChangeRecordNotificationWithType:PlayHistoryManagerChangeTypeMove
                                          atIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:section]
                                         newIndexPath:[NSIndexPath indexPathForItem:newIndexPath.item inSection:section]];
            break;
            
        case NSFetchedResultsChangeUpdate:
            
            [self _postChangeRecordNotificationWithType:PlayHistoryManagerChangeTypeUpdate
                                          atIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:section]
                                         newIndexPath:nil];
            
            break;
            
        default:
            break;
    }
}

#pragma mark - notification

- (void)_postWillChangeNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayHistoryManagerWillChangeNotification object:self];
}

- (void)_postDidChangeNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayHistoryManagerDidChangeNotification object:self];
}


- (void)_postChangeSectionNotificationWithSection:(NSUInteger)section
                                     changeType:(PlayHistoryManagerChangeType)changeType
{
    _sectionsCount = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayHistoryManagerChangeSectionNotification
                                                        object:self
                                                      userInfo:@{
                                                                 PlayHistoryManagerChangeTypeInfoKey : @(changeType),
                                                                 PlayHistoryManagerChangeSectionInfoKey : @(section)
                                                                 }];
}

- (void)_postChangeRecordNotificationWithType:(PlayHistoryManagerChangeType)changeType
                                atIndexPath:(NSIndexPath *)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath;
{
    
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:@(changeType) forKey:PlayHistoryManagerChangeTypeInfoKey];
    if (indexPath != nil) {
        [userInfo setValue:indexPath forKey:PlayHistoryManagerChangeIndexPathInfoKey];
    }
    if (newIndexPath != nil) {
        [userInfo setValue:newIndexPath forKey:PlayHistoryManagerNewIndexPathInfoKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayHistoryManagerChangeRecordNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)_postDidReloadNotification
{
    _sectionsCount = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayHistoryManagerDidReloadNotification
                                                        object:self];
}

//- (void)_postEmptyStatusChangeNotification
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:
//                                                        PlayHistoryManagerEmptyStatusChangeNotification
//                                                        object:self];
//}



@end
