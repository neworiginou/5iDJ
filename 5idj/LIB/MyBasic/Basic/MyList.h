//
//  MyList.h
//  Bestone
//
//  Created by Xuzhanya on 14-6-19.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import <Foundation/Foundation.h>

OS_OBJECT_DECL(MyListPtr);

/**
 * 单链表
 */
@interface MyList : NSObject

- (void)addObjectAtHead:(id)obj;
- (void)addObjectAtTail:(id)obj;

- (id)removeHeadObject;

- (id)headObject;
- (id)tailObject;

- (MyListPtr_t)headPtr;

- (id)next:(MyListPtr_t *)ptr;

@property(nonatomic,readonly) NSUInteger count;

@end
