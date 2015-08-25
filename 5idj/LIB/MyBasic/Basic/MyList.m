//
//  MyList.m
//  Bestone
//
//  Created by Xuzhanya on 14-6-19.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "MyList.h"

@interface _MyListNode : NSObject

- (id)initWithValue:(id)value;

@property(nonatomic,strong) _MyListNode * next;
@property(nonatomic,strong) id            value;

@end

@implementation _MyListNode

- (id)initWithValue:(id)value
{
    if (value == nil) {
        
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"value不能为nil"
                                        userInfo:nil];
    }
    
    self = [super init];
    
    if (self) {
        _value = value;
    }
    
    return self;
}

@end


@implementation MyList
{
    _MyListNode   * _head;
    _MyListNode   * _tail;
}


- (id)init
{
    self = [super init];
    
    if (self) {
        _head = _tail = nil;
        _count = 0;
    }
    
    return self;
}

- (void)addObjectAtHead:(id)obj
{
    _MyListNode * newNode = [[_MyListNode alloc] initWithValue:obj];
    
    if (_head) {
        newNode.next = _head;
        _head = newNode;
    }else{
        _head = _tail = newNode;
    }
    
    ++ _count;
}

- (void)addObjectAtTail:(id)obj
{
    _MyListNode * newNode = [[_MyListNode alloc] initWithValue:obj];
    
    if (_tail) {
        _tail.next = newNode;
        _tail = newNode;
    }else{
        _head = _tail = newNode;
    }
    
    ++ _count;
}

- (id)removeHeadObject
{
    if (_count == 0) {
        
        @throw [[NSException alloc] initWithName:@"方法调用错误"
                                          reason:@"无任何元素，无法移除"
                                        userInfo:nil];
        
    }
    
    _MyListNode * node = _head;
    
    _head = _head.next;
    
    if(!_head){
        _tail = nil;
    }
    
    -- _count;
    
    return node.value;
}

- (id)headObject
{
    return _head.value;
}

- (id)tailObject
{
    return _tail.value;
}

- (MyListPtr_t)headPtr
{
    return (MyListPtr_t)_head;
}

- (id)next:(MyListPtr_t *)ptr
{
    if (ptr == nil || * ptr == nil) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                          reason:@"指针不能为nil"
                                        userInfo:nil];
    }
    
    //获取当前元素
    id obj = [(_MyListNode *)(*ptr) value];
    
    //指向下一个位置
    *ptr =(MyListPtr_t)[(_MyListNode *)(*ptr) next];
    
    return obj;
}
@end
