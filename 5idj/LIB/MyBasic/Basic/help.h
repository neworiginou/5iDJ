//
//  help.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-11.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

/*
 *
 *常用帮助函数定义
 *
 */

//----------------------------------------------------------

#import <UIKit/UIKit.h>

//----------------------------------------------------------

#ifndef Help_h
#define Help_h

//----------屏幕尺寸及适配相关--------------
//----------------------------------------------------------

/*
 *获取系统版本
 */
float systemVersion();

/*
 *获取屏幕尺寸
 */
CGSize screenSize();

///*
// *获取适配系统的frame
// */
//CGRect adaptiveRect(CGRect frame);

#define StatusBarHeight         20.f
#define NavigationBarHeight     44.f
#define AspectScaleLenght(_x)  ((_x) * screenWidthScaleFactor())

//屏幕宽缩放比例
static inline CGFloat screenWidthScaleFactor(){
    return screenSize().width / 320.f;
}

//----------自动布局--------------
//----------------------------------------------------------

/*
 *添加边限制,view为要添加限制的视图，superView为其父视图，后面不定参数为属性与距离的组合，以
 *NSLayoutAttributeNotAnAttribute结尾
 */
void addEdgeConstraint(UIView *view,UIView *superView,...);

/*
 *添加大小,view为要添加限制的视图，后面不定参数为大小属性与距离的组合，以NSLayoutAttributeNotAnAttribute结尾
 */
void addSizeConstraint(UIView *view,...);


//----------字符串相关--------------
//----------------------------------------------------------

/*
 *获得唯一标识ID，该ID与时间和当前机器有关
 */
NSString * getUniqueID();


typedef enum {
    HashFuncType_MD2,
    HashFuncType_MD4,
    HashFuncType_MD5,
    HashFuncType_SHA1,
    HashFuncType_SHA224,
    HashFuncType_SHA256,
    HashFuncType_SHA384,
    HashFuncType_SHA512
}HashFuncType;

/*
 *获得Hash字符串
 */
NSString * hashStrWithStr(NSString *STR,HashFuncType TYPE);


//生成随机字符串
NSString * getRandomString(NSUInteger strLength);

/*
 *获取指定格式的当前日期字符串
 */
NSString * currentDateStringWithFormatter(NSString *dateFormatter);

/*
 *获取视频播放格式的时间字符串 hh:mm:ss
 */
NSString * moviePlayDurationFormatterString(NSTimeInterval playDuration,BOOL flexible);

//是否是手机号
BOOL isPhoneNumber(NSString *mobileNum);

//是否是邮箱
BOOL isEmailAddress(NSString * email);


//----------图片相关--------------
//----------------------------------------------------------

typedef NS_ENUM(int,MyScaleMode){
    /**  不改变长宽比，缩放至合适大小 */
    MyScaleModeAspectFit  = 0,
    /**  不改变长宽比，缩放至合适大小填充 */
    MyScaleModeAspectFill = 1,
    /**  可能改变长宽比，缩放至填充 */
    MyScaleModeFill       = 2
};

/**
 * 将源大小按具体模式缩放至目标大小
 * @param sourceSize sourceSize为源大小
 * @param targetSize targetSize为目标大小
 * @param scaleMode  scaleMode未缩放模式
 * @return 返回缩放后的大小
 */
CGSize sizeWithScaleMode(CGSize sourceSize,CGSize targetSize,MyScaleMode scaleMode);


/**
 * 图片的缩放模式
 */
typedef NS_ENUM(int,ImageScaleMode){
    /**  不改变长宽比，缩放至合适大小 */
    ImageScaleModeAspectFit  = MyScaleModeAspectFit,
    /**  不改变长宽比，缩放至合适大小填充，可能会裁剪图片 */
    ImageScaleModeAspectFill = MyScaleModeAspectFill,
    /**  可能改变长宽比，缩放至填充 */
    ImageScaleModeFill       = MyScaleModeFill
};

/**
 * 将图片按特定模式缩放至指定大小，返回压缩后的图片
 * @param image image为需要缩放的图片，image理因不为nil，为nil将返回nil
 * @param size  size为目标显示的大小,size应该有效（长和宽都大于0），否则将抛出异常
 * @param scaleMode scaleMode为图片缩放模式，具体取值请参看其定义
 * @return 返回压缩后的图片
 */
UIImage * imageScaleToSize(UIImage * image, CGSize size, ImageScaleMode scaleMode);


//截取视图
UIImage * snapshotView(UIView * view);


//返回大小可变的某颜色的图片
UIImage * resizableImageWithColor(UIColor * color);

/**
 * 生成认证码图片
 * @param authCode authCode为认证码，为nil或长度为0将返回nil
 * @param fontSize fontSize为字体大小,会有小范围的波动
 * @return 返回生成认证码的图片
 */
UIImage * createAuthCodeImage(NSString * authCode,CGFloat fontSize);


//----------消息相关--------------
//----------------------------------------------------------

@class     MBProgressHUD;
@protocol  MyActivityIndicatorViewProtocol;

//显示消息
MBProgressHUD * showMessage(UIView *view,NSString *titleText,NSString * detailText);

//显示带有用户视图的消息
MBProgressHUD * showMessageWithCustomView(UIView *view,NSString *titleText,NSString * detailText,UIView * customView);

//显示错误消息
MBProgressHUD * showErrorMessage(UIView *view,NSError *error,NSString *titleText);

//显示成功消息
MBProgressHUD * showSuccessMessage(UIView *view,NSString *titleText,NSString * detailText);


//显示MBProgressHUD进度
MBProgressHUD * showHUDWithActivityIndicatorView(UIView * view,UIView<MyActivityIndicatorViewProtocol> * activityIndicatorView,NSString *title);

MBProgressHUD * showHUDWithMyActivityIndicatorView(UIView * view,UIColor *color,NSString *title);


//显示当前网络环境
void showNetworkStatusMessage(UIView *view);


//显示
UIAlertView * showAlertView(NSString *titleText,NSString * detailText);


//----------文件相关--------------
//----------------------------------------------------------

/*
 *确保路径存在,如果成功返回YES
 */
BOOL makeSrueDirectoryExist(NSString *path);


/**
 * 获取文件大小
 * @param filePath filePath为文件路径
 * @return 返回文件大小，单位byte，若路径无效或者为指定一个路径，则返回0
 */
long long fileSizeAtPath(NSString *filePath);

/**
 * 获取指定文件夹路径下的所有文件总大小
 * @param folderPath folderPath为文件夹路径
 * @return 返回所有文件总大小，单位byte，若路径无效，则返回0，若路径指定一个文件，则返回文件大小
 */
long long folderSizeAtPath(NSString *folderPath);

/**
 * 异步获取文件夹的所有文件的总大小
 * @param folderPath folderPath为文件夹路径，若路径无效，则返回0，若路径指定一个文件，则返回文件大小
 * @param completeBlock completeBlock为结果返回的block，在主线程调用
 */
void folderSizeAtPath_asyn(NSString *folderPath, void (^completeBlock)(long long));

/**
 * 删除指定路径上的项目
 * @param path path为路径
 * @param onlyRemoveFile onlyRemoveFile指示是否只删除文件，如果为YES，则只删除文件，不破坏目录结构
 * @return 若路径有效切删除成功则返回YES，无效返回NO
 */
BOOL removeItemAtPath(NSString * path,BOOL onlyRemoveFile);


//----------动画相关--------------
//----------------------------------------------------------

typedef NS_ENUM(int,MoveAnimtedDirection) {
    MoveAnimtedDirectionUp,
    MoveAnimtedDirectionDown,
    MoveAnimtedDirectionLeft,
    MoveAnimtedDirectionRight
};

//执行平移动画
void playAnimated(UIView * view,MoveAnimtedDirection animtedDirection,NSTimeInterval duration,void(^animationBlock)(),void(^completeBlock)());

//----------索引相关--------------
//----------------------------------------------------------

//获取指定section上的连续的在range范围的indexPath
NSArray * indexPathsFromRange(NSInteger section,NSRange range);

NSArray * indexPathsFromIndexSet(NSInteger section,NSIndexSet * indexSet);


//核对index在range范围内，不在则抛出异常
void checkIndexAtRange(NSUInteger index,NSRange range);


//----------其它--------------
//----------------------------------------------------------

void gotoAppStore(NSString * appID);


/*
 *输出自动释放池信息
 */
extern void _objc_autoreleasePoolPrint();


/*
 *获取指定方向上的旋转仿射变换矩阵
 */
CGAffineTransform rotationAffineTransformForOrientation(UIInterfaceOrientation orientation);


//设置网络活动指示器的显示情况
void showNetworkActivityIndicator(BOOL bShow);


//返回直线layer
CAShapeLayer * createLineLayer(CGPoint startPoint,CGPoint endPoint,CGFloat lineWidth,UIColor * lineColor);


//是否耳机是插入的
BOOL isHeadsetPluggedIn();

//----------------------------------------------------------

static inline float radians (float degrees) { return degrees * M_PI/180;}


//----------------------------------------------------------

@class NSPersistentStoreCoordinator;

//移除可持续化文件
void removePersistentStore(NSPersistentStoreCoordinator * persistentStoreCoordinator,NSURL * storeURL);

//----------------------------------------------------------

//默认重用定义
extern  NSString * const defaultReuseDef;


#endif
