//
//  MyFromDataHTTPRequest.m
//  Bestone
//
//  Created by Xuzhanya on 14-6-13.
//  Copyright (c) 2014年 Xuzhanya. All rights reserved.
//

//----------------------------------------------------------

#import "MyFromDataHTTPRequest.h"
#import "help.h"

//----------------------------------------------------------

@interface _MyUploadData : NSObject

- (id)initWithData:(NSData *)data
          fileName:(NSString *)fileName
       contentType:(NSString *)contentType;


@property(nonatomic,strong,readonly) NSData *   data;

@property(nonatomic,strong,readonly) NSString * fileName;

@property(nonatomic,strong,readonly) NSString * contentType;

@end

//----------------------------------------------------------

@implementation _MyUploadData

- (id)initWithData:(NSData *)data
          fileName:(NSString *)fileName
       contentType:(NSString *)contentType
{
    self = [super init];
    
    if (self) {
        _data = data;
        _fileName = fileName;
        _contentType = contentType;
    }
    
    return self;
}

@end

//----------------------------------------------------------

@interface MyFromDataHTTPRequest ()

@property(nonatomic,strong,readonly) NSMutableDictionary * uploadDataDic;

@property(nonatomic,strong,readonly) NSString * boundary;

- (NSData *)_bodyDataWithUploadDataDic:(NSDictionary *)uploadDataDic;

@end

//----------------------------------------------------------


@implementation MyFromDataHTTPRequest

@synthesize boundary = _boundary;
@synthesize uploadDataDic = _uploadDataDic;

- (id)initWithURL:(NSString *)url
       uploadData:(NSData *)data
         fileName:(NSString *)fileName
      contentType:(NSString *)contentType
           forKey:(NSString *)key
{
    return [self initWithURL:url
                        path:nil
              queryArguments:nil
                  uploadData:data
                    fileName:fileName
                 contentType:contentType
                      forKey:key];
}


- (id)initWithURL:(NSString *)url
             path:(NSString *)path
   queryArguments:(NSDictionary *)queryArguments
       uploadData:(NSData *)data
         fileName:(NSString *)fileName
      contentType:(NSString *)contentType
           forKey:(NSString *)key
{
    self = [super initWithURL:url
                         path:path
               queryArguments:queryArguments];
    
    if (self) {
        //设置请求的方法
        [super setRequestType:HTTPRequestTypePost];
        
        //设置请求头
        NSDictionary * headerArguments = [NSDictionary dictionaryWithObject:
                                          [NSString stringWithFormat:@"multipart/form-data; boundary=%@",self.boundary]
                                                                     forKey:@"Content-Type"];
        
        [super setHeaderArguments:headerArguments];
        
        //添加数据
        [self addData:data fileName:fileName contentType:contentType forKey:key];
        
    }
    
    
    return self;
}

- (NSString *)boundary
{
    if (!_boundary) {
        _boundary = getUniqueID();
    }
    
    return  @"_boundary";
}

- (NSMutableDictionary *)uploadDataDic
{
    if (!_uploadDataDic) {
        _uploadDataDic = [NSMutableDictionary dictionary];
    }
    return _uploadDataDic;
}

- (void)addData:(NSData *)data
       fileName:(NSString *)fileName
    contentType:(NSString *)contentType
         forKey:(NSString *)key
{
    if (key == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"key不能为nil"
                                     userInfo:nil];
    }
    
    
    _MyUploadData * uploadData = [[_MyUploadData alloc] initWithData:data fileName:fileName contentType:contentType];
    
    [self.uploadDataDic setObject:uploadData forKey:key];
}

- (void)startRequest
{
    //设置bodyData
    [super setBodyData:[self _bodyDataWithUploadDataDic:self.uploadDataDic]];
    
    [super startRequest];
    
}

- (NSData *)_bodyDataWithUploadDataDic:(NSDictionary *)uploadDataDic
{
    NSMutableData * bodyData = [NSMutableData data];
    
    for (NSString * key in uploadDataDic.allKeys) {
        
        //上传数据
        _MyUploadData * uploadData = [uploadDataDic objectForKey:key];
        
        //添加边界
        NSString * tmpStr = [NSString stringWithFormat:@"--%@\r\n",self.boundary];
        [bodyData appendData:DataWithUTF8Code(tmpStr)];
        
        //设置参数key和名称
        tmpStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"",key];
        
        tmpStr = [tmpStr stringByAppendingString:(uploadData.fileName) ? [NSString stringWithFormat:@"; filename=\"%@\"\r\n",uploadData.fileName] : @"\r\n"];
        
        [bodyData appendData:DataWithUTF8Code(tmpStr)];
        
        //类型
        if (uploadData.contentType) {
            tmpStr = [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",uploadData.contentType];
            [bodyData appendData:DataWithUTF8Code(tmpStr)];
        }else{
            [bodyData appendData:DataWithUTF8Code(@"\r\n")];
        }
        
        //数据
        [bodyData appendData:uploadData.data];
        [bodyData appendData:DataWithUTF8Code(@"\r\n")];
    }
    
    //结束符
    if (bodyData.length) {
        NSString * endStr = [NSString stringWithFormat:@"--%@--",self.boundary];
        [bodyData appendData:DataWithUTF8Code(endStr)];
    }
    
    
    return bodyData;
}

- (void)setRequestType:(HTTPRequestType)type
{
    //do nothing
//    [super setRequestType:HTTPRequestTypePost];
}

- (void)setHeaderArguments:(NSDictionary *)headerArguments
{
    //do nothing
}

- (void)setBodyData:(NSData *)bodyData
{
    // do nothing
}

- (void)setBodyDataWithBodyArguments:(NSDictionary *)bodyArguments
{
    // do noting
}


@end

//----------------------------------------------------------


@implementation MyFromDataHTTPRequest(image)

- (id)initWithURL:(NSString *)url
      uploadImage:(UIImage *)image
        imageName:(NSString *)imageName
           forKey:(NSString *)key
{
    return [self initWithURL:url
                        path:nil
              queryArguments:nil
                 uploadImage:image
                     quality:1.f
                   imageName:imageName
                      forKey:key];
}

- (id)initWithURL:(NSString *)url
             path:(NSString *)path
   queryArguments:(NSDictionary *)queryArguments
      uploadImage:(UIImage *)image
          quality:(CGFloat)compressionQuality
        imageName:(NSString *)imageName
           forKey:(NSString *)key
{
    return [self initWithURL:url
                        path:path
              queryArguments:queryArguments
                  uploadData:UIImageJPEGRepresentation(image, compressionQuality)   //进行jpeg编码
                    fileName:[[imageName stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpeg"]
                 contentType:@"image/jpeg"
                      forKey:key];
}

- (void)addImage:(UIImage *)image
         quality:(CGFloat)compressionQuality
       imageName:(NSString *)imageName
          forKey:(NSString *)key
{
    [self addData:UIImageJPEGRepresentation(image, compressionQuality)
         fileName:[[imageName stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpeg"]
      contentType:@"image/jpeg"
           forKey:key];
}


@end
