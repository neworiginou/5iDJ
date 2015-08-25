//
//  NSError+GP_HTTPRequest.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-10.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "NSError+GP_HTTPRequest.h"

@implementation NSError (GP_HTTPRequest)

+ (NSError *)netErrorWithError:(NSError *)error
{
    return [NSError errorWithDomain:NetErrorDomin code:error.code userInfo:error.userInfo];
}

+ (NSError *)resultErrorWithErrorDescription:(NSString *)description
{
    return [NSError errorWithDomain:ResultErrorDomin code:0 userInfo:@{NSLocalizedDescriptionKey: description}];
}

@end
