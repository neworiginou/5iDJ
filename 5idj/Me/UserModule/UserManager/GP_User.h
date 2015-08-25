//
//  GP_User.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-26.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

@interface GP_User : NSObject

- (id)initWithInfoDic:(NSDictionary *)infoDic;

//用户名
@property(nonatomic,strong,readonly) NSString * userName;

//图像URL
@property(nonatomic,strong,readonly) NSString * avatarURL;

//token
@property(nonatomic,strong,readonly) NSString * token;

@end
