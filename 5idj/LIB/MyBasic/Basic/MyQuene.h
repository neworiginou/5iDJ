//
//  MyQuene.h
//  shopping
//
//  Created by Xuzhanya on 13-12-6.
//  Copyright (c) 2013年 Xu zhanya. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyQueneProtocol

//向队尾压入元素
- (void)pushToTail:(id)obj;

//从队头移出元素
- (id)popFromHead;

//队头元素
- (id)headItem;

//元素个数
- (NSUInteger)count;

//是否为空
- (BOOL)isEmpty;


@end


@interface MyArrayQuene : NSObject <MyQueneProtocol>

//初始化
- (id)initWithCapacity:(NSUInteger) capacity;

- (id)initWithArrayQuene:(MyArrayQuene *)arrayQuene;

//总容量
- (NSUInteger)capacity;

//是否已满
- (BOOL)isFull;

//返回索引为index的元素
- (id)objAtIndex:(NSUInteger)index;

//移除索引为index的元素
- (void)removeObjAtIndex:(NSUInteger)index;

@end


@interface MyListQuene : NSObject <MyQueneProtocol>


- (MyArrayQuene *)changeToArrayQuene:(NSUInteger)appendCapacity;

@end

