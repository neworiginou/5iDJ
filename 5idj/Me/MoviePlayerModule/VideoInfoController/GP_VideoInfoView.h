//
//  GP_videoInfoView.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-3-1.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_Video.h"

//----------------------------------------------------------

@interface GP_VideoInfoView : UIView

//- (id)initWithVideo:(GP_Video *)video;

- (void)refreshWithVideo:(GP_Video *)video;

//@property(nonatomic,strong,readonly) UIView * view;

@property(nonatomic,weak) id<SelectVideoProtocol> selectVideoDelegate;

@end
