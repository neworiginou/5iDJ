//
//  GP_VideoFilterInfo.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoFilterInfo.h"

//----------------------------------------------------------

@implementation GP_VideoFilterInfo
{
    NSMutableArray * _idArray;
    NSMutableArray * _valueArray;
}

//@synthesize description = _description;

+ (NSArray *)videoFiltersWithDataInfos:(NSArray *)dataInfos;
{
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:dataInfos.count];
    
    for (NSDictionary * info in dataInfos) {
        [result addObject:[[self alloc] initWithInfoDic:info]];
    }
    
    return result;
}

- (id)initWithInfoDic:(NSDictionary *)infoDic
{
    self = [super init];
    
    if (self) {
        _key            = infoDic[GP_GP_FILTER_INFO_KEY];
        _descriptionStr = infoDic[GP_GP_FILTER_INFO_DESCRIPTION];
        
        NSArray * valueInfoArray = infoDic[GP_GP_FILTER_INFO_VALUES];
        
        _idArray    = [NSMutableArray arrayWithCapacity:valueInfoArray.count];
        _valueArray = [NSMutableArray arrayWithCapacity:valueInfoArray.count];
        
        for (NSDictionary * valueInfo in valueInfoArray) {
            [_idArray    addObject:valueInfo[GP_GP_FILTER_INFO_ID]];
            [_valueArray addObject:valueInfo[GP_GP_FILTER_INFO_VALUE]];
        }
        
        _selectValueIndex = (_idArray.count) ? 0 : NoSelectIndex;
    }
    
    return self;
}

- (NSString *)description
{
    return _descriptionStr;
}


- (NSUInteger)valuesCount
{
    return _valueArray.count;
}

- (NSInteger)idForValueAtIndex:(NSUInteger)index
{
    return [_idArray[index] integerValue];
}

- (NSString *)valueAtIndex:(NSUInteger)index
{
    return _valueArray[index];
}

- (void)setSelectValueIndex:(NSInteger)selectValueIndex
{
    assert(selectValueIndex == NoSelectIndex || (selectValueIndex >= 0 && selectValueIndex < _idArray.count));
    
    _selectValueIndex = selectValueIndex;
}

- (NSDictionary *)selectVideoFilterInfo
{
    if (_selectValueIndex == NoSelectIndex) {
        return nil;
    }
    
    return [NSDictionary dictionaryWithObject:_idArray[_selectValueIndex] forKey:_key];
}



@end
