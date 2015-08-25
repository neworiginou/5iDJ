//
//  MySettingTableViewCell.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-7-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MySettingTableViewCell.h"
#import "UIViewController+Instance.h"
#import "UIImage+Tint.h"
#include "MacroDef.h"

//----------------------------------------------------------

NSString * const SettingCellDidChangeSettingInfoNotification = @"SettingCellDidChangeSettingInfoNotification";

NSString * const SettingInfoKeyUserInfoKey = @"SettingInfoKeyUserInfoKey";

#define PostChangeSettingInfoNotification(_settingInfoKey)  \
[[NSNotificationCenter defaultCenter] postNotificationName:SettingCellDidChangeSettingInfoNotification object:self userInfo:@{SettingInfoKeyUserInfoKey : _settingInfoKey}]

//----------------------------------------------------------


NSString * _reuseDef(MySettingTableViewCellType type,UITableViewCellStyle style)
{
    return [NSString stringWithFormat:@"MySettingTableViewCell_%d_%d_def",(int)type,(int)style];
    
}

//----------------------------------------------------------

@interface _MySettingTableViewCell_Next:MySettingTableViewCell

@end

//----------------------------------------------------------

@interface _MySettingTableViewCell_Switch:MySettingTableViewCell

@end

////----------------------------------------------------------
//
//@interface _MySettingTableViewCell_Selected:MySettingTableViewCell
//
//@end


//----------------------------------------------------------

Class  _cellClassForType(MySettingTableViewCellType type)
{
    switch (type) {
        case MySettingTableViewCellTypeDefault:
            return [MySettingTableViewCell class];
            break;
            
        case MySettingTableViewCellTypeNext:
            return [_MySettingTableViewCell_Next class];
            break;
            
        case MySettingTableViewCellTypeSwitch:
            return [_MySettingTableViewCell_Switch class];
            break;
            
            //        case MySettingTableViewCellTypeSelected:
            //            return [_MySettingTableViewCell_Selected class];
            //            break;
        default:
            return nil;
            break;
    }
}

//----------------------------------------------------------

@interface MySettingTableViewCell ()

- (void)_updateWithInfoDic:(NSDictionary *)info;

@property(nonatomic,strong,readonly) NSString * targetKey;

@end

//----------------------------------------------------------

@implementation MySettingTableViewCell

@synthesize targetKey = _targetKey;

+ (MySettingTableViewCell *)cellWithInfoDic:(NSDictionary *)info forTableView:(UITableView *)tableView
{
    NSString * reuseDef = _reuseDef([info type], [info style]);
    
    MySettingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseDef];
    
    if (!cell) {
        cell = [[_cellClassForType([info type]) alloc] initWithStyle:[info style] reuseIdentifier:reuseDef];
    }
    
    [cell _updateWithInfoDic:info];
    
    return cell;
}

- (void)_updateWithInfoDic:(NSDictionary *)info
{
    self.textLabel.text = [info title];
    self.detailTextLabel.text = [info detailTitle];
    
    if (self.imageView) {
        
        self.imageView.image = nil;
        self.imageView.highlightedImage = nil;
        
        UIImage * image = [info image];
        
        if (image) {
            UIImage * highlightedImage = [info highlightedImage];
            if (!highlightedImage) {
                highlightedImage = [image imageWithTintColor:[UIColor whiteColor]];
            }
            
            self.imageView.image = image;
            self.imageView.highlightedImage = highlightedImage;
        }
    }
    
     _targetKey = [info targetKey];
}


@end

//----------------------------------------------------------

@implementation _MySettingTableViewCell_Next

- (UIImage *)hightlightedNextImage
{
    static UIImage * hightlightedNextImage = nil;
    
    if (!hightlightedNextImage) {
        hightlightedNextImage = [ImageWithName(@"ic_arrow_right.png") imageWithTintColor:[UIColor whiteColor]];
    }
    
    return hightlightedNextImage;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        UIImageView * nextIndicatorView = [[UIImageView alloc] initWithImage:ImageWithName(@"ic_arrow_right.png") highlightedImage:[self hightlightedNextImage]];
        self.accessoryView = nextIndicatorView;
        
        NSMutableArray * array = [NSMutableArray arrayWithArray:self.highlightedObjects];
        [array addObject:nextIndicatorView];
        self.highlightedObjects = array;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.isSelected != selected) {
        
        if (selected && self.targetKey.length > 0) {
            
            Class viewControllerClass = NSClassFromString(self.targetKey);
            if (viewControllerClass) {
                
                id<MySettingTableViewCellDelegate> delegate = self.delegate;
                ifRespondsSelector(delegate, @selector(settingTableViewCell:needShowViewController:)){
                    if([viewControllerClass isSubclassOfClass:[UIViewController class]]){
                        [delegate settingTableViewCell:self needShowViewController:[viewControllerClass viewController]];
                    }
                }
            }else{
                
                //定位其它程序
                NSURL * url = [NSURL URLWithString:self.targetKey];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }
    }
    
    [super setSelected:selected animated:animated];
}

@end

//----------------------------------------------------------

@implementation _MySettingTableViewCell_Switch
{
    UISwitch * _switchControl;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _switchControl = [[UISwitch alloc] init];
        _switchControl.onTintColor = [self.tintColor colorWithAlphaComponent:self.tintColorAlpha];
        [_switchControl addTarget:self action:@selector(_switchHandle) forControlEvents:UIControlEventValueChanged];
        
        self.accessoryView  = _switchControl;
        
        self.canShowTintView = NO;
        self.textLabel.highlightedTextColor = nil;
        self.detailTextLabel.highlightedTextColor = nil;
    }
    
    return self;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    _switchControl.onTintColor = [self.tintColor colorWithAlphaComponent:self.tintColorAlpha];
}

- (void)_updateWithInfoDic:(NSDictionary *)info
{
    [super _updateWithInfoDic:info];
    _switchControl.on = [[NSUserDefaults standardUserDefaults] boolForKey:self.targetKey];
}


- (void)_switchHandle
{
    if (self.targetKey) {
        
        [[NSUserDefaults standardUserDefaults] setBool:_switchControl.on forKey:self.targetKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        PostChangeSettingInfoNotification(self.targetKey);
    }
}

@end

//@implementation _MySettingTableViewCell_Selected
//
////- (void)setSelected:(BOOL)selected animated:(BOOL)animated
////{
////    [super setSelected:selected animated:animated];
////
////    if (selected && self.targetKey) {
////
////        Class viewControllerClass = NSClassFromString(self.targetKey);
////
////        if (viewControllerClass) {
////
////            id<MySettingTableViewCellDelegate> delegate = self.delegate;
////            ifRespondsSelector(delegate, @selector(settingTableViewCell:needShowViewController:)){
////
////                if([viewControllerClass isSubclassOfClass:[UIViewController class]]){
////                    [delegate settingTableViewCell:self needShowViewController:[viewControllerClass viewController]];
////                }
////            }
////
////        }else{
////
////            //定位其它程序
////            NSURL * url = [NSURL URLWithString:self.targetKey];
////
////            if ([[UIApplication sharedApplication] canOpenURL:url]) {
////                [[UIApplication sharedApplication] openURL:url];
////            }
////        }
////    }
////}
//
//
//@end

//----------------------------------------------------------

@implementation NSDictionary (MySettingTableViewCell)

- (MySettingTableViewCellType)type
{
    return (MySettingTableViewCellType)[[self objectForKey:@"type"] integerValue];
}

- (UITableViewCellStyle)style
{
    return (UITableViewCellStyle)[[self objectForKey:@"style"] integerValue];
}

- (NSString *)title
{
    return [self objectForKey:@"title"];
}

- (NSString *)detailTitle
{
    return [self objectForKey:@"detailTitle"];
}

- (UIImage *)image
{
    NSString * imageName = [self objectForKey:@"image"];
    
    if (imageName) {
        return ImageWithName(imageName);
    }
    
    return nil;
}

- (UIImage *)highlightedImage
{
    NSString * imageName = [self objectForKey:@"highlightedImage"];
    
    if (imageName) {
        return ImageWithName(imageName);
    }
    
    return nil;
}

- (NSString *)targetKey
{
    return [self objectForKey:@"targetKey"];
}


- (NSString *)selectEvent
{
    return [self objectForKey:@"selectEvent"];
}

@end