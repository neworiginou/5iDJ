//
//  GP_User.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-26.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_User.h"

//----------------------------------------------------------

@implementation GP_User

- (id)initWithInfoDic:(NSDictionary *)infoDic
{
    self = [super init];
    
    if (self) {
        
        _userName  = infoDic[GP_GP_LOGIN_USERNAME];
        _avatarURL = infoDic[GP_GP_LOGIN_USERIMGURL];
        _token     = infoDic[GP_GP_LOGIN_TOKEN];
    }
    
    return self;
}

@end
