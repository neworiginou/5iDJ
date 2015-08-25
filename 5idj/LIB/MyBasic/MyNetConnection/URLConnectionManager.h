//
//  NetConnectManager.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-4.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

@class URLConnectionManager;

//----------------------------------------------------------

@protocol URLConnectionManagerDelegate

@optional

/**
 * 发送过程委托方法
 * @param manager manager是当前连接的管理对象
 * @param connection connection是当前连接
 * @param sendDataLenght sendDataLenght是已经发送的数据长度，单位是byte
 * @param expectedDataLength expectedDataLength是预期发送的数据总长度，单位是byte
 * @param speed speed是当前发送数据的速度，单位是byte/s
 */
- (void)urlConnectionManager:(URLConnectionManager *)manager
                  connection:(NSURLConnection *)connection
   didSendHTTPBodyDataLength:(long long)sendDataLenght
          expectedDataLength:(long long)expectedDataLength
               sendDataSpeed:(NSUInteger)speed;

/**
 * 收到响应的委托方法
 * @param manager manager是当前连接的管理对象
 * @param connection connection是当前连接
 * @param response response是收到的响应
 */
- (void)urlConnectionManager:(URLConnectionManager *)manager
                  connection:(NSURLConnection *)connection
          didReceiveResponse:(NSURLResponse *)response;

/**
 * 接收过程的委托方法
 * @param manager manager是当前连接的管理对象
 * @param connection connection是当前连接
 * @param receiveDataLength receiveDataLength是已经接收到数据的长度，单位是byte
 * @param receiveDataLength expectedDataLength是预期接收的数据总长度，单位是byte，如果总长度未知则此值为
 *                          NSURLResponseUnknownLength
 * @param speed speed是当前接收数据的速度，单位是byte/s
 */
- (void)urlConnectionManager:(URLConnectionManager *)manager
                  connection:(NSURLConnection *)connection
        didReceiveDataLength:(long long)receiveDataLength
          expectedDataLength:(long long)expectedDataLength
            receiveDataSpeed:(NSUInteger)speed;


/**
 * 请求完成的委托方法
 * @param manager manager是当前连接的管理对象
 * @param connection connection是当前连接
 * @param data data是接收到的数据
 */
- (void)urlConnectionManager:(URLConnectionManager *)manager
                  connection:(NSURLConnection *)connection
        didFinishLoadingData:(NSData *)data;

/**
 * 请求失败的委托方法
 * @param manager manager是当前连接的管理对象
 * @param connection connection是当前连接
 * @param error error是请求失败的原因
 */
- (void)urlConnectionManager:(URLConnectionManager *)manager
                  connection:(NSURLConnection *)connection
            didFailWithError:(NSError *)error;

@end

//----------------------------------------------------------

@interface URLConnectionManager : NSObject

/*
 *默认管理器
 */
+ (URLConnectionManager *)defaultManager;

/*
 *开始URL请求的连接，request不能为空，未空会发送失败消息
 */
- (void)startConnection:(id<URLConnectionManagerDelegate>)delegate request:(NSURLRequest *)request;

/*
 *取消delegate的所有URL请求的连接
 */
- (void)cancleConnection:(id<URLConnectionManagerDelegate>)delegate;

/*
 *取消delegate的request请求的连接，removeAll为YES，代表移除所有的request请求的连接
 */
- (void)cancleConnection:(id<URLConnectionManagerDelegate>)delegate request:(NSURLRequest *)request removeAll:(BOOL)removeAll;

/*
 *取消所有URL请求的连接
 */
- (void)cancleAllConnection;

/*
 *获取delegate所有的请求连接，无连接则返回nil
 */
- (NSArray *)connections:(id<URLConnectionManagerDelegate>)delegate;

@end
