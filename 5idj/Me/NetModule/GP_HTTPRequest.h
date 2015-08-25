//
//  GP_NetRequest.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//---------------------------------------

#import <Foundation/Foundation.h>

//---------------------------------------

@class GP_HTTPRequest;

//---------------------------------------

@protocol GP_HTTPRequestDelegate <MyHTTPRequestDelegate>


//成功
- (void)httpRequest:(id<MyHTTPRequestProtocol>)netRequest didSuccessRequestWithDataObject:(id)dataObject;

@end


//---------------------------------------
@interface GP_HTTPRequest : NSObject <MyHTTPRequestProtocol>

//Get方法
- (id)initWithAPIRoute:(NSString *)apiRoute
                  path:(NSString *)path
        queryArguments:(NSDictionary *)queryArguments;

//Post方法
- (id)initWithAPIRoute:(NSString *)apiRoute
                  path:(NSString *)path
         bodyArguments:(NSDictionary *)bodyArguments;

- (id)initWithAPIRoute:(NSString *)apiRoute
                  path:(NSString *)path
        queryArguments:(NSDictionary *)queryArguments
         bodyArguments:(NSDictionary *)bodyArguments;

//自定义方法
- (id)initWithAPIRoute:(NSString *)apiRoute                  //url
                  path:(NSString *)path                      //路径
        queryArguments:(NSDictionary *)queryArguments        //查询参数
         bodyArguments:(NSDictionary *)bodyArguments         //body参数
                  type:(HTTPRequestType)type;                //类型


//代理
@property(nonatomic,weak) id<GP_HTTPRequestDelegate> delegate;


@end
