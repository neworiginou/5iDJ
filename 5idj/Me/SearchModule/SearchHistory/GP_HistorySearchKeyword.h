//
//  GP_HistorySearchKeyword.h
//  5idj
//
//  Created by Xuzhanya on 14-10-16.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GP_HistorySearchKeyword : NSManagedObject

@property (nonatomic, retain) NSString * searchKey;
@property (nonatomic, retain) NSDate * timeStamp;

@end
