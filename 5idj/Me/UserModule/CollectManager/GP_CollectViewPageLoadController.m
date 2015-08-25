//
//  GP_CollectViewPageLoadController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-11.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_CollectViewPageLoadController.h"

//----------------------------------------------------------

@implementation GP_CollectViewPageLoadController

- (id)initWithPageSize:(NSUInteger)pageSize
{
    self = [super initWithPageSize:pageSize];
    
    if (self) {
        self.loadHandleName =  @"获取收藏视频";
    }
    
    return self;
    
}

- (void)refreshData
{
    if(![GP_UserManager currentUser]){
        
        if([GP_UserManager isAutoLogining]){
            [self.loadingIndicateView showLoadingStatusWithTitle:@"用户正在登录中,请稍后..." detailText:nil];
        }else{
            [self.loadingIndicateView showNoUserWiTitle:@"登陆后才能查看收藏的视频" detailText:@"点击页面立即登录"];
        }
        
        self.pageLoadObject.contentView.hidden = YES;
        
    }else{
        [super refreshData];
    }
}

@end
