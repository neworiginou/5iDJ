//
//  GP_VideoFilterInfo.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

#define NoSelectIndex       -1

//----------------------------------------------------------

@interface GP_VideoFilterInfo : NSObject

+ (NSArray *)videoFiltersWithDataInfos:(NSArray *)dataInfos;

- (id)initWithInfoDic:(NSDictionary *)infoDic;

@property(nonatomic,strong,readonly) NSString * key;

@property(nonatomic,strong,readonly) NSString * descriptionStr;

@property(nonatomic,readonly)        NSUInteger valuesCount;

@property(nonatomic)                 NSInteger  selectValueIndex;

- (NSInteger)idForValueAtIndex:(NSUInteger)index;

- (NSString *)valueAtIndex:(NSUInteger)index;

- (NSDictionary *)selectVideoFilterInfo;

@end
