//
//  pathManager.m
//  testDemo
//
//  Created by Xuzhanya on 13-11-5.
//  Copyright (c) 2013年 Xu zhanya. All rights reserved.
//

#import "MyPathManager.h"
#import "help.h"

@implementation MyPathManager
{
    MyPathType _pathType;
}

+ (MyPathManager *)pathManagerWithFileFolder:(NSString *)fileFolder
{
    return [[MyPathManager alloc] initWithFileFolder:fileFolder];
}

+ (MyPathManager *)pathManagerWithType:(MyPathType)type andFileFolder:(NSString *)fileFolder
{
    return [[MyPathManager alloc] initWithType:type andFileFolder:fileFolder];
}


- (id)init
{
    return [self initWithFileFolder:nil];
    
}

- (id)initWithFileFolder:(NSString *)fileFolder
{
    return [self initWithType:MyPathTypeDocument andFileFolder:fileFolder];
    
}

- (id)initWithType:(MyPathType)type andFileFolder:(NSString *)fileFolder
{
    self = [super init];
    
    if (self){
        _pathType = type;
        self.fileFolder = fileFolder;
    }
    
    return self;
}


- (void)setFileFolder:(NSString *)fileFolder
{
    _fileFolder = fileFolder;
    
    if (_fileFolder.length){
        
        if(!makeSrueDirectoryExist([self path])){
            _fileFolder = nil;
        }
    }
}

-(NSString *)pathForFile:(NSString *)fileName
{
    //获得文档目录路径
    NSString *documentDirectory = nil;
    
    switch (_pathType)
    {
        case MyPathTypeDocument:
            
            documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            break;
            
        case MyPathTypeTemp:
            documentDirectory = NSTemporaryDirectory();
            break;
            
        default:
            break;
    }
    
    
    //文件夹路路径
    documentDirectory = [documentDirectory stringByAppendingPathComponent:self.fileFolder];
    
    //文件路径
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

-(NSString *)pathForDirectory:(NSString *)DirectoryName
{
    NSString *path = [self pathForFile:DirectoryName];
     
    return makeSrueDirectoryExist(path) ? path : nil;
}

- (NSString *)path
{
    return [self pathForFile:nil];
}

@end
