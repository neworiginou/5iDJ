//
//  GP_HomeTableHeadView.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-14.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicHeaderContentView.h"
#import "GP_HomeVideosModule.h"

////----------------------------------------------------------

@interface GP_HomeModuleSupplementaryView : UICollectionReusableView

@property(nonatomic,strong) GP_HomeVideosModule *videosModule;

/*代理*/
@property(nonatomic,weak) id<SelectHomeVideosModuleProtocol> videosModuleDelegate;

@end

