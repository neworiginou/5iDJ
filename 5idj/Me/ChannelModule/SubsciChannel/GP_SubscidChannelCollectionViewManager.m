//
//  GP_SubChannelConllectionViewManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-8.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_SubscidChannelCollectionViewManager.h"
#import "GP_ChannelsManager.h"

//----------------------------------------------------------

@implementation GP_SubscidChannelCollectionViewManager

- (id)initWithBasicViewController:(GP_BasicViewController *)basicViewController
{
    return [self initWithBasicViewController:basicViewController cellClass:nil];
}

- (id)initWithCollectionView:(UICollectionView *)collectionView
                   cellClass:(__unsafe_unretained Class)cellClass
{
    self = [super initWithCollectionView:collectionView cellClass:[GP_SubscidChannelCell class]];
    
    if (self) {
        self.collectionView.allowsMultipleSelection = YES;
    }
    
    return self;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    assert(collectionView == self.collectionView);
    
    GP_SubscidChannelCell * cell = (GP_SubscidChannelCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if ([[GP_ChannelsManager defaultManager] isSubscibedChannel:[self.dataStoreManager dataAtIndexPath:indexPath]]) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        cell.selected = YES;
    }else{
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        cell.selected = NO;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    assert(collectionView == self.collectionView);
    
    [[GP_ChannelsManager defaultManager] subscibeChannels:@[[self.dataStoreManager dataAtIndexPath:indexPath]]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    assert(collectionView == self.collectionView);
    
    [[GP_ChannelsManager defaultManager] cancleSubscibeChannels:@[[self.dataStoreManager dataAtIndexPath:indexPath]]];
}


@end
