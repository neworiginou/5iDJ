//
//  GP_VideoPlayRecord.h
//  5idj
//
//  Created by Xuzhanya on 14-10-15.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GP_Video.h"

//----------------------------------------------------------

@interface GP_VideoPlayRecord : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSDate   * playDate;
@property (nonatomic, retain) NSNumber * playDuration;
@property (nonatomic, retain) NSNumber * playFinish;

- (void)setValuesWithVideo:(GP_Video *)video;

- (GP_Video *)toVideo;

@end
