//
//  GP_NetRequest.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//---------------------------------------
#import "GP_HTTPRequest.h"
#import "NSError+GP_HTTPRequest.h"


//---------------------------------------

@interface GP_HTTPRequest () <MyHTTPRequestDelegate>

@property(nonatomic,strong,readonly) NSURLRequest * urlRequest;

@end
//---------------------------------------

@implementation GP_HTTPRequest
{
    MyHTTPRequest * _httpRequest;
}

@synthesize successBlock = _successBlock;
@synthesize failBlock = _failBlock;

- (id)init
{
    @throw [NSException exceptionWithName:@"方法调用错误" reason:@"该类不支持默认初始化方法" userInfo:nil];
}

- (id)initWithAPIRoute:(NSString *)apiRoute
                  path:(NSString *)path
        queryArguments:(NSDictionary *)queryArguments
{
    return [self initWithAPIRoute:apiRoute
                             path:path
                   queryArguments:queryArguments
                    bodyArguments:nil
                             type:HTTPRequestTypeGet];
}

- (id)initWithAPIRoute:(NSString *)apiRoute
                  path:(NSString *)path
         bodyArguments:(NSDictionary *)bodyArguments
{
    return [self initWithAPIRoute:apiRoute
                             path:path
                   queryArguments:nil
                    bodyArguments:bodyArguments
                             type:HTTPRequestTypePost];
}

- (id)initWithAPIRoute:(NSString *)apiRoute
                  path:(NSString *)path
        queryArguments:(NSDictionary *)queryArguments
         bodyArguments:(NSDictionary *)bodyArguments
{
    return [self initWithAPIRoute:apiRoute
                             path:path
                   queryArguments:queryArguments
                    bodyArguments:bodyArguments
                             type:HTTPRequestTypePost];
}

- (id)initWithAPIRoute:(NSString *)apiRoute
                  path:(NSString *)path
        queryArguments:(NSDictionary *)queryArguments
         bodyArguments:(NSDictionary *)bodyArguments
                  type:(HTTPRequestType)type
{
    self = [super init];
    
    if (self) {
        
        _httpRequest = [[MyHTTPRequest alloc] initWithURL:GP_API_MAIN_URL
                                                     path:[apiRoute stringByAppendingPathComponent:path]
                                           queryArguments:queryArguments
                                          headerArguments:nil
                                            bodyArguments:bodyArguments
                                                     type:type];
        
        _httpRequest.delegate = self;
        
    }
    
    return self;
}

- (void)dealloc
{
    [self cancleRequest];
}

- (void)startRequest
{
    [_httpRequest startRequest];
}

- (void)cancleRequest
{
    [_httpRequest cancleRequest];
}

- (BOOL)isRequesting
{
    return [_httpRequest isRequesting];
}

- (void)httpRequest:(id<MyHTTPRequestProtocol>)request
didSendHTTPBodyDataLength:(long long)sendDataLenght
 expectedDataLength:(long long)expectedDataLength
      sendDataSpeed:(NSUInteger)speed
{
    id<MyHTTPRequestDelegate> __delegate = self.delegate;
    
    ifRespondsSelector(__delegate, @selector(httpRequest:didSendHTTPBodyDataLength:expectedDataLength:sendDataSpeed:)){
        
        [__delegate httpRequest:self
      didSendHTTPBodyDataLength:sendDataLenght
             expectedDataLength:expectedDataLength
                  sendDataSpeed:speed];
    }
    
}

- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didReceiveResponse:(NSURLResponse *)response
{
    id<MyHTTPRequestDelegate> __delegate = self.delegate;
    
    ifRespondsSelector(__delegate, @selector(httpRequest:didReceiveResponse:)){
        [__delegate httpRequest:self didReceiveResponse:response];
    }
    
}

-  (void)httpRequest:(id<MyHTTPRequestProtocol>)request
didReceiveDataLength:(long long)receiveDataLength
  expectedDataLength:(long long)expectedDataLength
    receiveDataSpeed:(NSUInteger)speed
{
    id<MyHTTPRequestDelegate> __delegate = self.delegate;
    
    ifRespondsSelector(__delegate, @selector(httpRequest:didReceiveDataLength:expectedDataLength:receiveDataSpeed:)){
        
        [__delegate httpRequest:self
           didReceiveDataLength:receiveDataLength
             expectedDataLength:expectedDataLength
               receiveDataSpeed:speed];
    }
    
    
}

- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didFailedRequestWithError:(NSError *)error
{
    id<MyHTTPRequestDelegate> __delegate = self.delegate;
    
    ifRespondsSelector(__delegate, @selector(httpRequest:didFailedRequestWithError:)){
        [__delegate httpRequest:self didFailedRequestWithError:[NSError netErrorWithError:error]];
    }
    
    if(_failBlock){
        _failBlock(error);
    }
}

- (void)httpRequest:(id<MyHTTPRequestProtocol>)request didSuccessRequestWithData:(NSData *)data
{
    //解析数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSError * error = nil;
        
        //后台解析JSON数据
        NSDictionary * dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers error:&error];
        
        NSError * resultError = nil;
        
        if (error) {
            
#if DEBUG
            //JSON数据解析错误
            resultError = [NSError resultErrorWithErrorDescription:@"JSON数据解析错误!"];
#else
            resultError = [NSError resultErrorWithErrorDescription:@"访问服务器出错。"];
            
#endif
            
        }else if(![dataDic[GP_GP_SUCCESS] boolValue] && !dataDic[GP_GP_RESULT]){
            
            //结果错误
            id errorMsg = dataDic[GP_GP_ERRORMESSAGE];
            errorMsg = (errorMsg == [NSNull null]) ? @"访问服务器出错。" : errorMsg;
            
            resultError = [NSError resultErrorWithErrorDescription:errorMsg];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            
            id<GP_HTTPRequestDelegate> __delegate = self.delegate;
            
            if (resultError) {
                
                ifRespondsSelector(__delegate, @selector(httpRequest:didFailedRequestWithError:)){
                    [__delegate httpRequest:self didFailedRequestWithError:resultError];
                }
                
            }else{
                
                ifRespondsSelector(__delegate, @selector(httpRequest:didSuccessRequestWithData:)){
                    [__delegate httpRequest:self didSuccessRequestWithData:data];
                }
                
                ifRespondsSelector(__delegate, @selector(httpRequest:didSuccessRequestWithDataObject:)){
                    [__delegate httpRequest:self didSuccessRequestWithDataObject:dataDic[GP_GP_RESULT]];
                }
                
                //发送给block
                if (_successBlock) {
                    _successBlock(data);
                }
                
            }
        });
        
    });
}

@end
