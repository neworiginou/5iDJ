//
//  GP_BasicTitleAndImage.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-27.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

@interface GP_BasicTitleAndImage : NSObject <NSCoding>

+ (NSArray *)dataArrayWithInfoArray:(NSArray *)infoArray;

- (id)initWithInfoDic:(NSDictionary *)info;

- (id)initWithID:(NSInteger)ID title:(NSString *)title;

- (id)initWithID:(NSInteger)ID
           title:(NSString *)title
        imageURL:(NSString *)imageURL;

- (id)initWithID:(NSInteger)ID
           title:(NSString *)title
        imageURL:(NSString *)imageURL
           brief:(NSString *)brief;

//id
@property(nonatomic,readonly)        NSInteger  ID;
//标题
@property(nonatomic,strong,readonly) NSString * title;
//图片URL
@property(nonatomic,strong,readonly) NSString * imageURL;
//简介
@property(nonatomic,strong,readonly) NSString * brief;

@end

//----------------------------------------------------------


//选择协议定义
SelectProtocolDefine(BasicTitleAndImage, GP_BasicTitleAndImage)

#define SafeSendSelectBasicTitleAndImageMsg(_delegate,_data)              \
SafeSendSelectMsg(_delegate,_data,BasicTitleAndImage)


