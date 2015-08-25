//
//  GP_HomeHotFocusTableViewCell.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-11.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "GP_Video.h"

//----------------------------------------------------------

/*
 *该类为主页最上端焦点聚焦表格单元
 */
@interface GP_HomeHotFocusVideosView : UIView


- (id)initWithVideos:(NSArray *)videos;


- (void)updateWithVideos:(NSArray *)videos;

/*
 *选择视频代理
 */
@property(nonatomic,weak) id<SelectVideoProtocol> videoDelegate;


@end




