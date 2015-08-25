//
//  UIView+ReuseDef.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "UIView+ReuseDef.h"
#import  <objc/runtime.h>

//----------------------------------------------------------

static char UIViewReuseIdentifierKey;

@implementation UIView (ReuseDef)

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self init];
    
    if (self) {
        objc_setAssociatedObject(self, &UIViewReuseIdentifierKey, reuseIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return self;
}

- (NSString *)reuseIdentifier
{
    return objc_getAssociatedObject(self, &UIViewReuseIdentifierKey);
}

@end
