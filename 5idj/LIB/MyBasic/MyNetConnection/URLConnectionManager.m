//
//  NetConnectManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-4.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "URLConnectionManager.h"
#import "MacroDef.h"

//----------------------------------------------------------

@interface _URLConnectionData : NSObject

- (id)initWithDelegate:(id<URLConnectionManagerDelegate>)delegate URLConnection:(NSURLConnection *)urlConnection;

@property(nonatomic,strong,readonly) id<URLConnectionManagerDelegate> connectionDelegate;
@property(nonatomic,strong,readonly) NSURLConnection  * urlConnection;
@property(nonatomic,strong,readonly) NSMutableData    * resultData;
@property(nonatomic,strong)          NSDate           * lastSendDataDate;
@property(nonatomic,strong,readonly) NSDate           * lastReceiveDataDate;
@property(nonatomic,readonly) long long expectedDataLength;

//收到响应
- (void)receiveResponse:(NSURLResponse *)response;

//返回接收数据的速度byte/s
- (NSUInteger)receiveData:(NSData *)data;

//返回发送速度byte/s
- (NSUInteger)speedForSendData:(NSUInteger)bytesWritten;

@end

//----------------------------------------------------------

@implementation _URLConnectionData
@synthesize expectedDataLength = _expectedDataLength;

- (id)initWithDelegate:(id<URLConnectionManagerDelegate>)delegate URLConnection:(NSURLConnection *)urlConnection
{
    if (self = [super init]) {
        _connectionDelegate = delegate;
        _urlConnection  = urlConnection;
        _resultData = [NSMutableData data];
        _expectedDataLength = NSURLResponseUnknownLength;
    }
    
    return self;
}

- (void)receiveResponse:(NSURLResponse *)response
{
    assert(response);
    
    _expectedDataLength = response.expectedContentLength;
}

- (NSUInteger)speedForSendData:(NSUInteger)bytesWritten
{
    NSUInteger sendDataSpeed = 0;
    NSDate * now =  [NSDate date];
    
    //计算速度
    if (_lastSendDataDate) {
        
//        NSLog(@"bytesWritten = %i , time = %f",(int)bytesWritten ,[now timeIntervalSinceDate:_lastSendDataDate]);
        
        sendDataSpeed = bytesWritten / [now timeIntervalSinceDate:_lastSendDataDate];
        
//        NSLog(@" bytesWritten = %i speed = %i byte/s ",(int)bytesWritten,(int)sendDataSpeed);
    }
    
    //记录时间
    _lastSendDataDate = now;
    
    return sendDataSpeed;
}

- (NSUInteger)receiveData:(NSData *)data
{
    assert(data);
    
    NSUInteger receiveDataSpeed = 0;
    NSDate * now =  [NSDate date];
    
    //计算速度
    if (_lastReceiveDataDate) {
        receiveDataSpeed = data.length / [now timeIntervalSinceDate:_lastReceiveDataDate];
    }
    
    //记录时间
    _lastReceiveDataDate = now;
    
    //扩充数据
    [_resultData appendData:data];
    
    return receiveDataSpeed;
}


@end

//----------------------------------------------------------


@interface URLConnectionManager()< NSURLConnectionDataDelegate >

@end

//----------------------------------------------------------

@implementation URLConnectionManager
{
    //代理到数据的映射表
    NSMutableDictionary    *_delegateToDataDicMap;
    //URL连接到数据的映射表
    NSMutableDictionary    *_urlConnectionToDataMap;
}

+ (URLConnectionManager *)defaultManager
{
    static URLConnectionManager * defaultManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [URLConnectionManager new];
    });
    
    return defaultManager;
}

- (id)init
{
    if (self = [super init]) {
        _delegateToDataDicMap = [NSMutableDictionary dictionary];
        _urlConnectionToDataMap = [NSMutableDictionary dictionary];
    }
    
    return self;
}


//发送错误消息
#define sendFailMsg(_delegate,_connection,_error)                                                \
do{                                                                                              \
    ifRespondsSelector(_delegate, @selector(urlConnectionManager:connection:didFailWithError:))  \
        [_delegate urlConnectionManager:self connection:_connection didFailWithError:_error];    \
}while(0)

//初始化错误
#define URLConnectionError(_code,_description)          \
    ERROR(@"URLConnectionError", _code, _description)


- (void)startConnection:(id<URLConnectionManagerDelegate>)delegate request:(NSURLRequest *)request
{
    if (!request) {
        sendFailMsg(delegate, nil, URLConnectionError(0, @"请求不能为空!!"));
        return;
    }
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
  
    if (urlConnection) {
        _URLConnectionData *connectionData  = [[_URLConnectionData alloc] initWithDelegate:delegate URLConnection:urlConnection];
        
        [_urlConnectionToDataMap setObject:connectionData  forKey:NSNumberWithPointer(urlConnection)];
        
        NSNumber *delegateKey = NSNumberWithPointer(delegate);
        NSMutableDictionary *dataDic = [_delegateToDataDicMap objectForKey:delegateKey];
        
        if (!dataDic) {
            dataDic = [NSMutableDictionary dictionary];
            [_delegateToDataDicMap setObject:dataDic forKey:delegateKey];
        }
        
        [dataDic setObject:connectionData forKey:NSNumberWithPointer(connectionData)];
        
        //开始连接
        [urlConnection start];
    }
}


- (void)cancleConnection:(id<URLConnectionManagerDelegate>)delegate
{
    [self cancleConnection:delegate request:nil removeAll:YES];
}

- (void)cancleConnection:(id<URLConnectionManagerDelegate>)delegate request:(NSURLRequest *)request removeAll:(BOOL)removeAll
{
    NSNumber *delegateKey = NSNumberWithPointer(delegate);
    NSMutableDictionary *dataDic = [_delegateToDataDicMap objectForKey:delegateKey];
    
    if (dataDic) {
        
        for (_URLConnectionData *connectionData  in dataDic.allValues) {
            
            if (request == nil || [[connectionData .urlConnection currentRequest] isEqual:request]) {
                
                [connectionData .urlConnection cancel];
                [_urlConnectionToDataMap removeObjectForKey:NSNumberWithPointer(connectionData .urlConnection)];
                
                [dataDic removeObjectForKey:NSNumberWithPointer(connectionData)];
                
                if (!removeAll){
                    break;
                }
            }
        }
        
        //无元素则移除
        if (dataDic.count == 0) {
            [_delegateToDataDicMap removeObjectForKey:delegateKey];
        }
    }
}

- (void)cancleAllConnection
{
    for (_URLConnectionData *connectionData  in _urlConnectionToDataMap.allValues) {
        [connectionData.urlConnection cancel];
    }
    
    [_urlConnectionToDataMap removeAllObjects];
    [_delegateToDataDicMap removeAllObjects];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
                                               totalBytesWritten:(NSInteger)totalBytesWritten
                                       totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    _URLConnectionData *connectionData  = [_urlConnectionToDataMap objectForKey:NSNumberWithPointer(connection)];
    
    if (connectionData) {
        
        //发送消息给代理
        ifRespondsSelector(connectionData.connectionDelegate, @selector(urlConnectionManager:connection:didSendHTTPBodyDataLength:expectedDataLength:sendDataSpeed:)){
            
            [connectionData.connectionDelegate urlConnectionManager:self
                                                         connection:connection
                                          didSendHTTPBodyDataLength:totalBytesWritten
                                                 expectedDataLength:totalBytesExpectedToWrite
                                                      sendDataSpeed:[connectionData speedForSendData:bytesWritten]];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _URLConnectionData *connectionData  = [_urlConnectionToDataMap objectForKey:NSNumberWithPointer(connection)];
    
    if (connectionData) {
        
        ifRespondsSelector(connectionData.connectionDelegate, @selector(urlConnectionManager:connection:didReceiveResponse:))  {
            [connectionData .connectionDelegate urlConnectionManager:self connection:connection didReceiveResponse:response];
        }
        
        [connectionData receiveResponse:response];
    }
}

//移除连接数据
#define RemoveConnectionData(connectionData)                                                        \
{                                                                                                   \
    [_urlConnectionToDataMap removeObjectForKey:NSNumberWithPointer(connectionData.urlConnection)]; \
    NSNumber *delegateKey = NSNumberWithPointer(connectionData.connectionDelegate);                 \
    NSMutableDictionary *dataDic = [_delegateToDataDicMap objectForKey:delegateKey];                \
    [dataDic removeObjectForKey:NSNumberWithPointer(connectionData)];                               \
    if (dataDic.count == 0) {                                                                       \
        [_delegateToDataDicMap removeObjectForKey:delegateKey];                                     \
    }                                                                                               \
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _URLConnectionData *connectionData = [_urlConnectionToDataMap objectForKey:NSNumberWithPointer(connection)];
    
    if (connectionData) {
        
        RemoveConnectionData(connectionData);
        
        //发送错误消息
        sendFailMsg(connectionData.connectionDelegate, connection, URLConnectionError(error.code,DescriptionWithError(error)));
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    _URLConnectionData *connectionData  = [_urlConnectionToDataMap objectForKey:NSNumberWithPointer(connection)];
    
    if (connectionData ) {
        
        NSUInteger speed = [connectionData receiveData:data];
        
        //发送消息给代理
        ifRespondsSelector(connectionData.connectionDelegate, @selector(urlConnectionManager:connection:didReceiveDataLength:expectedDataLength:receiveDataSpeed:)){
            
            [connectionData.connectionDelegate urlConnectionManager:self
                                                         connection:connection
                                               didReceiveDataLength:connectionData.resultData.length expectedDataLength:connectionData.expectedDataLength
                                                   receiveDataSpeed:speed];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _URLConnectionData *connectionData  = [_urlConnectionToDataMap objectForKey:NSNumberWithPointer(connection)];
    
    if (connectionData ) {
        
        RemoveConnectionData(connectionData);
        
        ifRespondsSelector(connectionData.connectionDelegate, @selector(urlConnectionManager:connection:didFinishLoadingData:))  {
            
            [connectionData .connectionDelegate urlConnectionManager:self
                                                          connection:connection
                                                didFinishLoadingData:connectionData .resultData];
        }
    }
}

- (NSArray *)connections:(id<URLConnectionManagerDelegate>)delegate
{
    NSMutableArray * array = [_delegateToDataDicMap objectForKey:NSNumberWithPointer(delegate)];
    return array ? [NSArray arrayWithArray:array] :nil;
}

@end
