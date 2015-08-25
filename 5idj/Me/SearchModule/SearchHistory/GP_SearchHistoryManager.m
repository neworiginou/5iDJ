 //
//  GP_SearchHistoryManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------
#import "GP_SearchHistoryManager.h"
//----------------------------------------------------------

NSString * const SearchHistoryManagerWillChangeNotification          =
    @"SearchHistoryManagerWillChangeNotification";
NSString * const SearchHistoryManagerChangeSectionNotification       =
    @"SearchHistoryManagerChangeSectionNotification";
NSString * const SearchHistoryManagerChangeSearchKeywordNotification =
    @"SearchHistoryManagerChangeSearchKeywordNotification";
NSString * const SearchHistoryManagerDidChangeNotification           =
    @"SearchHistoryManagerDidChangeNotification";

NSString * const SearchHistoryManagerChangeTypeInfoKey      =
    @"SearchHistoryManagerChangeTypeInfoKey";
NSString * const SearchHistoryManagerChangeSectionInfoKey   =
    @"SearchHistoryManagerChangeSectionInfoKey";
NSString * const SearchHistoryManagerChangeIndexPathInfoKey =
    @"SearchHistoryManagerChangeIndexPathInfoKey";
NSString * const SearchHistoryManagerNewIndexPathInfoKey    =
    @"SearchHistoryManagerNewIndexPathInfoKey";


//----------------------------------------------------------

@interface GP_SearchHistoryManager () <NSFetchedResultsControllerDelegate>

@property(nonatomic,strong,readonly) NSManagedObjectModel * managedObjectModel;
@property(nonatomic,strong,readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property(nonatomic,strong,readonly) NSManagedObjectContext * managedObjectContext;
@property(nonatomic,strong,readonly) NSFetchedResultsController * fetchedResultsController;

@property(nonatomic,strong,readonly) NSNumber * sectionsCount;

@end

//----------------------------------------------------------

static GP_SearchHistoryManager * _shareSearchHistoryManager = nil;

//----------------------------------------------------------

@implementation GP_SearchHistoryManager

@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext       = _managedObjectContext;
@synthesize fetchedResultsController   = _fetchedResultsController;
@synthesize sectionsCount              = _sectionsCount;


#define HistorySearchKeywordsFilePath() \
[[[MyPathManager alloc] initWithFileFolder:@"HistorySearchKeywords"] pathForFile:@"searchKeywords.data"]

+ (void)migrateDataWithCompletedBlock:(void(^)(NSError * error))completedBlock
{
    NSString * oldDataFilePath = HistorySearchKeywordsFilePath();
    
    //存在文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldDataFilePath]) {
        NSArray * historySearchKeywords = [NSArray arrayWithContentsOfFile:oldDataFilePath];
        //存在数据
        if (historySearchKeywords.count) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
                NSManagedObjectContext * managedObjectContext = [[self shareManager] managedObjectContext];
                
                for (NSString * keyword in historySearchKeywords) {
                    GP_HistorySearchKeyword * searchKeyword = [NSEntityDescription insertNewObjectForEntityForName:@"GP_HistorySearchKeyword" inManagedObjectContext:managedObjectContext];
                    searchKeyword.searchKey = keyword;
                    searchKeyword.timeStamp = [NSDate date];
                }
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[NSFileManager defaultManager] removeItemAtPath:oldDataFilePath error:NULL];
                    
                    NSError * error = nil;
                    if(![managedObjectContext save:&error]){
                        
                        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                        [userInfo setValue:@"搜索记录数据迁移发生错误,数据可能丢失" forKey:NSLocalizedDescriptionKey];
                        [userInfo setValue:error forKey:NSUnderlyingErrorKey];
                        error = [NSError errorWithDomain:SearchHistoryManagerDomin code:SearchHistoryMigrateDataErrorCode userInfo:userInfo];
                        
                        DebugLog(PlayHistoryManagerDomin,@"搜索记录数据迁移失败.error = %@",error);
                    }
                    
                    if (completedBlock) {
                        completedBlock(error);
                    }
                    
                });
            });
            
            return;
        }else{
            [[NSFileManager defaultManager] removeItemAtPath:oldDataFilePath error:NULL];
        }
    }
    
    if (completedBlock) {
        completedBlock(nil);
    }
}


#pragma mark - life circle

+ (GP_SearchHistoryManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareSearchHistoryManager = [[GP_SearchHistoryManager alloc] init];
    });
    
    return _shareSearchHistoryManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return _shareSearchHistoryManager ?: [super allocWithZone:zone];
}

- (id)init
{
    if (_shareSearchHistoryManager) {
        return _shareSearchHistoryManager;
    }
    
    self = [super init];
    
    return self;
}


#pragma mark - database object

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSString * modelPath = [[NSBundle mainBundle] pathForResource:@"GP_HistroySearchKeywords" ofType:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    }
    
    return _managedObjectModel;
}

- (NSString *)_pathForDataBaseFile
{
    return [[[MyPathManager alloc] initWithFileFolder:@"HistorySearchKeywords"] pathForFile:@"searchKeywords.sqlite"];
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
            
            DebugLog(SearchHistoryManagerDomin,@"数据库打开失败.error = %@",error);
            
            //移除所有记录
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GP_HistorySearchKeyword" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchBatchSize:20];
    
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        
        NSFetchRequest * fetchRequest = [self _createFetchRequest];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"searchKeywordsCache"];
        _fetchedResultsController.delegate = self;
        
        NSError * error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            DebugLog(SearchHistoryManagerDomin, @"获取搜索关键字失败.error = %@",error);
            showErrorMessage(nil, error, @"获取搜索关键字失败");
        }
    }
    
    return _fetchedResultsController;
}

#pragma mark - data handle

- (void)addSearchKeyword:(NSString *)keyword
{
    if (keyword.length) {
    
        GP_HistorySearchKeyword * searchKeyword = [self _searchKeywordForKeyword:keyword];
    
        //没找到则创建一个新的
        if (!searchKeyword) {
            searchKeyword = [NSEntityDescription insertNewObjectForEntityForName:@"GP_HistorySearchKeyword" inManagedObjectContext:self.managedObjectContext];
            searchKeyword.searchKey = keyword;
        }
        searchKeyword.timeStamp = [NSDate date];
        
        NSError * error = nil;
        if (![self.managedObjectContext save:&error]) {
            DebugLog(SearchHistoryManagerDomin, @"添加搜索记录失败.error = %@",error);
            showErrorMessage(nil, error, @"添加搜索记录失败");
        }
        
    }else{
        NSLog(@"传入长度为0的keyword");
    }
}

- (GP_HistorySearchKeyword *)_searchKeywordForKeyword:(NSString *)keyword
{
    GP_HistorySearchKeyword * searchKeyword = nil;
    
    if (keyword) {
        
        NSFetchRequest *fetchRequest = [self _createFetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchKey == %@", keyword];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *searchKeywords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            NSLog(@"查询记录失败,error = %@",error);
        }else{
            searchKeyword = [searchKeywords firstObject];
        }
    }else{
        NSLog(@"传入值为nil的keyword");
    }
    
    return searchKeyword;
}

- (BOOL)removeHistorySearchKeyword:(GP_HistorySearchKeyword *)keyword error:(NSError *__autoreleasing *)error
{
    if (keyword) {
        
        //删除
        [self.managedObjectContext deleteObject:keyword];
        
        NSError * tmpError = nil;
        if (![self.managedObjectContext save:&tmpError]) {
            DebugLog(SearchHistoryManagerDomin, @"删除搜索记录失败.error = %@",tmpError);
            if (error) *error = tmpError;
            
            return NO;
        }
        
    }else{
        NSLog(@"传入值为nil的keyword");
    }
    
    return YES;
}

- (void)removeAllHistorySearchKeywords
{
    NSInteger sectionsCount = [self numberOfSections];
    
    if (sectionsCount != 0) {
        
        _fetchedResultsController.delegate = nil;
        _fetchedResultsController = nil;
        _managedObjectContext = nil;
        
        NSURL * storeURL = [NSURL fileURLWithPath:[self _pathForDataBaseFile]];
        removePersistentStore(self.persistentStoreCoordinator,storeURL);
        _persistentStoreCoordinator = nil;
        
        //发送通知
        [self _postWillChangeNotification];
        
        while ((-- sectionsCount) >= 0) {
            [self _postChangeSectionNotificationWithSection:sectionsCount changeType:SearchHistoryManagerChangeTypeDelete];
        }
        
        [self _postDidChangeNotification];
    }
}

#pragma mark - get data

#define ObjectsCountForFetchedResults(_fetchedResults) \
    [(id<NSFetchedResultsSectionInfo>)[[_fetchedResults sections] firstObject] numberOfObjects]

- (NSUInteger)numberOfSections
{
    return [self.sectionsCount unsignedIntegerValue];
}

- (NSNumber *)sectionsCount
{
    if (!_sectionsCount) {
        _sectionsCount = @(ObjectsCountForFetchedResults(self.fetchedResultsController) ? 1 : 0);
    }
    
    return _sectionsCount;
}

- (NSUInteger)numberOfSearchKeywordsAtSection:(NSUInteger)section
{
    checkIndexAtRange(section, NSMakeRange(0, [self numberOfSections]));
    return ObjectsCountForFetchedResults(self.fetchedResultsController);
}

- (GP_HistorySearchKeyword *)searchKeywordsAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - fetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self _postDidChangeNotification];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self _postDidChangeNotification];
}

#if DEBUG

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    DebugLog(SearchHistoryManagerDomin, @"不可能调用该方法");
    assert(NO);
}

#endif

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            
            if (ObjectsCountForFetchedResults(controller) == 1) {
                [self _postChangeSectionNotificationWithSection:newIndexPath.section
                                                   changeType:SearchHistoryManagerChangeTypeInsert];
            }else{
                [self _postChangeRecordNotificationWithType:SearchHistoryManagerChangeTypeInsert
                                              atIndexPath:nil
                                             newIndexPath:newIndexPath];
            }
            
            break;
            
        case NSFetchedResultsChangeDelete:
            
            if (ObjectsCountForFetchedResults(controller) != 0) {
                [self _postChangeRecordNotificationWithType:SearchHistoryManagerChangeTypeDelete
                                              atIndexPath:indexPath
                                             newIndexPath:nil];
            }else{
                [self _postChangeSectionNotificationWithSection:indexPath.section
                                                   changeType:SearchHistoryManagerChangeTypeDelete];
            }
            
            break;
        
        case NSFetchedResultsChangeMove:
            [self _postChangeRecordNotificationWithType:SearchHistoryManagerChangeTypeMove
                                          atIndexPath:indexPath
                                         newIndexPath:newIndexPath];
            
            break;
        
        case NSFetchedResultsChangeUpdate:
            [self _postChangeRecordNotificationWithType:SearchHistoryManagerChangeTypeUpdate
                                          atIndexPath:indexPath
                                         newIndexPath:nil];
            
            break;
            
        default:
            break;
    }
}


#pragma mark - notification

- (void)_postWillChangeNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SearchHistoryManagerWillChangeNotification
                                                        object:self];
}

- (void)_postDidChangeNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SearchHistoryManagerDidChangeNotification
                                                        object:self];
}

- (void)_postChangeSectionNotificationWithSection:(NSUInteger)section
                                     changeType:(SearchHistoryManagerChangeType)changeType
{
    _sectionsCount = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:
                                                            SearchHistoryManagerChangeSectionNotification
                                                        object:self
                                                      userInfo:@{
                                                                 SearchHistoryManagerChangeTypeInfoKey : @(changeType),
                                                                 SearchHistoryManagerChangeSectionInfoKey : @(section)
                                                                 }];
}

- (void)_postChangeRecordNotificationWithType:(SearchHistoryManagerChangeType)changeType
                                atIndexPath:(NSIndexPath *)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath;
{
    
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:@(changeType) forKey:SearchHistoryManagerChangeTypeInfoKey];
    if (indexPath != nil) {
        [userInfo setValue:indexPath forKey:SearchHistoryManagerChangeIndexPathInfoKey];
    }
    if (newIndexPath != nil) {
        [userInfo setValue:newIndexPath forKey:SearchHistoryManagerNewIndexPathInfoKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:
                                                        SearchHistoryManagerChangeSearchKeywordNotification
                                                        object:self
                                                      userInfo:userInfo];
}

@end
