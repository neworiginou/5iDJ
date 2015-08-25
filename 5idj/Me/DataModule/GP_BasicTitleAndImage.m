//
//  GP_BasicTitleAndImage.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-27.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "GP_BasicTitleAndImage.h"

//----------------------------------------------------------

@implementation GP_BasicTitleAndImage

+ (NSArray *)dataArrayWithInfoArray:(NSArray *)infoArray
{
    assert(infoArray);
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:infoArray.count];
    
    for (NSDictionary *info in infoArray) {
        [array addObject:[[self alloc] initWithInfoDic:info]];
    }
    
    return array;
}

- (id)initWithInfoDic:(NSDictionary *)info
{
    return [self initWithID:[info[@"ID"] integerValue]
                      title:info[@"title"]
                   imageURL:info[@"imageURL"]
                      brief:nil];
}

- (id)initWithID:(NSInteger)ID title:(NSString *)title
{
    return [self initWithID:ID
                      title:title
                   imageURL:nil
                      brief:nil];
}

- (id)initWithID:(NSInteger)ID title:(NSString *)title imageURL:(NSString *)imageURL
{
    return [self initWithID:ID
                      title:title
                   imageURL:imageURL
                      brief:nil];
}

- (id)initWithID:(NSInteger)ID
           title:(NSString *)title
        imageURL:(NSString *)imageURL
           brief:(NSString *)brief
{
    self = [super init];
    
    if (self) {
        _ID       = ID;
        _title    = title;
        _imageURL = imageURL;
        _brief    = brief;
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _ID       = [aDecoder decodeIntegerForKey:@"_ID"];
        _title    = [aDecoder decodeObjectForKey: @"_title"];
        _imageURL = [aDecoder decodeObjectForKey: @"_imageURL"];
        _brief    = [aDecoder decodeObjectForKey: @"_brief"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_ID      forKey:@"_ID"];
    [aCoder encodeObject:_title    forKey:@"_title"];
    [aCoder encodeObject:_imageURL forKey:@"_imageURL"];
    [aCoder encodeObject:_brief    forKey:@"_brief"];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return _ID == [(typeof(self))object ID];
    }
    
    return NO;
}

@end
