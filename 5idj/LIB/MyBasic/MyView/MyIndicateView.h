//
//  MyLoadingIndicateView.h
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-27.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "MyActivityIndicatorView.h"

//----------------------------------------------------------

typedef NS_ENUM(int, MyIndicateViewStyle){
    MyIndicateViewStyleNoneView,
    MyIndicateViewStyleActivityView,
    MyIndicateViewStyleImageView,
    MyIndicateViewStyleCustomView
    
};

//----------------------------------------------------------

@interface MyIndicateView : UIView

@property(nonatomic) MyIndicateViewStyle style;


//--------layout----------

@property(nonatomic) CGPoint offsetValue;

@property(nonatomic) CGPoint offsetScale;

@property(nonatomic) CGSize marginScale;

//default is 10.f
@property(nonatomic) float   topMargin;
//default is 5.f
@property(nonatomic) float   bottomMargin;

//--------content----------

@property(nonatomic,strong,readonly) MyActivityIndicatorView * activityIndicatorView;

@property(nonatomic,strong) UIImage  * image;

@property(nonatomic,strong) UIView   * customView;

@property (copy) NSString *titleLabelText;

@property (copy) NSString *detailLabelText;

//--------UI----------

@property(nonatomic,strong) UIFont* titleLabelFont;

@property(nonatomic,strong) UIColor* titleLabelColor;

@property(nonatomic,strong) UIFont* detailLabelFont;

@property(nonatomic,strong) UIColor* detailLabelColor;

@property (assign) float progress;

@end





