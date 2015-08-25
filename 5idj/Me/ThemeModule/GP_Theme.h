//
//  GP_Theme.h
//  5idj_ios
//
//  Created by Xuzhanya on 14-9-5.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>

//----------------------------------------------------------

@interface GP_Theme : NSObject

- (id)initWithInfoDic:(NSDictionary *)info;

@property(nonatomic,readonly)           NSInteger ID;

@property(nonatomic,readonly,strong)    NSString * themeImageName;

@property(nonatomic,readonly,strong)    NSString * thumbnailName;

@property(nonatomic,readonly,strong)    NSString * themeHexColor;

@end
