//
//  help.c
//  GamePlayerDemo
//
//  Created by Xuzhanya on 13-12-11.
//  Copyright (c) 2013年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import  "help.h"
#include "MacroDef.h"
#import  "MBProgressHUD.h"
#import  "MyActivityIndicatorView.h"
#import "MyNetReachability.h"

#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreData/CoreData.h>

//----------------------------------------------------------

float systemVersion()
{
    static float version = 0.f;
    
    if (version == 0.f) {
        version = [[[UIDevice currentDevice] systemVersion] floatValue];
    }
    
    return version;
}

CGSize screenSize()
{
    static CGSize _screenSize = {0,0};
    
    if (_screenSize.width == 0.f) {
        _screenSize = [UIScreen mainScreen].bounds.size;
    }
    
    return _screenSize;
}

//inline CGRect adaptiveRect(CGRect frame)
//{
//    CGFloat Yoffset = (systemVersion() >= 7.0f) ? StatusBarHeight : 0.f;
//    return CGRectOffset(frame, 0.f, Yoffset);
//}
//


void addEdgeConstraint(UIView *view,UIView *superView,...)
{
    va_list args;
    va_start(args, superView);
    
    while (true) {
        
        NSLayoutAttribute attr = va_arg(args, NSLayoutAttribute);
        
        if (attr == NSLayoutAttributeNotAnAttribute) {
            break;
        }

        double constance = va_arg(args, double);
        
        setEdgeConstraint(view, attr, superView, constance);
    }
    
    va_end(args);
}


void addSizeConstraint(UIView *view,...)
{
    va_list args;
    va_start(args, view);
    
    while (args!=nil) {
        
        NSLayoutAttribute attr = va_arg(args, NSLayoutAttribute);
        
        if (attr == NSLayoutAttributeNotAnAttribute) {
            break;
        }
        
        double constance = va_arg(args, double);
        setSizeConstraint(view, attr, constance);
    }
    
    va_end(args);
}

//获得唯一标识ID
NSString * getUniqueID()
{
    //创建一个CFUUIDRef类型对象
    CFUUIDRef newUniqueID=CFUUIDCreate(kCFAllocatorDefault);
    
    //获得一个唯一的字符ID
    CFStringRef newUniqueString=CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    //转换成NSString
    NSString *str=(__bridge NSString *)newUniqueString;
    
    //释放
    CFRelease(newUniqueID);
    CFRelease(newUniqueString);
    
    return str;
}


NSString * hashStrWithStr(NSString *STR,HashFuncType TYPE)
{
    if (!STR) {
        return nil;
    }
    
    unsigned char * (*caculateFunc)(const void *, CC_LONG , unsigned char *);
    CC_LONG DIGEST_LENGTH = 0;
    
    
#define SwitchCaseWithHashFuncName(_name)         \
case HashFuncType_##_name:                        \
    DIGEST_LENGTH = CC_##_name##_DIGEST_LENGTH;   \
    caculateFunc = CC_##_name;                    \
    break;
    
    switch (TYPE) {
        SwitchCaseWithHashFuncName(MD2)
        SwitchCaseWithHashFuncName(MD4)
        SwitchCaseWithHashFuncName(MD5)
        SwitchCaseWithHashFuncName(SHA1)
        SwitchCaseWithHashFuncName(SHA224)
        SwitchCaseWithHashFuncName(SHA256)
        SwitchCaseWithHashFuncName(SHA384)
        SwitchCaseWithHashFuncName(SHA512)
    }
    
    unsigned char *digest = malloc(sizeof(unsigned char) * DIGEST_LENGTH);
    
    NSData *stringBytes = [STR dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *returnStr = nil;
    
    if (caculateFunc([stringBytes bytes],(CC_LONG)[stringBytes length],digest)) {
        
        returnStr = [NSMutableString stringWithCapacity:DIGEST_LENGTH * 2];
        
        for (CC_LONG i = 0; i < DIGEST_LENGTH; i ++) {
            [returnStr appendFormat:@"%02X",digest[i]];
        }
    }
    
    free(digest);
    
    return returnStr;
}

//生成随机字符串
NSString * getRandomString(NSUInteger strLength)
{
    NSString * randomString = nil;
    
    if (strLength != 0) {
        
        char  *digest = malloc(strLength * sizeof(char));
        
        for (int i = 0; i< strLength;  ++ i) {
            
            int j = '0' + (arc4random_uniform(75));
            
            if((j>=58 && j<= 64) || (j>=91 && j<=96)){
                -- i;
            }else{
                digest[i] = (char)j;
            }
        }
        
        randomString = [[NSString alloc] initWithBytes:digest length:strLength encoding:NSUTF8StringEncoding];
        
        free(digest);
    }
    
    return randomString;
}


NSString * currentDateStringWithFormatter(NSString *formatter)
{
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = formatter;
    return [dateFormatter stringFromDate:[NSDate date]];
}

NSString * moviePlayDurationFormatterString(NSTimeInterval playDuration,BOOL flexible)
{
    //hour
    int hour = HourForTimeInterVal(playDuration);
    
    //减去小时
    playDuration -= hour * SecPerHour;
    
    //min
    int min = MinForTimeInterVal(playDuration);
    
    //减去分钟
    playDuration -= min * SecPerMin;
    
    //秒
    int sec = floor(playDuration);
    
    //格式化
    if (flexible && hour == 0) {
        return [NSString stringWithFormat:@"%02d:%02d",min,sec];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,min,sec];
    }
}



//手机判断
BOOL isPhoneNumber(NSString *mobileNum)
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,163,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if ([regextestmobile evaluateWithObject:mobileNum]
        || [regextestcm evaluateWithObject:mobileNum]
        || [regextestct evaluateWithObject:mobileNum]
        || [regextestcu evaluateWithObject:mobileNum]){
        return YES;
    }else{
        return NO;
    }
}

//邮箱判断
BOOL isEmailAddress(NSString * email)
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}



UIImage * imageScaleToSize(UIImage * image, CGSize size, ImageScaleMode scaleMode)
{
    
    if (image) {
        
        //检测size
        if (size.height <= 0 || size.width <=0 ) {
            
            @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                              reason:@"size不合法!"
                                            userInfo:nil];
        }
        
        //图片大小
        CGSize imageSize = image.size;
 
        //尺寸相等
        if (CGSizeEqualToSize(imageSize, size)) {
            return image;
        }
        
        CGFloat width       = imageSize.width;
        CGFloat height      = imageSize.height;
        CGFloat scaleWidth  = size.width;
        CGFloat scaleHeight = size.height;
        
        //长宽其一为0
        if (width == 0 || height == 0) {
            return image;
        }
        
        //计算长宽压缩比例
        CGFloat widthFactor = scaleWidth / width;
        CGFloat heightFactor = scaleHeight / height;
        
        //目标大小
        CGSize targetSize = size;
        //绘制的矩形
        CGRect drawRect = CGRectZero;
        
        
        switch (scaleMode) {
            case ImageScaleModeAspectFit:
            {
                //压缩比例
                CGFloat scaleFactor = MIN(widthFactor, heightFactor);
                //目标大小
                targetSize = CGSizeMake(width * scaleFactor, height * scaleFactor);
                //绘制矩形
                drawRect.size = targetSize;
                
            }
                break;
            
            case ImageScaleModeAspectFill:
            {
                //压缩比例
                CGFloat scaleFactor = MAX(widthFactor, heightFactor);
                
                //绘制图像的大小
                CGSize drawSize = CGSizeMake(width * scaleFactor, height * scaleFactor);
                
                //绘制矩形
                //原点
                drawRect.origin = CGPointMake((scaleWidth -  drawSize.width) * 0.5f,
                                              (scaleHeight - drawSize.height) * 0.5f);
                //大小
                drawRect.size = drawSize;
            }
                
                break;
                
            case ImageScaleModeFill:
            {
                drawRect.size = size;
            }
                
                break;
        }
        
        //设置大小，超出会剪裁
        UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.f);
        
        //绘制在矩形范围内
        [image drawInRect:drawRect];
        
        UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        
        return resultImage;
        
    }
    
    return nil;
}

CGSize sizeWithScaleMode(CGSize sourceSize,CGSize targetSize,MyScaleMode scaleMode)
{
    //计算长宽压缩比例
    CGFloat widthFactor  = sourceSize.width  ? targetSize.width  / sourceSize.width  : 0.f;
    CGFloat heightFactor = sourceSize.height ? targetSize.height / sourceSize.height : 0.f;
    
    widthFactor  = fabs(widthFactor);
    heightFactor = fabs(heightFactor);
    
    switch (scaleMode) {
        case MyScaleModeAspectFill:
            
            widthFactor  = MAX(widthFactor, heightFactor);
            heightFactor = widthFactor;
            
            break;
            
        case MyScaleModeAspectFit:
            
            widthFactor  = MIN(widthFactor, heightFactor);
            heightFactor = widthFactor;
            
            break;
            
        default:
            break;
    }
    
    return CGSizeMake(sourceSize.width * widthFactor, sourceSize.height * heightFactor);
}


UIImage * snapshotView(UIView * view)
{
    if (view) {
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
        
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return nil;
}


UIImage * resizableImageWithColor(UIColor * color)
{
    UIGraphicsBeginImageContext(CGSizeMake(1.f, 1.f));
    
    [color setFill];
    UIRectFill(CGRectMake(0.f, 0.f, 1.f, 1.f));
    
    UIImage * image = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];
    
    UIGraphicsEndImageContext();
    
    return image;
}

UIImage * createAuthCodeImage(NSString * authCode,CGFloat fontSize)
{
    UIImage * authCodeImage = nil;
    NSUInteger authCodeLength = authCode.length;
    
    if (authCodeLength != 0) {
        
        //文字的绘制大小
        CGSize textDrawSize = TEXTSIZE(authCode,[UIFont systemFontOfSize:fontSize]);
        CGSize minCharDrawSize = TEXTSIZE(@"S",[UIFont systemFontOfSize:fontSize]);
        textDrawSize.width = MAX(textDrawSize.width, minCharDrawSize.width * authCodeLength);
        
        
        //图片大小
        CGSize imageSize = CGSizeMake(floorf(textDrawSize.width * 1.6f), floorf(textDrawSize.height * 1.5f));
        
        //创建图片上下文
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.f);
        
        //开始绘制
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        
        //填充随机背景色
//        [RANDOM_COLOR(0.2f) setFill];
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0.f, 0.f, imageSize.width, imageSize.height));
        
        //每个字符的宽度
        CGFloat charWidth = imageSize.width / authCodeLength;
        
        //绘制随机码，每次绘制一个字符
        for (NSUInteger i = 0; i < authCodeLength ; ++ i) {
            
            //当前绘制的字符
            NSString * charStr = [authCode substringWithRange:NSMakeRange(i, 1)];
            //绘制的矩形
            CGRect drawRect = CGRectMake(charWidth * i, 0.f, charWidth, imageSize.height);
            
            //生成一定范围内的随机大小字体
            UIFont * font = [UIFont systemFontOfSize:RANDOM_FLOAT(0.8f, 1.3f) * fontSize];
            
            //字符实际绘制尺寸
            CGSize actualDrawSize = TEXTSIZE(charStr, font);
            
            //随机偏移
            CGFloat drawPointX = (CGRectGetWidth(drawRect) - actualDrawSize.width) * RANDOM_0_1() + CGRectGetMinX(drawRect);
            CGFloat drawPointY = (CGRectGetHeight(drawRect) - actualDrawSize.height) * RANDOM_0_1() + CGRectGetMinY(drawRect);
            
            
            //保存当前状态
            CGContextSaveGState(currentContext);
            
            CGContextTranslateCTM(currentContext, drawPointX,  drawPointY);
            
            //设置随机旋转
            if (i == 0) {
                CGContextRotateCTM(currentContext,radians(-45.f * RANDOM_0_1()));
            }else if (i == authCodeLength - 1){
                CGContextRotateCTM(currentContext,radians(45.f * RANDOM_0_1()));
            }else{
                CGContextRotateCTM(currentContext,radians(RANDOM_FLOAT(- 45.f, 45.f)));
            }
            
            CGContextTranslateCTM(currentContext, - drawPointX, - drawPointY);
            
            
            //绘制字符
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
            NSDictionary * attribute = @{NSForegroundColorAttributeName : RANDOM_COLOR(1.f),
                                         NSFontAttributeName : font};
            [charStr drawAtPoint:CGPointMake(drawPointX, drawPointY) withAttributes:attribute];
#else
            [RANDOM_COLOR(1.f) setStroke];
            [charStr drawAtPoint:CGPointMake(drawPointX, drawPointY) withFont:font];
#endif
            
            //恢复之前状态
            CGContextRestoreGState(currentContext);
        }
        
        
        //绘制干扰线
        
        //随机干扰线个数
        NSInteger minLineCount = MAX(3, authCodeLength);
        NSInteger maxLineCount = MAX(minLineCount, authCodeLength * 1.5f);
        NSInteger lineCount = RANDOM_INT(minLineCount, maxLineCount);
        
        //最短线长的平方
        NSInteger minLineLength_2 = MIN(charWidth, imageSize.height);
        minLineLength_2 = minLineLength_2 * minLineLength_2;
        
        for(int i = 0; i < lineCount; ++ i) {
            
            CGPoint startPoint = CGPointMake(RANDOM_0_1() * imageSize.width, RANDOM_0_1() * imageSize.height);
            CGPoint endPoint = CGPointMake(RANDOM_0_1() * imageSize.width, RANDOM_0_1() * imageSize.height);
            
            CGFloat xOffset = startPoint.x - endPoint.x;
            CGFloat yOffset = startPoint.y - startPoint.y;
            
            //线长长于最短长度，则划出来
            if (minLineLength_2 <= (xOffset * xOffset + yOffset * yOffset)) {
                
                //设置随机线宽
                CGContextSetLineWidth(currentContext, RANDOM_FLOAT(0.8f, 1.2f));
                
                //设置随机线的颜色
                CGContextSetStrokeColorWithColor(currentContext, [RANDOM_COLOR(1.f) CGColor]);
                //随机起点
                CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
                //随机终点
                CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
                //绘制
                CGContextStrokePath(currentContext);
                
            }
        }
        
        //获取图片并结束上下文
        authCodeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return authCodeImage;
}



MBProgressHUD * showMessage(UIView *view,NSString * titleText,NSString * detailText)
{
    MBProgressHUD * progressHUD = showMessageWithCustomView(view,titleText,detailText,nil);
    progressHUD.mode = MBProgressHUDModeText;
    
    return progressHUD;
}

MBProgressHUD * showMessageWithCustomView(UIView *view,NSString *titleText,NSString * detailText,UIView * customView)
{
    //初始化
    MBProgressHUD * progressHUD = [[MBProgressHUD alloc] init];
    progressHUD.removeFromSuperViewOnHide = YES;
    progressHUD.mode = MBProgressHUDModeCustomView;
    progressHUD.customView = customView;
    progressHUD.labelText = titleText;
    progressHUD.detailsLabelText = detailText;
    
    if (!view) {

        UIWindow * topWindow = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
        topWindow.windowLevel = UIWindowLevelAlert;
        [topWindow makeKeyAndVisible];
        [topWindow addSubview:progressHUD];
        
        //构成短暂的循环保留
        progressHUD.completionBlock = ^{
            topWindow.hidden= YES;
        };
        
    }else{
        [view addSubview:progressHUD];
    }
    
    //显示
    [progressHUD show:YES];
    
    //1s后消失
    [progressHUD hide:YES afterDelay:1.f];
    
    return progressHUD;

}

//显示错误消息
MBProgressHUD * showErrorMessage(UIView *view,NSError *error,NSString *titleText)
{
    return showMessageWithCustomView(view, titleText, [error localizedDescription], [[UIImageView alloc] initWithImage:ImageWithName(@"error_msg.png")]);
}

//显示成功消息
MBProgressHUD * showSuccessMessage(UIView *view,NSString *titleText,NSString * detailText)
{
    return showMessageWithCustomView(view, titleText, detailText, [[UIImageView alloc] initWithImage:ImageWithName(@"success_msg.png")]);
}

MBProgressHUD * showHUDWithActivityIndicatorView(UIView * view,UIView<MyActivityIndicatorViewProtocol> * activityIndicatorView,NSString *title)
{
    MBProgressHUD * progressHUD = showMessageWithCustomView(view,title,nil,activityIndicatorView);
    [activityIndicatorView startAnimating];
    
    return progressHUD;
}

MBProgressHUD * showHUDWithMyActivityIndicatorView(UIView * view,UIColor *color,NSString *title)
{
    MyActivityIndicatorView * activityIndicatorView = [[MyActivityIndicatorView alloc] initWithStyle:MyActivityIndicatorViewStyleIndeterminate];
    activityIndicatorView.twoStepAnimation = NO;
    activityIndicatorView.tintColor = color;
    
    return showHUDWithActivityIndicatorView(view, activityIndicatorView,title);
}


void showNetworkStatusMessage(UIView *view)
{
    //网络状态
    NetworkStatus status = [MyNetReachability currentNetReachabilityStatus];
    
    if (status == kNotReachable) {
        showMessage(view, @"当前无可用网络", nil);
    }else if (status == kReachableViaWWAN){
        showMessage(view, @"当前处于非WIFI网络", nil);
    }else{
        showMessage(view, @"当前处于WIFI网络", nil);
    }
}

UIAlertView * showAlertView(NSString *titleText,NSString * detailText)
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:titleText
                                                         message:detailText
                                                        delegate:nil
                                               cancelButtonTitle:@"知道了"
                                               otherButtonTitles:nil];
    
    [alertView show];
    
    return alertView;
}


BOOL makeSrueDirectoryExist(NSString *path)
{
    BOOL isDir;
    BOOL isExis = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    if (!isExis || !isDir) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return YES;
}


long long fileSizeAtPath(NSString *filePath)
{
    BOOL isDir;
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath isDirectory:&isDir] && !isDir){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    
    return 0;
}

long long folderSizeAtPath(NSString *folderPath)
{
    //1.判断路径所指定的类型
    //2.遍历所有子路径计算大小

    BOOL isDir;
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath isDirectory:&isDir]){
        return 0;
    }else if (!isDir){
        return [[manager attributesOfItemAtPath:folderPath error:nil] fileSize];
    }
    
    //遍历子路径
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        //完整路径
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += fileSizeAtPath(fileAbsolutePath);
    }
    
    return folderSize;
}

void folderSizeAtPath_asyn(NSString *folderPath, void (^completeBlock)(long long))
{
    if (completeBlock) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            long long resultSize = folderSizeAtPath(folderPath);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(resultSize);
            });
            
        });
    }
}

BOOL removeItemAtPath(NSString * path,BOOL onlyRemoveFile)
{
    BOOL isDir;
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:path isDirectory:&isDir]){
        return NO;
    }else if (!isDir || !onlyRemoveFile){
        return  [manager removeItemAtPath:path error:nil];
    }else{
        
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
        
        NSString * fileName;
        
        while ((fileName = [childFilesEnumerator nextObject]) != nil) {
            //完整路径
            NSString* fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
            
            //删除文件
            if ([manager fileExistsAtPath:fileAbsolutePath isDirectory:&isDir] && !isDir) {
                [manager removeItemAtPath:fileAbsolutePath error:nil];
            }
            
        }
        
         return YES;
    }

}

void playAnimated(UIView * view,MoveAnimtedDirection animtedDirection,NSTimeInterval duration,void(^animationBlock)(),void(^completeBlock)())
{
    if (view) {
        
        CGPoint startcenter = view.center;
        CGPoint endCenter = startcenter;
        CGSize  size   = view.bounds.size;
        
        switch (animtedDirection) {
            case MoveAnimtedDirectionUp:
                startcenter.y += size.height;
                break;
                
            case MoveAnimtedDirectionDown:
                startcenter.y += size.height;
                break;
                
            case MoveAnimtedDirectionLeft:
                startcenter.x += size.width;
                break;
                
            case MoveAnimtedDirectionRight:
                startcenter.x -= size.width;
                break;
            default:
                break;
        }
        
        view.center = startcenter;
        
        [UIView animateWithDuration:duration animations:^{
        
            view.center = endCenter;
            
            if (animationBlock) {
                animationBlock();
            }
            
            
        } completion:^(BOOL finished){
        
            if (completeBlock) {
                completeBlock();
            }
            
        }];
        
    }
}

void checkIndexAtRange(NSUInteger index,NSRange range)
{
    if (!NSLocationInRange(index,range)) {
        
        @throw [[NSException alloc] initWithName:NSRangeException
                                          reason:[NSString stringWithFormat:@"index = %u 超出范围 %u ~ %u",(unsigned int)index,(unsigned int)range.location,(unsigned int)NSMaxRange(range)]
                                        userInfo:nil];
    }
    
}


NSArray * indexPathsFromRange(NSInteger section,NSRange range)
{
    return indexPathsFromIndexSet(section, [NSIndexSet indexSetWithIndexesInRange:range]);
}

NSArray * indexPathsFromIndexSet(NSInteger section,NSIndexSet * indexSet)
{
    NSMutableArray * indexPaths = [NSMutableArray arrayWithCapacity:indexSet.count];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    
    return indexPaths;
}


CGAffineTransform rotationAffineTransformForOrientation(UIInterfaceOrientation orientation)
{
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(- M_PI_2);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(M_PI);
            break;
            
        default:
            return CGAffineTransformIdentity;
            break;
    }
}


void showNetworkActivityIndicator(BOOL bShow)
{
    static NSUInteger networkActivityIndicatorShowTimes = 0;
    
    if (bShow) {
        
        if (networkActivityIndicatorShowTimes == 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
        
        //显示次数+1
        networkActivityIndicatorShowTimes ++ ;
        
    }else if (networkActivityIndicatorShowTimes > 0) {
        
        networkActivityIndicatorShowTimes -- ;
        
        //无显示次数，则隐藏
        if (networkActivityIndicatorShowTimes == 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
    
}

CAShapeLayer * createLineLayer(CGPoint startPoint,CGPoint endPoint,CGFloat lineWidth,UIColor * lineColor)
{
    CAShapeLayer * lineLayer = [[CAShapeLayer alloc] init];
    lineLayer.lineWidth = lineWidth;
    lineLayer.strokeColor = lineColor.CGColor;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    CGPathCloseSubpath(path);
    lineLayer.path = path;
    CGPathRelease(path);
    
    return lineLayer;
}


//void gotoAppStorePageRaisal(NSString * appID)
//{
//    NSString  * nsStringToOpen = [NSString  stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appID];
//
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nsStringToOpen]];
//}


void gotoAppStore(NSString * appID)
{
    NSString  * nsStringToOpen = [NSString  stringWithFormat: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",appID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nsStringToOpen]];
}


BOOL isHeadsetPluggedIn()
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    
    return NO;
}

void removePersistentStore(NSPersistentStoreCoordinator * persistentStoreCoordinator,NSURL * storeURL)
{
    if (storeURL) {
        
        NSPersistentStore * persistentStore = [persistentStoreCoordinator persistentStoreForURL:storeURL];
        if (persistentStore) {
            [persistentStoreCoordinator removePersistentStore:persistentStore error:NULL];
        }
        
        //删除问价
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
    }
}


NSString * const defaultReuseDef = @"defaultReuseDef";


