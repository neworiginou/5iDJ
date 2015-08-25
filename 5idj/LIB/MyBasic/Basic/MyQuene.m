//
//  MyQuene.m
//  shopping
//
//  Created by Xuzhanya on 13-12-6.
//  Copyright (c) 2013年 Xu zhanya. All rights reserved.
//

#import "MyQuene.h"
#import "MyList.h"
#import "help.h"

@implementation MyArrayQuene
{
    NSMutableArray     * _dataArray;
    NSUInteger           _head;
    NSUInteger           _tail;
    NSUInteger           _actualCapacity;
}

- (id)copy
{
    return [[MyArrayQuene alloc] initWithArrayQuene:self];
}

- (id)mutableCopy
{
    return [self copy];
}


- (id)init
{
    //默认大小为30
    return [self initWithCapacity:30];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    capacity = MAX(1.f, capacity);
    
    if (self = [super init]) {
        
        _head = _tail = 0;
        _actualCapacity = capacity + 1;
        
        _dataArray = [NSMutableArray arrayWithCapacity:_actualCapacity];
        for (NSUInteger i = 0; i < _actualCapacity; i ++) {
            [_dataArray addObject:[NSNull null]];
        }
    }
    return self;
}

- (id)initWithArrayQuene:(MyArrayQuene *)arrayQuene
{
    if (!arrayQuene) {
        return [self init];
    }else{
        
        if (self = [super init]) {
            
            _dataArray = [NSMutableArray arrayWithArray:arrayQuene->_dataArray];
            _head = arrayQuene->_head;
            _tail = arrayQuene->_tail;
            _actualCapacity = arrayQuene->_actualCapacity;
            
        }
        
        return self;
    }
    
}


- (void)pushToTail:(id)obj
{
    if ([self isFull]) {
        @throw [[NSException alloc] initWithName:NSRangeException reason:@"当前空间已满" userInfo:nil];
    }
    
    _dataArray[_tail] = obj;
    _tail = (_tail + 1) % _actualCapacity;
}


- (id)popFromHead
{
    if ([self isEmpty]) {
        @throw [[NSException alloc] initWithName:NSRangeException reason:@"当前无元素" userInfo:nil];
    }
    
    id headItem = _dataArray[_head];
    _dataArray[_head] = [NSNull null];
    _head = (_head + 1) % _actualCapacity;
    
    return headItem;
}

- (id)headItem
{
    if ([self isEmpty]) {
        return nil;
    }
    
    return _dataArray[_head];
}

- (NSUInteger)count
{
    return (_tail - _head + _actualCapacity) % _actualCapacity;
}

- (NSUInteger)capacity
{
    return _actualCapacity - 1;
}


- (BOOL)isEmpty
{
    return (_head == _tail);
}

- (BOOL)isFull
{
    return ([self count] == [self capacity]);
}

- (id)objAtIndex:(NSUInteger)index
{
    checkIndexAtRange(index, NSMakeRange(0, [self count]));
    
    return _dataArray[(_head + index)%_actualCapacity];
}

- (void)removeObjAtIndex:(NSUInteger)index
{
    NSUInteger count = [self count];
    
    checkIndexAtRange(index, NSMakeRange(0, count));
    
    NSUInteger actualIndex = (_head + index)%_actualCapacity;
    _dataArray[actualIndex] = [NSNull null];
    
    for (NSUInteger i = index + 1 ; i < count ; ++ i) {
        
        NSUInteger currentActualIndex = (_head + i)%_actualCapacity;
        NSUInteger beforeActualIndex = (_head + i - 1)%_actualCapacity;
        
        //交换
        id tmp = _dataArray[currentActualIndex];
        _dataArray[currentActualIndex] = _dataArray[beforeActualIndex];
        _dataArray[beforeActualIndex] = tmp;
    }

}

@end


@implementation MyListQuene
{
    MyList   * _list;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _list = [[MyList alloc] init];
    }
    
    return self;
}

- (void)pushToTail:(id)obj
{
    [_list addObjectAtTail:obj];
}

- (id)popFromHead
{
    return [_list removeHeadObject];
}

- (id)headItem
{
    return [_list headObject];
}

- (BOOL)isEmpty
{
    return _list.count == 0;
}

- (NSUInteger)count
{
    return _list.count;
}

- (MyArrayQuene *)changeToArrayQuene:(NSUInteger)appendCapacity
{
    MyArrayQuene * arrayQuene = [[MyArrayQuene alloc] initWithCapacity:_list.count + appendCapacity];
    
    MyListPtr_t ptr = [_list headPtr];
    
    while (ptr) {
        [arrayQuene pushToTail:[_list next:&ptr]];
    }
    
    return arrayQuene;
}


@end
