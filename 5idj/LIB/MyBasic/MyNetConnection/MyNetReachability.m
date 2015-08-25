//
//  MyNetReachability.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

#import "MyNetReachability.h"

NSString *const NetReachabilityChangedNotification = @"NetReachabilityChangedNotification";

@interface MyNetReachability ()

+ (MyNetReachability *)_shareNetReachability;

@property(nonatomic,strong,readonly) Reachability * reachability;

- (BOOL)_startNotifier;

- (void)_stopNotifier;

- (NetworkStatus)_currentNetStatus;

- (void)_netReachabilityStatusChangeNotification:(NSNotification *)notification;

@end


@implementation MyNetReachability
{
    BOOL   _isNotifier;
}

@synthesize reachability = _reachability;

+ (MyNetReachability *)_shareNetReachability
{
    static MyNetReachability * shareNetReachability = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareNetReachability = [MyNetReachability new];
    });
    
    return shareNetReachability;
}

+ (BOOL)startNotifier
{
    return [[self _shareNetReachability] _startNotifier];
}

+ (void)stopNotifier
{
    [[self _shareNetReachability] _stopNotifier];
}

+ (NetworkStatus)currentNetReachabilityStatus
{
    return [[self _shareNetReachability] _currentNetStatus];
}

- (Reachability *)reachability
{
    if (!_reachability) {
        
        _reachability = [Reachability reachabilityForInternetConnection];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_netReachabilityStatusChangeNotification:) name:kReachabilityChangedNotification object:_reachability];
    }
    
    return _reachability;
}

- (BOOL)_startNotifier
{
    if (!_isNotifier) {
        _isNotifier = [self.reachability startNotifier];
    }
    
    return _isNotifier;
}

- (void)_stopNotifier
{
    if (_isNotifier) {
        [self.reachability stopNotifier];
        _isNotifier = NO;
    }
}

- (NetworkStatus)_currentNetStatus
{
    [self _startNotifier];
    
    return [self.reachability currentReachabilityStatus];
}

- (void)_netReachabilityStatusChangeNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NetReachabilityChangedNotification object:nil];
}

@end
