//
//  GP_ChannelsManager.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-12.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ChannelsManager.h"
#import "GP_ServiceRequest.h"

//----------------------------------------------------------


#define ChannelsFilePath \
    [[[MyPathManager alloc] initWithFileFolder:@"SubscibedChannels"] pathForFile:@"Channels.data"]

static GP_ChannelsManager * defaultManager = nil;

NSString * const SubscibedChannelsChangeNotifcation   = @"SubscibedChannelsChangeNotifcation";
NSString * const ChangedChannelsUserinfoKey           = @"ChangedChannelsUserinfoKey";

NSString * const CheckChannelsStatusChangeNotifcation = @"CheckChannelsStatusChangeNotifcation";
NSString * const CheckChannelsStatusUserinfoKey       = @"CheckChannelsStatusUserinfoKey";

//----------------------------------------------------------


@interface GP_ChannelsManager()<GP_ServiceRequestDelegate>

@property(nonatomic,strong) NSMutableDictionary * channelDic;

@property(nonatomic,strong) NSMutableArray      * channelArray;

- (void)appDidEnterBackgrounp:(NSNotification *) notification;

//开始核对有效性
- (void)_startCheckChannelsValidity;

- (void)_currentNetworkChangeNotification:(NSNotification *)notification;

@end


//----------------------------------------------------------

@implementation GP_ChannelsManager
{
    BOOL _needWriteToFile;
    
    GP_ServiceRequest * _serviceRequest;
}


+ (GP_ChannelsManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[super allocWithZone:nil] init];
    });
    
    return defaultManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return defaultManager;
}

- (id)init
{
    if (defaultManager) {
        return defaultManager;
    }
    
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackgrounp:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        _needWriteToFile = NO;
        
        //开始检测有效性
        [self _startCheckChannelsValidity];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableDictionary *)channelDic
{
    if (!_channelDic) {
        [self _initData];
    }
    
    return _channelDic;
}

- (NSMutableArray *)channelArray
{
    if (!_channelArray) {
        [self _initData];
    }
    
    return _channelArray;
}

//初始化数据
- (void)_initData
{
    id  data = [NSKeyedUnarchiver unarchiveObjectWithFile:ChannelsFilePath];
    
    if ([data isKindOfClass:[NSMutableArray class]]) {
        _channelArray = data;
    }else if ([data isKindOfClass:[NSMutableArray class]]){
        _channelDic = data;
    }else{
        _channelArray = [NSMutableArray arrayWithArray:[GP_Channel dataArrayWithInfoArray:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"channels" ofType:@"plist"]]]];
    }
    
    if (!_channelArray) {
        _channelArray = [NSMutableArray arrayWithArray:_channelDic.allValues];
    }else{
        
        _channelDic = [NSMutableDictionary dictionaryWithCapacity:_channelArray.count];
        for (GP_Channel * channel in _channelArray) {
            [_channelDic setObject:channel forKey:[NSNumber numberWithInteger:channel.ID]];
        }
    }
    
    
    
}

- (void)appDidEnterBackgrounp:(NSNotification *)notification
{
    if (_needWriteToFile) {
        
        _needWriteToFile = NO;
        
        //写入文件
        [NSKeyedArchiver archiveRootObject:_channelArray toFile:ChannelsFilePath];
    }
}

#define PostSubscibedChannelsChangeNotification(_channels)                  \
{                                                                           \
    [[NSNotificationCenter defaultCenter] postNotificationName:SubscibedChannelsChangeNotifcation \
                                                    object:self             \
                                                    userInfo:_channels ? @{ChangedChannelsUserinfoKey : _channels} : nil];  \
}                                                                           \

#define PostCheckChannelsStatusChangeNotification(_status)                  \
{                                                                           \
    [[NSNotificationCenter defaultCenter] postNotificationName:CheckChannelsStatusChangeNotifcation \
                                                        object:self         \
                                                      userInfo:@{CheckChannelsStatusUserinfoKey : [NSNumber numberWithInteger:_status]}];  \
}                                                                           \


- (NSArray *)subscibedChannels
{
    return [NSArray arrayWithArray:self.channelArray];
}

- (void)subscibeChannels:(NSArray *)channels
{
    NSMutableArray * changedChannels = [NSMutableArray arrayWithCapacity:channels.count];
    
    for (GP_Channel * channel in channels) {
        
        assert([channel isKindOfClass:[GP_Channel class]]);
        
        NSNumber * key = [NSNumber numberWithInteger:channel.ID];
        
        if (![self.channelDic objectForKey:key]) {
            [changedChannels addObject:channel];
            
            [self.channelDic setObject:channel forKey:key];
            [self.channelArray addObject:channel];
        }
    }
    
    if (changedChannels.count != 0) {
        _needWriteToFile = YES;
        
        PostSubscibedChannelsChangeNotification(changedChannels);
    }
}

- (void)cancleSubscibeChannels:(NSArray *)channels
{
    NSMutableArray * changedChannels = [NSMutableArray arrayWithCapacity:channels.count];
    
    for (GP_Channel * channel in channels) {
        
        assert([channel isKindOfClass:[GP_Channel class]]);
        
        NSNumber * key = [NSNumber numberWithInteger:channel.ID];
        
        if ([self.channelDic objectForKey:key]) {
            [changedChannels addObject:channel];
            
            [self.channelDic removeObjectForKey:key];
            
            NSUInteger index = [self.channelArray indexOfObject:channel];
            assert(index != NSNotFound);
            [self.channelArray removeObjectAtIndex:index];
        }

    }
    
    if (changedChannels.count != 0) {
        _needWriteToFile = YES;
        
        PostSubscibedChannelsChangeNotification(changedChannels);
    }
}

- (BOOL)isSubscibedChannel:(GP_Channel *)channel
{
    GP_Channel * _channel = [_channelDic objectForKey:[NSNumber numberWithInteger:channel.ID]];
    
    return (_channel != nil);
}


- (void)_startCheckChannelsValidity
{
    //存在频道数据
    if (self.channelArray.count > 0) {
        
        if ([MyNetReachability currentNetReachabilityStatus] != kNotReachable) {
            
            PostCheckChannelsStatusChangeNotification(CheckChannelsStatusChecking);
            
            _serviceRequest = [[GP_ServiceRequest alloc] init];
            _serviceRequest.delegate = self;
            [_serviceRequest startGetChannelsServiceWithCurrentPage:0 andPageSize:20];
            
        }else{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentNetworkChangeNotification:) name:NetReachabilityChangedNotification object:nil];
        }
    }
}

- (void)_currentNetworkChangeNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NetReachabilityChangedNotification object:nil];
    
    [self _startCheckChannelsValidity];
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didSuccessRequestWithData:(id)data
{
    _serviceRequest = nil;
    
    NSMutableDictionary * channelsDic = [NSMutableDictionary dictionaryWithCapacity:[data count]];
    
    for (GP_Channel * channel in [data objectForKey:GP_GP_GET_CHANNELS_CHANNELS]) {
        [channelsDic setObject:channel forKey:[NSNumber numberWithInteger:channel.ID]];
    }
    
    
    NSMutableArray      * resultChannels    = [NSMutableArray arrayWithCapacity:self.channelArray.count];
    NSMutableDictionary * resultChannelsDic = [[NSMutableDictionary alloc] initWithCapacity:self.channelArray.count];
    
    for (GP_Channel * channel in self.channelArray) {
        
        NSNumber * key = [NSNumber numberWithInteger:channel.ID];
        
        GP_Channel * tmpChannel = [channelsDic objectForKey:key];
        
        if (tmpChannel) { //存在
            
            [resultChannels addObject:tmpChannel];
            [resultChannelsDic setObject:tmpChannel forKey:key];
        }
    }
    
    _channelArray = resultChannels;
    _channelDic   = resultChannelsDic;
    
    //发送消息
    _needWriteToFile = YES;
    
    PostCheckChannelsStatusChangeNotification(CheckChannelsStatusSuccess);
}

- (void)serviceRequest:(GP_ServiceRequest *)serviceRequest serviceType:(ServiceRequestSerivceType)type didFailRequestWithError:(NSError *)error
{
    _serviceRequest = nil;
    
    //3s后重新访问
    [self performSelector:@selector(_startCheckChannelsValidity) withObject:nil afterDelay:3.f];
    
    PostCheckChannelsStatusChangeNotification(CheckChannelsStatusFail);
}


@end
