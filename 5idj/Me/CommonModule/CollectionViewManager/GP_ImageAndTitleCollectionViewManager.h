//
//  GP_ImageAndTitleCollectionViewManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-7.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "GP_BasicTitleAndImage.h"
#import "GP_PageLoadManager.h"

//----------------------------------------------------------

@class GP_BasicViewController;

//----------------------------------------------------------

@interface GP_ImageAndTitleCollectionViewManager : GP_PageLoadManager
                                                        <
                                                            UICollectionViewDelegateFlowLayout,
                                                            UICollectionViewDataSource
                                                        >


- (id)initWithCollectionView:(UICollectionView *)collectionView cellClass:(Class)cellClass;

@property(nonatomic,strong,readonly) UICollectionView * collectionView;

//@property(nonatomic,strong) NSArray * dataArray;

//添加数据
//- (void)insertDataFromDataArray:(NSArray *)dataArray;

@property(nonatomic,weak) id<SelectBasicTitleAndImageProtocol> delegate;

@end

//----------------------------------------------------------

@interface GP_ImageAndTitleCollectionViewManager (GP_BasicViewController)

- (id)initWithBasicViewController:(GP_BasicViewController *)viewController cellClass:(Class)cellClass;

@end

