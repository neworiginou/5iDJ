//
//  MyHTTPRequest.m
//  Bestone
//
//  Created by Xuzhanya on 14-6-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyHTTPRequest.h"
#import "URLConnectionManager.h"
#import "MyNetReachability.h"
#import "MacroDef.h"
#import "help.h"

//----------------------------------------------------------

#define HttpRequestDebugLog(_format,...)  DebugLog(@"HttpRequestDomain",_format, ##__VA_ARGS__)


//----------------------------------------------------------

@interface MyHTTPRequest () <URLConnectionManagerDelegate>

@property(nonatomic,strong,readonly) NSURLRequest * urlRequest;


+ (NSData *)_dataWithBodyArguments:(NSDictionary *)bodyArguments;

- (void)_postErrorMsgWithError:(NSError *)error;

@end

//----------------------------------------------------------

@implementation MyHTTPRequest
{
    NSString        * _requestURL;
    NSDictionary    * _headerArguments;
    NSData          * _bodyData;
    
    HTTPRequestType   _type;
}

@synthesize successBlock = _successBlock;
@synthesize failBlock    = _failBlock;
@synthesize delegate     = _delegate;
@synthesize requesting   = _requesting;
@synthesize urlRequest   = _urlRequest;

- (id)init
{
    @throw [[NSException alloc] initWithName:@"方法调用错误"
                                      reason:@"MyHTTPRequest不支持无参数初始化"
                                    userInfo:nil];
}

- (id)initWithURL:(NSString *)url
{
    return [self initWithURL:url
                        path:nil
              queryArguments:nil
             headerArguments:nil
                    bodyData:nil
                        type:HTTPRequestTypeGet];
}

- (id)initWithURL:(NSString *)url
             path:(NSString *)path
   queryArguments:(NSDictionary *)queryArguments
{
    return [self initWithURL:url
                        path:path
              queryArguments:queryArguments
             headerArguments:nil
                    bodyData:nil
                        type:HTTPRequestTypeGet];
}

- (id)initWithURL:(NSString *)url bodyArguments:(NSDictionary *)bodyArguments
{
    return [self initWithURL:url
                        path:nil
              queryArguments:nil
             headerArguments:nil
               bodyArguments:bodyArguments
                        type:HTTPRequestTypePost];
}

- (id)initWithURL:(NSString *)url
             path:(NSString *)path
    bodyArguments:(NSDictionary *)bodyArguments
{
    return [self initWithURL:url
                        path:path
              queryArguments:nil
             headerArguments:nil
                    bodyData:nil
                        type:HTTPRequestTypeGet];
}

- (id)initWithURL:(NSString *)url
             path:(NSString *)path
   queryArguments:(NSDictionary *)queryArguments
  headerArguments:(NSDictionary *)headerArguments
    bodyArguments:(NSDictionary *)bodyArguments
             type:(HTTPRequestType)type
{
    
    return [self initWithURL:url
                        path:path
              queryArguments:queryArguments
             headerArguments:headerArguments
                    bodyData:[MyHTTPRequest _dataWithBodyArguments:bodyArguments]
                        type:type];
    
}

- (id)initWithURL:(NSString *)url
             path:(NSString *)path
   queryArguments:(NSDictionary *)queryArguments
  headerArguments:(NSDictionary *)headerArguments
         bodyData:(NSData *)bodyData
             type:(HTTPRequestType)type
{
    if (self = [super init]) {
        
        //url不能为nil
        if (!url || [url isEqualToString:@""]) {
            @throw [[NSException alloc] initWithName:@"参数错误" reason:@"请求的URL不能为NULL" userInfo:nil];
        }
        
        //设置路径
        if (path && path.length) {
            url = [NSString stringWithFormat:@"%@/%@",url,path];
        }
        
        //生成查询参数
        NSString * queryArgumentStr = nil;
        
        if (queryArguments && queryArguments.count) {
            
            //记录各参数
            NSMutableArray * queryArgumentStrArrary = [[NSMutableArray alloc] initWithCapacity:queryArguments.count];
            for (NSString * key in queryArguments.allKeys) {
                
                id value = queryArguments[key];
                
                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSValue class]]) {
                    [queryArgumentStrArrary addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
                }
            }
            
            if (queryArgumentStrArrary.count) {
                queryArgumentStr = [queryArgumentStrArrary componentsJoinedByString:@"&"];
            }
        }
        
        //设置查询路径
        if (queryArgumentStr) {
            url = [NSString stringWithFormat:@"%@?%@",url,queryArgumentStr];
        }
        
        _requestURL      = url;
        _headerArguments = headerArguments;
        _bodyData        = bodyData;
        _type            = type;
        
    }
    
    return self;
}

//- (void)dealloc
//{
//    [self cancleRequest];
//}

+ (NSData *)_dataWithBodyArguments:(NSDictionary *)bodyArguments
{
    NSMutableData * bodyData = nil;
    
    if (bodyArguments && bodyArguments.count) {
        
        bodyData = [NSMutableData data];
        
        BOOL isStart = YES;
        
        for (NSString * key in bodyArguments.allKeys) {
            
            
#define   addConnectChar()                              \
{                                                       \
    if (!isStart) {                                     \
        [bodyData appendData:DataWithUTF8Code(@"&")];   \
    }else{                                              \
        isStart = NO;                                   \
    }                                                   \
}
            id value = bodyArguments[key];
            
            if ([value isKindOfClass:[NSData class]]) {
                
                //添加连接符
                addConnectChar();
                
                NSString * tmpStr = [NSString stringWithFormat:@"%@=",key];
                [bodyData appendData:DataWithUTF8Code(tmpStr)];
                [bodyData appendData:(NSData *)value];
                
            }else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSValue class]]){
                
                //添加连接符
                addConnectChar();
                
                NSString * tmpStr = [NSString stringWithFormat:@"%@=%@",key,value];
                [bodyData appendData:DataWithUTF8Code(tmpStr)];
            }
            
        }
    }
    
    return bodyData;
}

- (NSURLRequest *)urlRequest
{
    //lazy init
    if (!_urlRequest) {
        
        HttpRequestDebugLog(@"URL = %@",_requestURL);
        
        NSMutableURLRequest * tmpURLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        //设置方法
        switch (_type) {
            case HTTPRequestTypeGet:
                [tmpURLRequest setHTTPMethod:@"GET"];
                break;
            
            case HTTPRequestTypePost:
                [tmpURLRequest setHTTPMethod:@"POST"];
                break;
                
            case HTTPRequestTypePut:
                [tmpURLRequest setHTTPMethod:@"PUT"];
                
            default:
                break;
        }
        
        
        //设置头
        if (_headerArguments && _headerArguments.count) {
            
            for (id key in _headerArguments.allKeys) {
                
                id value = _headerArguments[key];
                
                if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                    [tmpURLRequest setValue:(NSString *)value forHTTPHeaderField:(NSString *)key];
                }
            }
        }
        
        //设置body
        if (_bodyData) {
            [tmpURLRequest setHTTPBody:_bodyData];
        }
        
        _urlRequest = tmpURLRequest;

    }
    return _urlRequest;
}


- (void)_setRequesting:(BOOL)requesting
{
    if (_requesting != requesting) {
        _requesting = requesting;
        
        //设置网络活动指示的显示
        showNetworkActivityIndicator(requesting);
    }
}

- (void)startRequest
{
    //取消可能得访问
    [self cancleRequest];
    
    if ([MyNetReachability currentNetReachabilityStatus] == kNotReachable) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _postErrorMsgWithError:[NSError errorWithDomain:@"defaultErrorDomain"
                                                             code:MyHTTPRequestNoNetReachableErrorCode
                                                         userInfo:@{NSLocalizedDescriptionKey : @"网络似乎断开了连接。"}]];
        });
        
    }else{
        
        //开始访问
        [self _setRequesting:YES];
        
        [[URLConnectionManager defaultManager] startConnection:self request:self.urlRequest];
    }
}

- (void)cancleRequest
{
    if (_requesting) {
        
        //取消连接
        [[URLConnectionManager defaultManager] cancleConnection:self];
        [self _setRequesting:NO];
    }
}

- (void)urlConnectionManager:(URLConnectionManager *)manager
                  connection:(NSURLConnection *)connection
   didSendHTTPBodyDataLength:(long long)sendDataLenght
          expectedDataLength:(long long)expectedDataLength
               sendDataSpeed:(NSUInteger)speed
{
    id<MyHTTPRequestDelegate> __delegate = _delegate;
    
    ifRespondsSelector(__delegate, @selector(httpRequest:didSendHTTPBodyDataLength:expectedDataLength:sendDataSpeed:)){
        
        [__delegate httpRequest:self
      didSendHTTPBodyDataLength:sendDataLenght
             expectedDataLength:expectedDataLength
                  sendDataSpeed:speed];
    }
    
}

- (void)urlConnectionManager:(URLConnectionManager *)manager
                  connection:(NSURLConnection *)connection
          didReceiveResponse:(NSURLResponse *)response
{
    id<MyHTTPRequestDelegate> __delegate = _delegate;
    
    ifRespondsSelector(__delegate, @selector(httpRequest:didReceiveResponse:)){
        [__delegate httpRequest:self didReceiveResponse:response];
    }
}

- (void)urlConnectionManager:(URLConnectionManager *)manager connection:(NSURLConnection *)connection didReceiveDataLength:(long long)receiveDataLength expectedDataLength:(long long)expectedDataLength receiveDataSpeed:(NSUInteger)speed
{
    id<MyHTTPRequestDelegate> __delegate = _delegate;
    
    ifRespondsSelector(__delegate, @selector(httpRequest:didReceiveDataLength:expectedDataLength:receiveDataSpeed:)){
        
        [__delegate httpRequest:self
           didReceiveDataLength:receiveDataLength
             expectedDataLength:expectedDataLength
               receiveDataSpeed:speed];
    }
}


- (void)urlConnectionManager:(URLConnectionManager *)manager
                  connection:(NSURLConnection *)connection
        didFinishLoadingData:(NSData *)data
{
    HttpRequestDebugLog(@"receiveData = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [self _setRequesting:NO];
    
    id<MyHTTPRequestDelegate> __delegate = _delegate;
    
    ifRespondsSelector(__delegate, @selector(httpRequest:didSuccessRequestWithData:)){
        [__delegate httpRequest:self didSuccessRequestWithData:data];
    }
    
    //发送给block
    if (_successBlock) {
        _successBlock(data);
    }
    
}

- (void)urlConnectionManager:(URLConnectionManager *)manager connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self _setRequesting:NO];
    
    //发送错误消息
    [self _postErrorMsgWithError:error];
}


- (void)_postErrorMsgWithError:(NSError *)error
{
    id<MyHTTPRequestDelegate> __delegate = _delegate;
    
    //给代理发送消息
    ifRespondsSelector(__delegate, @selector(httpRequest:didFailedRequestWithError:)){
        [__delegate httpRequest:self didFailedRequestWithError:error];
    }
    
    //发送给block
    if (_failBlock) {
        _failBlock(error);
    }
}

@end

//----------------------------------------------------------

@implementation MyHTTPRequest(Mutable)

- (void)_updateRequest
{
    if (_urlRequest) {
        
        [self cancleRequest];
        
        _urlRequest = nil;
    }
}

- (void)setRequestType:(HTTPRequestType)type
{
    if (_type != type) {
        _type = type;
    
        [self _updateRequest];
    }
}

- (void)setBodyData:(NSData *)bodyData
{
    _bodyData = bodyData;
    
    [self _updateRequest];
}

- (void)setBodyDataWithBodyArguments:(NSDictionary *)bodyArguments
{
    [self setBodyData:[MyHTTPRequest _dataWithBodyArguments:bodyArguments]];
}

- (void)setHeaderArguments:(NSDictionary *)headerArguments
{
    _headerArguments = headerArguments;
    
    [self _updateRequest];
}


@end
