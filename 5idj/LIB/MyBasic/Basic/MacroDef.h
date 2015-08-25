//
//  MacroDef.h
//
//  Created by hldw on 13-12-10.
//  Copyright (c) 2013年 hldw. All rights reserved.
//

/*
 *常用宏的定义
 */

//----------------------------------------------------------

#ifndef MacroDef_h
#define MacroDef_h

//----------------------------------------------------------

//系统版本
#define SystemVersion systemVersion()

#define GreaterThanSystem(_version) (systemVersion() >= (_version))
#define GreaterThanIOS6System       GreaterThanSystem(6.f)
#define GreaterThanIOS7System       GreaterThanSystem(7.f)
#define GreaterThanIOS8System       GreaterThanSystem(8.f)

#define IS_SUPPORT_ARC  __has_feature(objc_arc)

//----------------------------------------------------------

//初始化一个布局限制
#define InitConstraint(_view1,_attr1,_view2,_attr2,_relation,_mul,_constance)  \
[NSLayoutConstraint constraintWithItem:_view1 attribute:_attr1 relatedBy:_relation toItem:_view2 attribute:_attr2 multiplier:_mul constant:_constance]

//初始化一个相关的相同属性的布局限制
#define InitRelatedCommonAttrConstraint(_view1,_attr,_view2,_mul,_constance)    \
InitConstraint(_view1,_attr,_view2,_attr,NSLayoutRelationEqual,_mul,_constance)

//设置子视图与父视图同一属性相关的限制
#define setRelatedCommonAttrConstraint(_view,_attr,_superView,_mul,_constance) \
[_superView addConstraint:InitRelatedCommonAttrConstraint(_view,_attr,_superView,_mul,_constance)]

//设置边界限制
#define setEdgeConstraint(_view,_attr,_superView,_constance) \
setRelatedCommonAttrConstraint(_view,_attr,_superView,1.f,_constance)

//设置大小限制
#define setSizeConstraint(_view,_attr,_constance) \
setSizeConstraint_(_view,_attr,NSLayoutRelationEqual,_constance)

//设置大小限制
#define setSizeConstraint_(_view,_attr,_relation,_constance) \
[_view addConstraint:InitConstraint(_view,_attr,nil,NSLayoutAttributeNotAnAttribute,NSLayoutRelationEqual,0.f,_constance)]


//设置所有子视图到父视图所有边界距离为固定值，实现居中效果，且会自动调整大小
#define setAllEdgeConstraint(_view,_superView,_constance)                      \
do{                                                                            \
    setEdgeConstraint(_view,NSLayoutAttributeLeft,_superView,_constance);      \
    setEdgeConstraint(_view,NSLayoutAttributeRight,_superView,-_constance);    \
    setEdgeConstraint(_view,NSLayoutAttributeTop,_superView,_constance);       \
    setEdgeConstraint(_view,NSLayoutAttributeBottom,_superView,-_constance);   \
}while(0)

//实现居中效果，不会自动调节大小
#define setCenterConstraint(_view,_superView)                                              \
do{                                                                                        \
    setRelatedCommonAttrConstraint(_view, NSLayoutAttributeCenterX, _superView,1.f,0.f);   \
    setRelatedCommonAttrConstraint(_view, NSLayoutAttributeCenterY, _superView,1.f,0.f);   \
}while(0)


//----------------------------------------------------------

//颜色
#define ColorWithRGBA(int_r,int_g,int_b,int_a)  \
    [UIColor colorWithRed:(int_r)/255.0 green:(int_g)/255.0 blue:(int_b)/255.0 alpha:(int_a)/255.0]


//通过数字初始化颜色
#define ColorWithNumberRGB(_hex)  \
    ColorWithRGBA(((_hex)>>16)&0xFF,((_hex)>>8)&0xFF,(_hex)&0xFF,255)

#define ColorWithNumberRGBA(_hex) \
    ColorWithRGBA(((_hex)>>24)&0xFF,((_hex)>>16)&0xFF,((_hex)>>8)&0xFF,(_hex)&0xFF)

//指定透明度的黑色
#define BlackColorWithAlpha(_alpha) [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:_alpha]


//----------------------------------------------------------

//通过名字初始化图片
#define ImageWithName(_name)  [UIImage imageNamed:(_name)]

//----------------------------------------------------------

#define ifRespondsSelector(_obj,_sel)                             \
if (_obj&&[(NSObject *)_obj respondsToSelector:_sel])


//安全调用Selector
#define SafePerformSelector(_per_obj,_sel,...)                   \
do{                                                              \
    NSObject *_obj =(NSObject *) _per_obj;                       \
    ifRespondsSelector(_obj,_sel)                                \
        objc_msgSend(_obj,_sel,##__VA_ARGS__);                   \
}while(0)

//----------------------------------------------------------

//调试输出

#if DEBUG

#define DebugLog(_targetDomin,_format,...) \
NSLog(@"\n["#_targetDomin@"]  \n\nFile:%s ,Line:%d \n\n"_format,__FILE__,__LINE__,##__VA_ARGS__)

#else

#define DebugLog(_targetDomin,_format,...)

#endif

//----------------------------------------------------------

#define SelectProtocolDefine(_dataName,_dataClassName)                          \
@protocol Select##_dataName##Protocol                                           \
@optional                                                                       \
- (void)object:(id)object didSelect##_dataName:(_dataClassName *)_dataName;     \
@end                                                                            \

#define  SafeSendSelectMsg(_delegate,_data,_dataName)                           \
do {                                                                            \
    id<Select##_dataName##Protocol> __delegate = _delegate;                     \
    ifRespondsSelector(__delegate, @selector(object:didSelect##_dataName:))     \
        [__delegate object:self didSelect##_dataName:_data];                    \
}while(0)

//----------------------------------------------------------

#define NSNumberWithPointer(_pointer) [NSNumber numberWithInteger:((NSInteger)(_pointer))]

#define ERROR(_domin,_code,_description)    \
    [NSError errorWithDomain:_domin code:_code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_description,NSLocalizedDescriptionKey,nil]]

#define DescriptionWithError(_error) [_error.userInfo objectForKey:NSLocalizedDescriptionKey]

//----------------------------------------------------------

//是否整除
#define IsIntrgerDivision(_num1,_num2) (((int)((_num1)/(_num2))) == (((float)(_num1))/(_num2)))

//获取资源路径
#define PathForResource(_path,_name,_bundle)                                                    \
do{                                                                                             \
    _path = nil;                                                                                \
    if (_name) {                                                                                \
        NSBundle *bundle = _bundle ? : [NSBundle mainBundle];                                   \
        NSRange range = [_name rangeOfString:@"." options:NSBackwardsSearch];                   \
        if (range.location != NSNotFound && range.location < _name.length - 1) {                \
            _path = [bundle pathForResource:[_name substringToIndex:range.location] ofType:[_name substringFromIndex:range.location + 1]];                                        \
        }                                                                                       \
    }                                                                                           \
}while (0)

//----------------------------------------------------------
#define SecPerDay                               86400.f
#define SecPerHour                              3600.f
#define MinPerHour                              60.f
#define SecPerMin                               MinPerHour
#define DayForTimeInterVal(_time)               floor(_time / SecPerDay)
#define HourForTimeInterVal(_time)              floor(_time / SecPerHour)
#define MinForTimeInterVal(_time)               floor(_time / SecPerMin)

//----------------------------------------------------------

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
#define TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
#define TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
#define MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
#define MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
#endif

//----------------------------------------------------------

#define ChangeInMinToMax(_value,_min,_max) \
((_value) < (_min) ? (_min) : ((_value) < (_max) ? (_value) : (_max)))

//----------------------------------------------------------

#define Mask8(x) ((x) & 0xFF)
#define Rp(x)    Mask8(x)
#define Gp(x)    Mask8((x) >> 8)
#define Bp(x)    Mask8((x) >> 16)
#define Ap(x)    Mask8((x) >> 24)

//亮度
#define Brp(x)    ((Rc(x) + Rc(x) + Rc(x)) / 3.f)

//构造像素
#define RGBAMakePixel(r,g,b,a) (Mask8(r) + (Mask8(g) << 8) + (Mask8(b) << 16) + (Mask8(a) << 24))

//透明度混合
#define AlphaMixed(top,bottom,alpha_f) ((top) * alpha_f + bottom * (1 - alpha_f))

//----------------------------------------------------------

#define PiexlToPoint(_p)   ((_p) / [UIScreen mainScreen].scale)


//随机数
//----------------------------------------------------------
//#define RANDOM_SEED() srandom((unsigned)time(NULL))
#define RANDOM_INT(_MIN, _MAX)   ((_MIN) + arc4random() % ((_MAX) - (_MIN) + 1))
#define RANDOM_FLOAT(_MIN, _MAX) ((_MIN) + RANDOM_0_1() * ((_MAX) - (_MIN)))
#define RANDOM_0_1()             ((double)arc4random() / UINT32_MAX)

//生成随机颜色
#define RANDOM_COLOR(_alpha) [UIColor colorWithRed:RANDOM_0_1() \
                                             green:RANDOM_0_1() \
                                              blue:RANDOM_0_1() \
                                             alpha:_alpha]
#endif
