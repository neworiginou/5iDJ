//
//  GP_VideoPlayRecord.m
//  5idj
//
//  Created by Xuzhanya on 14-10-15.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "GP_VideoPlayRecord.h"

//----------------------------------------------------------

@implementation GP_VideoPlayRecord

@dynamic id;
@dynamic title;
@dynamic imageURL;
@dynamic playDate;
@dynamic playDuration;
@dynamic playFinish;

//- (void)awakeFromInsert
//{
//    [super awakeFromInsert];
//    self.playDate = [NSDate date];
//}

- (void)setValuesWithVideo:(GP_Video *)video
{
    if (video) {
        self.id       = [NSString stringWithFormat:@"%li",(long)video.ID];
        self.title    = video.title;
        self.imageURL = video.imageURL;
    }
}

- (GP_Video *)toVideo
{
    GP_Video * video = [[GP_Video alloc] initWithID:[self.id integerValue]
                                              title:self.title
                                           imageURL:self.imageURL];
    
    return video;
}


@end
