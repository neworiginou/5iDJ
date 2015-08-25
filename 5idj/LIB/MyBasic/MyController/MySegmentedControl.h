//
//  MySegmentedControl.h
//  5idj_ios
//
//  Created by Xuzhanya on 14-9-21.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

#define NoSelectedSectionIndex NSNotFound

//----------------------------------------------------------

@interface MySegmentedControl : UIControl

- (id)initWithSectionTitles:(NSArray *)titles;

- (id)initWithSectionImages:(NSArray *)images
             selectedImages:(NSArray *)selectedImages;

- (id)initWithSectionTitles:(NSArray *)titles
                     images:(NSArray *)images
             selectedImages:(NSArray *)selectedImages;;


@property(nonatomic,strong) NSArray * sectionTitles;
@property(nonatomic,strong) NSArray * sectionImages;
@property(nonatomic,strong) NSArray * sectionSelectedImages;

//文字字体，默认为17号system字体
@property(nonatomic,strong) UIFont  * textFont;
//文字颜色，默认为黑色
@property(nonatomic,strong) UIColor * textColor;
//高亮文字颜色，默认为nil,为nil使用半透明的selectedTextColor
@property(nonatomic,strong) UIColor * highlightedTextColor;
//选择文字颜色，默认为nil，为nil时使用tintColor
@property(nonatomic,strong) UIColor * selectedTextColor;

//是否自动调整图片，高亮和选择时，默认为YES
@property(nonatomic) BOOL autoAdjustImage;

//是否显示选择指示线,默认为YES
@property(nonatomic) BOOL    showSelectedIndicatorLine;
//选择指示线的宽度,默认为2.f
@property(nonatomic) CGFloat selectedIndicatorLineWidth;
//选择指示线的颜色，默认为nil，为nil时使用tintColor
@property(nonatomic) UIColor * selectedIndicatorLineColor;
//选择指示线的缩进量，默认为0
@property(nonatomic) UIEdgeInsets selectedIndicatorLineInset;
//选择指示线的缩进比例，默认为0
@property(nonatomic) UIEdgeInsets selectedIndicatorLineInsetScale;

//单元间是否显示分割线,默认为YES
@property(nonatomic) BOOL showSeparatorLine;
//是否划渐变的的分割线
@property(nonatomic) BOOL drawGradientSeparatorLine;
//分割线颜色,默认为黑色
@property(nonatomic,strong) UIColor * separatorLineColor;
//分割线的宽度,默认为1个像素对应的宽度
@property(nonatomic) CGFloat separatorLineWidth;
//分割线的缩进量，默认为0
@property(nonatomic) UIEdgeInsets separatorLineInset;
//分割线缩进比例，默认为(0.1,0.1)
@property(nonatomic) UIEdgeInsets separatorLineInsetScale;

//图片和文字的间隔，默认为2.f
@property(nonatomic) CGFloat titleImageMargin;


//选择的单元索引,默认为NoSelectedSectionIndex
@property(nonatomic) NSUInteger selectedSectionIndex;
- (void)setSelectedSectionIndex:(NSUInteger)selectedSectionIndex animated:(BOOL)animated;

//单元个数
@property(nonatomic,readonly) NSUInteger sectionCount;

- (NSString *)titleForIndex:(NSUInteger)index;
- (UIImage *)imageForIndex:(NSUInteger)index;
- (UIImage *)selectedImageForIndex:(NSUInteger)index;

- (CGRect)rectForSectionAtIndex:(NSUInteger)index;

@end
