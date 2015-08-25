//
//  GP_MultipleServicePageLoadController.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-17.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ServicePageLoadController.h"

//----------------------------------------------------------

@interface GP_MultipleServicePageLoadController : GP_ServicePageLoadController

- (id)initWithPageSize:(NSUInteger)pageSize andPageCount:(NSUInteger)pageCount;

@property(nonatomic) NSUInteger currentSelectIndex;

@end
