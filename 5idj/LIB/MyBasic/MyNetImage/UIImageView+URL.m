//
//  UIImageView+URL.m
//  GamePlayerDemo
//
//  Created by Xuzhanya on 14-1-3.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "UIImageView+URL.h"
#import "MBProgressHUD.h"
#import "MyActivityIndicatorView.h"
#import "MyLoadingIndicateView.h"
#import "MacroDef.h"
#import  <objc/runtime.h>

//----------------------------------------------------------

@interface ImageLoadConfiguration()

- (void)startLoadImage;

- (void)failLoadImage;

@end


@implementation ImageLoadConfiguration

- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(ImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
            loadStatus:(ImageLoadStatus)loadStatus
        downLoadPolicy:(ImageDownLoadPolicy)policy
  imageDownLoadManager:(MyImageDownLoadManager *)manager
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
{
    
    self = [super init];
    
    if (self) {
        _url              = url;
        _placeholderImage = placeholderImage;
        _progressViewMode = progressViewMode;
        _loadFailPolicy   = loadFailPolicy;
        _loadStatues      = loadStatus;
        _downLoadPolicy   = policy;
        _downLoadManager  = manager;
        _successBlock     = [success copy];
        _failureBlock     = [failure copy];
    }
    
    return self;
}

- (void)startLoadImage
{
    _loadStatues = ImageLoadStatusNormal;
}

- (void)failLoadImage
{
    _loadStatues = ImageLoadStatusFail;
}


@end


#define IndicateViewViewTag          1234353

static char  ImageLoadConfigurationKey;

@interface UIImageView(_URL)<MyLoadingIndicateViewDelegate>

//图片加载配置
@property(nonatomic,strong) ImageLoadConfiguration * imageLoadConfiguration;

/*
 *图片下载管理器
 */
@property(nonatomic,strong,readonly) MyImageDownLoadManager *imageDownLoadManager;


- (MyLoadingIndicateView *)_loadingIndicateView;

- (BOOL)_hasLoadingIndicateView;

- (void)_startDownloadImage;

- (void)_failDownLoadImage;

@end

//----------------------------------------------------------

@implementation UIImageView (URL)


+ (MyImageDownLoadManager *)shareImageDownLoadManager
{
    static MyImageDownLoadManager * _shareImageDownLoadManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        MyImageCachePool * imageCachePool = [[MyImageCachePool alloc] init];
        
        _shareImageDownLoadManager = [[MyImageDownLoadManager alloc] initWithImageCachePool:imageCachePool
                                                                          concurrentCount:10
                                                                             waitingCount:20];
    });
    
    return _shareImageDownLoadManager;
}

- (void)setImageLoadConfiguration:(ImageLoadConfiguration *)imageLoadConfiguration
{
    objc_setAssociatedObject(self, &ImageLoadConfigurationKey, imageLoadConfiguration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if([self _hasLoadingIndicateView]){
        [self._loadingIndicateView removeFromSuperview];
    }
}

- (ImageLoadConfiguration *)imageLoadConfiguration
{
    return objc_getAssociatedObject(self, &ImageLoadConfigurationKey);
}

- (MyImageDownLoadManager *)imageDownLoadManager
{
    return self.imageLoadConfiguration.downLoadManager ?: [UIImageView shareImageDownLoadManager];
}


//init
//----------------------------------------------------------

- (id)initWithImageURL:(NSString *)url
{
    return [self initWithImageURL:url
                 placeholderImage:nil
                 progressViewMode:ImageLoadProgressViewModeNone
                loadFailPolicy:ImageLoadFailPolicyDefault
                   downLoadPolicy:ImageDownLoadPolicyDefault
             imageDownLoadManager:nil
                          success:nil
                          failure:nil];
}

- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(ImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
{
    return [self initWithImageURL:url
                 placeholderImage:placeholderImage
                 progressViewMode:progressViewMode
                   loadFailPolicy:loadFailPolicy
                   downLoadPolicy:ImageDownLoadPolicyDefault
             imageDownLoadManager:nil
                          success:nil
                          failure:nil];
}

- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(ImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
{
    return [self initWithImageURL:url
                 placeholderImage:placeholderImage
                 progressViewMode:progressViewMode
                   loadFailPolicy:loadFailPolicy
                   downLoadPolicy:ImageDownLoadPolicyDefault
             imageDownLoadManager:nil
                          success:success
                          failure:failure];
}


- (id)initWithImageURL:(NSString *)url
      placeholderImage:(UIImage *)placeholderImage
      progressViewMode:(ImageLoadProgressViewMode)progressViewMode
        loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
        downLoadPolicy:(ImageDownLoadPolicy) policy
  imageDownLoadManager:(MyImageDownLoadManager *)manager
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
{
    self = [self initWithImage:placeholderImage];
    
    if (self) {
        
        //设置
        [self setImageWithURL:url
             placeholderImage:placeholderImage
             progressViewMode:progressViewMode
               loadFailPolicy:loadFailPolicy
               downLoadPolicy:policy
         imageDownLoadManager:manager
                      success:success
                      failure:failure];
    }
    
    return self;
}

- (id)initWithConfiguration:(ImageLoadConfiguration *)configuration
{
    self = [self initWithImage:configuration.placeholderImage];
    
    if (self) {
        [self setImageWithConfiguration:configuration];
    }
    
    return self;
    
}


//setImage
//----------------------------------------------------------

- (void)setImageWithURL:(NSString *)url
{
    [self setImageWithURL:url
         placeholderImage:nil
         progressViewMode:ImageLoadProgressViewModeNone
           loadFailPolicy:ImageLoadFailPolicyDefault
           downLoadPolicy:ImageDownLoadPolicyDefault
     imageDownLoadManager:nil
                  success:nil
                  failure:nil];
}


- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(ImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
{
    [self setImageWithURL:url
         placeholderImage:placeholderImage
         progressViewMode:progressViewMode
           loadFailPolicy:loadFailPolicy
           downLoadPolicy:ImageDownLoadPolicyDefault
     imageDownLoadManager:nil
                  success:nil
                  failure:nil];
}

- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(ImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
                success:(SuccessBlock)success
                failure:(FailureBlock)failure
{
    [self setImageWithURL:url
         placeholderImage:placeholderImage
         progressViewMode:progressViewMode
           loadFailPolicy:loadFailPolicy
           downLoadPolicy:ImageDownLoadPolicyDefault
     imageDownLoadManager:nil
                  success:success
                  failure:failure];
}

- (void)setImageWithURL:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage
       progressViewMode:(ImageLoadProgressViewMode)progressViewMode
         loadFailPolicy:(ImageLoadFailPolicy)loadFailPolicy
         downLoadPolicy:(ImageDownLoadPolicy)policy
   imageDownLoadManager:(MyImageDownLoadManager *)manager
                success:(SuccessBlock)success
                failure:(FailureBlock)failure
{
    
    ImageLoadConfiguration * configuration = [[ImageLoadConfiguration alloc] initWithImageURL:url
                                                        placeholderImage:placeholderImage
                                                        progressViewMode:progressViewMode
                                                          loadFailPolicy:loadFailPolicy
                                                              loadStatus:ImageLoadStatusNormal
                                                          downLoadPolicy:policy
                                                    imageDownLoadManager:manager
                                                                 success:success
                                                                 failure:failure];
    
    [self setImageWithConfiguration:configuration];
    
}

- (void)setImageWithConfiguration:(ImageLoadConfiguration *)configuration
{
    [self cancleLoadURLImage:NO];
    
    //设置配置
    [self setImageLoadConfiguration:configuration];
    
    if (configuration.loadStatues != ImageLoadStatusFail || !(configuration.loadFailPolicy & ImageLoadFailPolicyReloadWhenFail)) {
        [self _startDownloadImage];
    }else{
        [self _failDownLoadImage];
    }
    
}

- (void)cancleLoadURLImage:(BOOL)cancleNetRequest
{
    [[self imageDownLoadManager] cancleDownLoadImage:self forceToCancle:cancleNetRequest];
    
    [self setImageLoadConfiguration:nil];
}


- (void)_startDownloadImage
{
    ImageLoadConfiguration * configuration = self.imageLoadConfiguration;
 
    self.image = nil;
    
    if (configuration) {
        
        //开始下载图片
        [configuration startLoadImage];
        
        //设置hoder图片
        self.image = configuration.placeholderImage;
        
        //设置加载视图
        if (configuration.progressViewMode != ImageLoadProgressViewModeNone) {
            
            self._loadingIndicateView.activityIndicatorView.style = configuration.progressViewMode == ImageLoadProgressViewModeDeterminate ? MyActivityIndicatorViewStyleDeterminate : MyActivityIndicatorViewStyleIndeterminate;
            
            [self._loadingIndicateView showLoadingStatusWithTitle:nil detailText:nil];
            
        }
        
        //开始下载图片
        [[self imageDownLoadManager] startDownLoadImage:self
                                                    URL:configuration.url
                                         downLoadPolicy:configuration.downLoadPolicy];
        
    }else if([self _hasLoadingIndicateView]){
        [self._loadingIndicateView removeFromSuperview];
    }
}

- (void)_failDownLoadImage
{
    ImageLoadConfiguration * configuration = self.imageLoadConfiguration;
    
    self.image = nil;
    
    if (configuration && (configuration.loadFailPolicy & ImageLoadFailPolicyReloadWhenFail)) {
        
        self.userInteractionEnabled = YES;
        
        [configuration failLoadImage];
        
        [self._loadingIndicateView showLoadingErrorStatusWithWithImage:ImageWithName(@"error_tap_reload.png")
                                                                 title:@"点击重新加载"
                                                            detailText:nil];
        
    }else{
        [self setImageLoadConfiguration:nil];
    }
}

- (BOOL)_hasLoadingIndicateView
{
    UIView * indicateView = [self viewWithTag:IndicateViewViewTag];
    
    if (indicateView && [indicateView isMemberOfClass:[MyLoadingIndicateView class]]) {
        return YES;
    }
    
    return NO;
}

- (MyLoadingIndicateView *)_loadingIndicateView
{
    
    MyLoadingIndicateView * indicateView = (MyLoadingIndicateView *)[self viewWithTag:IndicateViewViewTag];
    
    if (!indicateView || ![indicateView isMemberOfClass:[MyLoadingIndicateView class]]) {
        
        indicateView = [[MyLoadingIndicateView alloc] initWithFrame:self.bounds];
        indicateView.marginScale = CGSizeMake(0.15f, 0.15f);
        indicateView.tag = IndicateViewViewTag;
        indicateView.delegate = self;
//        indicateView.activityIndicatorView.twoStepAnimation = NO;
        
        [self addSubview:indicateView];
        
        [self setNeedsLayout];
    }
 
    return indicateView;
}

- (void)loadingIndicateViewDidTap:(MyLoadingIndicateView *)loadingIndicateView
{
    self.userInteractionEnabled = NO;
    [loadingIndicateView hiddenView];
    
    [self _startDownloadImage];
}

//super
//----------------------------------------------------------

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self _hasLoadingIndicateView]) {
        
        MyLoadingIndicateView * indicateView = self._loadingIndicateView;
        
        CGRect bounds = self.bounds;
        
        indicateView.frame = bounds;
    
        CGFloat sizeStandards = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds));
        
        if (sizeStandards >= 150.f) {
            
            indicateView.activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 40.f, 40.f);
            indicateView.activityIndicatorView.lineWidth = 1.5f;
            indicateView.topMargin = 10.f;
            indicateView.titleLabelFont = [UIFont boldSystemFontOfSize:16.f];
            
        }else if(sizeStandards >= 50.f){
            
            indicateView.activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 30.f, 30.f);
            indicateView.activityIndicatorView.lineWidth = 1.f;
            indicateView.topMargin = 5.f;
            indicateView.titleLabelFont = [UIFont boldSystemFontOfSize:8.f];
            
        }else{
            
            indicateView.activityIndicatorView.bounds = CGRectMake(0.f, 0.f, 20.f, 20.f);
            indicateView.activityIndicatorView.lineWidth = 1.f;
            indicateView.topMargin = 2.f;
            indicateView.titleLabelFont = [UIFont boldSystemFontOfSize:5.f];
        }
    }
}


//super
//----------------------------------------------------------


- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
                    imageURL:(NSString *)url
        didReceiveDataLength:(long long)receiveDataLength
          expectedDataLength:(long long)expectedDataLength
            receiveDataSpeed:(NSUInteger)speed
{
    if (self.imageLoadConfiguration.progressViewMode != ImageLoadProgressViewModeNone) {
        MyActivityIndicatorView  * progressView = self._loadingIndicateView.activityIndicatorView;
        
        if (progressView && progressView.style == MyActivityIndicatorViewStyleDeterminate) {
            
            if (expectedDataLength != NSURLResponseUnknownLength) {
                //设置进度
                [progressView setProgress:(float)receiveDataLength/expectedDataLength];
            }else{
                [progressView setStyle:MyActivityIndicatorViewStyleIndeterminate];
                [progressView startAnimating];
            }
        }
    }
}

- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
        downloadFailedForURL:(NSString *)url
                       error:(NSError *)error
{
    
    ImageLoadConfiguration * configuration = self.imageLoadConfiguration;
    NSString * imageURL = configuration.url;
    
    //URL不一样则忽略
    if ((manager == [self imageDownLoadManager]) &&
        ([imageURL isEqualToString:url] || (!url && ! imageURL))) {
        
        if(error.code == ImageDownLoadNoNetReachableErrorCode && (configuration.loadFailPolicy & ImageLoadFailPolicyAutoReloadWhenNoNet)){
            
            self.image = nil;
            
            if (configuration.loadFailPolicy & ImageLoadFailPolicyShowNoNetIndicate) {
                
                [self._loadingIndicateView
                    showNoNetworkStatusWithImage:ImageWithName(@"error_no_network.png")
                                           title:@"检查网络设置"
                                      detailText:nil
                           observerNetworkChange:YES];

                
            }else{
                
                [self._loadingIndicateView showNoNetworkStatusWithImage:nil
                                                                  title:nil
                                                             detailText:nil
                                                  observerNetworkChange:YES];

            }
            
            
        }else{
        
            FailureBlock failure = configuration.failureBlock;
            
            if (failure) {
                failure(self,error);
            }
            
            [self _failDownLoadImage];
        }
    }
}

- (void)imageDownLoadManager:(MyImageDownLoadManager *)manager
       downloadSucceedForURL:(NSString *)url
                       image:(UIImage *)image
{
    
    //URL不一样则忽略
    if ((manager == [self imageDownLoadManager]) &&
        [[self imageLoadConfiguration].url isEqualToString:url]) {
        
        self.image = image;
        
        SuccessBlock success = [self imageLoadConfiguration].successBlock;
        
        if (success) {
            success(self,image);
        }
        
       [self setImageLoadConfiguration:nil];
    }
}



@end
