//
//  UIImageView+URL.h
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import <UIKit/UIKit.h>
#import "MyImageDownLoadManager.h"

//----------------------------------------------------------

typedef void(^SuccessBlock)(UIImageView *,UIImage *);
typedef void(^FailureBlock)(UIImageView *,NSError *);

#define ImageFadeInAnimateSuccessBlock                  \
    ^(UIImageView * imageView,UIImage * image){         \
        imageView.alpha = 0.f;                          \
        [UIView animateWithDuration:1.f animations:^{  \
            imageView.alpha = 1.f;                      \
        }];                                             \
    }

/** 图片加载过程视图的模式 */
typedef NS_ENUM(NSInteger,ImageLoadProgressViewMode){
    /** 无加载过程视图 */
    ImageLoadProgressViewModeNone,
    /** 无限加载过程视图 */
    ImageLoadProgressViewModeIndeterminate,
    /** 进度加载过程视图 */
    ImageLoadProgressViewModeDeterminate
};


/** 图片加载状态 */
typedef NS_ENUM(NSInteger,ImageLoadStatus){
    /** 正常加载状态 */
    ImageLoadStatusNormal,
    /** 加载失败 */
    ImageLoadStatusFail
};

typedef NS_OPTIONS(NSUInteger,ImageLoadFailPolicy){
    ImageLoadFailPolicyNone                 = 0,
    ImageLoadFailPolicyReloadWhenFail       = 1,
    ImageLoadFailPolicyAutoReloadWhenNoNet  = 2,
    ImageLoadFailPolicyShowNoNetIndicate    = 4,
    
    ImageLoadFailPolicyDefault   =  ImageLoadFailPolicyAutoReloadWhenNoNet |
                                   ImageLoadFailPolicyShowNoNetIndicate,
    
    ImageLoadFailPolicyAllPolicy =  ImageLoadFailPolicyDefault |
                                   ImageLoadFailPolicyReloadWhenFail
};

//----------------------------------------------------------
@interface ImageLoadConfiguration : NSObject


- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(ImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
            loadStatus:(ImageLoadStatus)loadStatus
        downLoadPolicy:(ImageDownLoadPolicy)policy
  imageDownLoadManager:(MyImageDownLoadManager *)manager
               success:(SuccessBlock)success
               failure:(FailureBlock)failure;

@property(nonatomic,strong,readonly) NSString                * url;
@property(nonatomic,strong,readonly) UIImage                 * placeholderImage;
@property(nonatomic,readonly)        ImageLoadProgressViewMode progressViewMode;
//@property(nonatomic,readonly)        BOOL                      canReloadWhenFail;
@property(nonatomic,readonly)        ImageLoadFailPolicy       loadFailPolicy;
@property(nonatomic,readonly)        ImageLoadStatus           loadStatues;
@property(nonatomic,readonly)        ImageDownLoadPolicy       downLoadPolicy;
@property(nonatomic,strong,readonly) MyImageDownLoadManager    * downLoadManager;
@property(nonatomic,copy,readonly)   SuccessBlock              successBlock;
@property(nonatomic,copy,readonly)   FailureBlock              failureBlock;

@end



//----------------------------------------------------------

/**
 * 该分类为UIImageView提供直接通过图片URL设置图片的方法
 */
@interface UIImageView (URL) <MyImageDownLoadDelegate>


/**
 * 通过图片url初始化imageView
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 * @return UIImageView实例
 */
- (id)initWithImageURL:(NSString *)url;

/**
 * 通过图片url初始化imageView
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 * @return UIImageView实例
 */
- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(ImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy;

/**
 * 通过图片url初始化imageView
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 * @return UIImageView实例
 */
- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(ImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
               success:(SuccessBlock)success
               failure:(FailureBlock)failure;


/**
 * 通过图片url初始化imageView
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 * @return UIImageView实例
 */
- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(ImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(ImageDownLoadPolicy)policy
  imageDownLoadManager:(MyImageDownLoadManager *)manager
               success:(SuccessBlock)success
               failure:(FailureBlock)failure;

/**
 * 通过图片加载配置初始化
 */
- (id)initWithConfiguration:(ImageLoadConfiguration *)configuration;


/**
 * 通过图片URL设置image
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 */
- (void)setImageWithURL:(NSString *)url;

/**
 * 通过图片URL设置image
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 */
- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(ImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy;


/**
 * 通过图片URL设置image
 * @see 参数意义请参考setImageWithURL:placeholderImage:showLoadProgressView:
 * downLoadPolicy:imageDownLoadManager:success:failure:
 */
- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(ImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
                success:(SuccessBlock)success
                failure:(FailureBlock)failure;

/**
 * 通过图片URL设置image，采用缓存机制
 * @param url url为图片url，可以是网络url和本地文件url
 * @param placeholderImage placeholderImage为图片加载前显示的图片
 * @param success success为加载成功后调用的block
 * @param failure failure为加载失败后调用的block
 * @param policy  policy为下载策略，默认为ImageDownLoadPolicyDefault
 * @param manager manager为使用的图片下载管理器,使用自定义的图片管理器来实现更多缓存上的操作，传入nil使用共享的下载管理器
 * @param progressViewMode progressViewMode指示加载视图模式
 * @return 无
 */
- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(ImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
         downLoadPolicy:(ImageDownLoadPolicy)policy
   imageDownLoadManager:(MyImageDownLoadManager *)manager
                success:(SuccessBlock)success
                failure:(FailureBlock)failure;

/**
 * 通过图片加载配置设置image
 */
- (void)setImageWithConfiguration:(ImageLoadConfiguration *)configuration;

/**
 * 取消加载图片
 */
- (void)cancleLoadURLImage:(BOOL)cancleNetRequest;

/**
 * 共享的图片下载管理
 * @return 图片下载管理类的实例，是个单例
 */
+ (MyImageDownLoadManager *)shareImageDownLoadManager;

@end
