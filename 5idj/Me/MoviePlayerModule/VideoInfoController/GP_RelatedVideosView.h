//
//  GP_RelatedVideosView.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-6-27.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_Video.h"
#import "GP_BasicViewController.h"

//----------------------------------------------------------

@interface GP_RelatedVideosView : UIView

- (void)refreshWithVideo:(GP_Video *)video;

@property(nonatomic,weak) id<SelectVideoProtocol> selectVideoDelegate;

@end
