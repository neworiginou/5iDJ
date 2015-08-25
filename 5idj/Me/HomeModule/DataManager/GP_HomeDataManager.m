//
//  GP_HomeDataManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-4-9.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_HomeDataManager.h"
#import "GP_ServiceRequest.h"

//----------------------------------------------------------

@interface GP_HomeDataManager()<GP_ServiceRequestDelegate>

//服务请求
@property(nonatomic, strong, readonly) GP_ServiceRequest * getHomeHotVideosService;
@property(nonatomic, strong, readonly) GP_ServiceRequest * getHomeMoudlePagesService;

@end

//----------------------------------------------------------

@implementation GP_HomeDataManager
{
    NSArray * _hotVideos;
    NSArray * _homeMoudles;
}

@synthesize getHomeHotVideosService   = _getHomeHotVideosService;
@synthesize getHomeMoudlePagesService = _getHomeMoudlePagesService;

- (GP_ServiceRequest *)getHomeHotVideosService
{
    if (!_getHomeHotVideosService) {
        
        _getHomeHotVideosService = [[GP_ServiceRequest alloc] init];
        _getHomeHotVideosService.delegate = self;
    }
    
    return _getHomeHotVideosService;
}

- (GP_ServiceRequest *)getHomeMoudlePagesService
{
    if (!_getHomeMoudlePagesService) {
        
        _getHomeMoudlePagesService = [[GP_ServiceRequest alloc] init];
        _getHomeMoudlePagesService.delegate = self;
    }
    
    return _getHomeMoudlePagesService;
}

- (void)startGetHomeData
{
    [self cancleGetHomeData];
    
    _gettingHomeData = YES;
    
    //开始请求
    [self.getHomeHotVideosService startGetHomeHotVideos];
    [self.getHomeMoudlePagesService startGetHomeMoudlePages];
    
}

- (void)cancleGetHomeData
{
    _gettingHomeData = NO;
    
    //取消服务
    [_getHomeMoudlePagesService cancleService];
    [_getHomeHotVideosService cancleService];
    
    _hotVideos = nil;
    _homeMoudles = nil;
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest
           serviceType:(ServiceRequestSerivceType)type
    didFailRequestWithError:(NSError *)error
{
    _gettingHomeData = NO;
    
    [self.delegate homeDataManager:self getHomeDataFailWithError:error];
    
    [self cancleGetHomeData];
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest
           serviceType:(ServiceRequestSerivceType)type
    didSuccessRequestWithData:(id)data
{
    if (type == ServiceRequestSerivceTypeGetHomeHotVideos) {
        _hotVideos = data;
    }else{
        _homeMoudles = data;
    }
    
    if(_hotVideos && _homeMoudles){
        
        _gettingHomeData = NO;
        
        [self.delegate homeDataManager:self getHomeDataSuccessWithVideos:_hotVideos andModules:_homeMoudles];
        
        _homeMoudles = nil;
        _hotVideos = nil;
    }
}

@end
