//
//  NSError+GP_HTTPRequest.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

//错误域
#define NetErrorDomin               @"NetErrorDomin"
#define ResultErrorDomin            @"ResultErrorDomin"

//----------------------------------------------------------

@interface NSError (GP_HTTPRequest)

+ (NSError *)netErrorWithError:(NSError *)error;
+ (NSError *)resultErrorWithErrorDescription:(NSString *)description;

@end
