//
//  GP_RelatedVideosPageLoadController.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-11.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_RelatedVideosPageLoadController.h"
#import "GP_MainTabBarController.h"

//----------------------------------------------------------

@implementation GP_RelatedVideosPageLoadController

- (id)initWithPageSize:(NSUInteger)pageSize
{
    self = [super initWithPageSize:pageSize];
    
    if (self) {
        self.loadHandleName = @"获取视频" ;
    }
    
    return self;
}


- (void)refreshData
{
    if(![GP_UserManager currentUser]){
        
        if([GP_UserManager isAutoLogining]){
            [self.loadingIndicateView showLoadingStatusWithTitle:@"用户正在登录中,请稍后..." detailText:nil];
        }else{
            [self.loadingIndicateView showNoUserWiTitle:@"登陆后才能知道你喜欢的视频" detailText:@"点击页面立即登录"];
        }
    }else{
        [super refreshData];
    }
}


@end
