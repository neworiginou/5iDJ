//
//  MyHTTPRequest.h
//  Bestone
//
//  Created by Xuzhanya on 14-6-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

#define DataWithUTF8Code(_str) [_str dataUsingEncoding:NSUTF8StringEncoding]
#define MyHTTPRequestNoNetReachableErrorCode 9920

//----------------------------------------------------------

typedef NS_ENUM(NSUInteger, HTTPRequestType){
    HTTPRequestTypeGet,     //GET
    HTTPRequestTypePost,    //POST
    HTTPRequestTypePut      //PUT
};

//----------------------------------------------------------

@protocol MyHTTPRequestProtocol;

//----------------------------------------------------------

@protocol MyHTTPRequestDelegate

@optional

/**
 * 发送过程委托方法
 * @param request request是当前的请求对象
 * @param sendDataLenght sendDataLenght是已经发送的数据长度，单位是byte
 * @param expectedDataLength expectedDataLength是预期发送的数据总长度，单位是byte
 * @param speed speed是当前发送数据的速度，单位是byte/s
 */
- (void)httpRequest:(id<MyHTTPRequestProtocol>)request
didSendHTTPBodyDataLength:(long long)sendDataLenght
       expectedDataLength:(long long)expectedDataLength
            sendDataSpeed:(NSUInteger)speed;

/**
 * 收到响应的委托方法
 * @param request request是当前的请求对象
 * @param response response是收到的响应
 */
- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didReceiveResponse:(NSURLResponse *)response;

/**
 * 接收过程的委托方法
 * @param request request是当前的请求对象
 * @param receiveDataLength receiveDataLength是已经接收到数据的长度，单位是byte
 * @param receiveDataLength expectedDataLength是预期接收的数据总长度，单位是byte，如果总长度未知则此值为
 *                          NSURLResponseUnknownLength
 * @param speed speed是当前接收数据的速度，单位是byte/s
 */
-  (void)httpRequest:(id<MyHTTPRequestProtocol>)request
didReceiveDataLength:(long long)receiveDataLength
  expectedDataLength:(long long) expectedDataLength
    receiveDataSpeed:(NSUInteger)speed;

/**
 * 请求完成的委托方法
 * @param request request是当前的请求对象
 * @param data data是接收到的数据
 */
- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didSuccessRequestWithData:(NSData *)data;

/**
 * 请求失败的委托方法
 * @param request request是当前的请求对象
 * @param error error是请求失败的原因
 */
- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didFailedRequestWithError:(NSError *)error;

@end

//----------------------------------------------------------

//请求成功的block
typedef void(^HTTPRequestSuccessBlock)(NSData *);

//请求失败的block
typedef void(^HTTPRequestFailBlock)(NSError * error);

//----------------------------------------------------------

@protocol MyHTTPRequestProtocol

//开始请求
- (void)startRequest;

//取消请求
- (void)cancleRequest;

//是否正在请求
@property(nonatomic,readonly,getter = isRequesting) BOOL requesting;

//代理
@property(nonatomic,weak) id<MyHTTPRequestDelegate> delegate;

//成功block
@property(nonatomic,copy) HTTPRequestSuccessBlock successBlock;

//失败block
@property(nonatomic,copy) HTTPRequestFailBlock    failBlock;


@end

//----------------------------------------------------------


@interface MyHTTPRequest : NSObject <MyHTTPRequestProtocol>


//几个基本的GET请求初始化,默认未GET的初始化

- (id)initWithURL:(NSString *)url;                      //url

- (id)initWithURL:(NSString *)url                       //url
             path:(NSString *)path                      //路径
   queryArguments:(NSDictionary *)queryArguments;       //查询参数


//几个基本的POST请求初始化，默认为POST的初始化

- (id)initWithURL:(NSString *)url                       //url
    bodyArguments:(NSDictionary *)bodyArguments;        //body参数

- (id)initWithURL:(NSString *)url                       //url
             path:(NSString *)path                      //路径
    bodyArguments:(NSDictionary *)bodyArguments;        //body参数


//其他初始化方法

- (id)initWithURL:(NSString *)url                       //url
             path:(NSString *)path                      //路径
   queryArguments:(NSDictionary *)queryArguments        //查询参数
  headerArguments:(NSDictionary *)headerArguments       //头参数
    bodyArguments:(NSDictionary *)bodyArguments         //body参数
             type:(HTTPRequestType)type;                //类型


- (id)initWithURL:(NSString *)url                       //url
             path:(NSString *)path                      //路径(path1/path2/path3/...格式)
   queryArguments:(NSDictionary *)queryArguments        //查询参数
  headerArguments:(NSDictionary *)headerArguments       //头参数
         bodyData:(NSData *)bodyData                    //body数据
             type:(HTTPRequestType)type;                //类型

@end

//----------------------------------------------------------

@interface MyHTTPRequest (Mutable)

//设置类型
- (void)setRequestType:(HTTPRequestType)type;

//设置头参数
- (void)setHeaderArguments:(NSDictionary *)headerArguments;

//设置请求体数据
- (void)setBodyData:(NSData *)bodyData;

//通过body参数设置请求体数据
- (void)setBodyDataWithBodyArguments:(NSDictionary *)bodyArguments;

@end


