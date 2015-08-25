//
//  MyTintTableViewCell.h
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-29.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

@interface MyTintTableViewCell : UITableViewCell

@property(nonatomic) BOOL canShowTintView;

@property(nonatomic,strong) NSArray * highlightedObjects;

- (void)showTintView:(BOOL)show animated:(BOOL)animated;

//default NO
@property(nonatomic) BOOL showSeparatorLine;

//default is grayColor
@property(nonatomic,strong) UIColor * separatorLineColor;

//透明度，默认为1.f
@property(nonatomic) CGFloat tintColorAlpha;

@end
