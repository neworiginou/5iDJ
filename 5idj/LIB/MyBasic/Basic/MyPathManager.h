//
//  pathManager.h
//  testDemo
//
//  Created by Xuzhanya on 13-11-5.
//  Copyright (c) 2013年 Xu zhanya. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger,MyPathType)
{
    MyPathTypeDocument,
    MyPathTypeTemp
};


@interface MyPathManager : NSObject


@property(nonatomic,strong) NSString *fileFolder;

+ (MyPathManager *)pathManagerWithFileFolder:(NSString *)fileFolder;
+ (MyPathManager *)pathManagerWithType:(MyPathType) type andFileFolder:(NSString *)fileFolder;

- (id)initWithFileFolder:(NSString *)fileFolder;
- (id)initWithType:(MyPathType) type andFileFolder:(NSString *)fileFolder;

- (NSString *)path;
- (NSString *)pathForFile:(NSString *)fileName;
- (NSString *)pathForDirectory:(NSString *)DirectoryName;


@end
