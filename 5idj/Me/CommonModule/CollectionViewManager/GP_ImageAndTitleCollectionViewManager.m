//
//  GP_ImageAndTitleCollectionViewManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-7.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ImageAndTitleCollectionViewManager.h"
#import "GP_BasicImageAndTitleCell.h"
#import "GP_BasicViewController.h"

//----------------------------------------------------------

@implementation GP_ImageAndTitleCollectionViewManager
{
    __weak GP_BasicViewController * _basciViewController;
    
    MyRefreshControl * _topRefreshControl;
    MyRefreshControl * _bottomLoadControl;
}

@synthesize collectionView = _collectionView;

- (id)init
{
    return [self initWithCollectionView:nil cellClass:nil];
}

- (id)initWithCollectionView:(UICollectionView *)collectionView cellClass:(Class)cellClass
{
    cellClass = cellClass ?: [GP_BasicImageAndTitleCell class];
    
    assert([cellClass isSubclassOfClass:[GP_BasicImageAndTitleCell class]]);
    
    if (!collectionView) {
        
        UICollectionViewFlowLayout * collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        collectionViewFlowLayout.itemSize = [cellClass cellSize];
        collectionViewFlowLayout.minimumInteritemSpacing = 6.f;
        collectionViewFlowLayout.minimumLineSpacing = 0.f;
        
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenSize().width, screenSize().height) collectionViewLayout:collectionViewFlowLayout];
    }
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    //注册
    [collectionView registerClass:cellClass forCellWithReuseIdentifier:defaultReuseDef];
    
    if (self = [super initWithScrollView:collectionView]) {
        _collectionView = collectionView;
    }
    
    return self;
    
}

- (MyRefreshControl *)topRefreshControl
{
    if (!_topRefreshControl) {
        
        id<GP_PageLoadDelegate> pageLoadDelegate = self.pageLoadDelegate;
        ifRespondsSelector(pageLoadDelegate, @selector(objectNeedTopRefreshControl:)){
            if ([pageLoadDelegate objectNeedTopRefreshControl:self]) {
                
                GP_BasicViewController * basciViewController = _basciViewController;
                
                if (basciViewController) {
                    _topRefreshControl = basciViewController.refreshControl;
                    [_topRefreshControl addTarget:self action:@selector(refreshControlHandle) forControlEvents:UIControlEventValueChanged];
                }else{
                    _topRefreshControl = [super topRefreshControl];
                }
            }
        }
    }
    
    return _topRefreshControl;
}

- (MyRefreshControl *)bottomLoadControl
{
    if (!_bottomLoadControl) {
        
        id<GP_PageLoadDelegate> pageLoadDelegate = self.pageLoadDelegate;
        ifRespondsSelector(pageLoadDelegate, @selector(objectNeedBottomLoadControl:)){
            if ([pageLoadDelegate objectNeedBottomLoadControl:self]) {
                
                GP_BasicViewController * basciViewController = _basciViewController;
                
                if (basciViewController) {
                    _bottomLoadControl = basciViewController.loadControl;
                    [_bottomLoadControl addTarget:self action:@selector(loadControlHandle) forControlEvents:UIControlEventValueChanged];
                }else{
                    _bottomLoadControl = [super bottomLoadControl];
                }
            }
        }
    }
    
    return _bottomLoadControl;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    assert(collectionView == self.collectionView);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0.f, 6.f, 0.f, 6.f);
    
    if (section == 0) {
        insets.top = 6.f;
    }
    
    return insets;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    assert(collectionView == self.collectionView);
    
    return [self.dataStoreManager numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    assert(collectionView == self.collectionView);
    
    return [self.dataStoreManager numberOfDatasAtSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    assert(collectionView == self.collectionView);
    
//    static NSString * cellDef = BasicImageAndTitleCellDef;
    
    GP_BasicImageAndTitleCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:defaultReuseDef forIndexPath:indexPath];
    
    [cell updateWithBasicTitleAndImage:[self.dataStoreManager dataAtIndexPath:indexPath]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    assert(collectionView == self.collectionView);
    
    SafeSendSelectBasicTitleAndImageMsg(self.delegate, [self.dataStoreManager dataAtIndexPath:indexPath]);
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


#pragma mark - pageLoad

- (void)endRefreshDataStoreManager:(MyDataStoreManager *)dataStoreManager
{
    [super endRefreshDataStoreManager:dataStoreManager];
    
    [self.collectionView reloadData];
}

- (void)endLoadDatas:(NSArray *)datas
{
    [self.collectionView performBatchUpdates:^{
        [super endLoadDatas:datas];
    } completion:nil];
}


#pragma mark - data store delegate

- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager
        didChangeSection:(NSUInteger)section
              changeType:(MyDataStoreManagerDataChangeType)type
{
    if (dataStoreManager == self.dataStoreManager) {
        
        if (type == MyDataStoreManagerDataChangeTypeAdd) {
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:section]];
        }else{
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:section]];
        }
    }
    
}

//- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager didAddSection:(NSUInteger)section
//{
//    if (dataStoreManager == self.dataStoreManager) {
//        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:section]];
//    }
//}

- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager
 didChangeDatasAtSection:(NSUInteger)section
             andIndexSet:(NSIndexSet *)indexSet
              changeType:(MyDataStoreManagerDataChangeType)type
{
    
    if (dataStoreManager == self.dataStoreManager) {
        
        if (type == MyDataStoreManagerDataChangeTypeAdd) {
            [self.collectionView insertItemsAtIndexPaths:indexPathsFromIndexSet(section, indexSet)];
        }else{
            [self.collectionView deleteItemsAtIndexPaths:indexPathsFromIndexSet(section, indexSet)];
        }
    }
    
}

//- (void)dataStoreManager:(MyDataStoreManager *)dataStoreManager
//    didAddDatasAtSection:(NSUInteger)section
//             andIndexSet:(NSIndexSet *)indexSet
//{
//    if (dataStoreManager == self.dataStoreManager) {
//        [self.collectionView insertItemsAtIndexPaths:indexPathsFromIndexSet(section, indexSet)];
//    }
//}


@end


//----------------------------------------------------------


@implementation GP_ImageAndTitleCollectionViewManager (GP_BasicViewController)

- (id)initWithBasicViewController:(GP_BasicViewController *)viewController
                        cellClass:(__unsafe_unretained Class)cellClass
{
    _basciViewController = viewController;
    
    return [self initWithCollectionView:viewController.collectionView cellClass:cellClass];
}

@end
