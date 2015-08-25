//
//  GP_Theme.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-9-5.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "GP_Theme.h"

//----------------------------------------------------------

@implementation GP_Theme

- (id)initWithInfoDic:(NSDictionary *)info
{
    self = [super init];
    
    if (self) {
        
        _ID             = [info[@"id"] integerValue];
        _themeImageName = info[@"image"];
        _thumbnailName  = info[@"thumbnail"];
        _themeHexColor  = info[@"color"];
        
    }
    
    return self;
}

@end
