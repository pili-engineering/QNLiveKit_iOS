//
//  LicenseUtil.m
//  SenseMeEffects
//
//  Created by Sunshine on 2019/1/14.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import "LicenseUtil.h"

//st_mobile
#import "st_mobile_common.h"
#import "st_mobile_license.h"

#import <CommonCrypto/CommonDigest.h>

#import <AFNetworking/AFNetworking.h>
#import <MJExtension/MJExtension.h>
#import "QNLicenseModel.h"

@interface LicenseUtil ()
@property (nonatomic, assign) BOOL bChecked;
@property (nonatomic, assign) int  msgCheck;

@property (nonatomic,strong)AFHTTPSessionManager *manager;

@end

@implementation LicenseUtil

static dispatch_once_t onceToken;
static LicenseUtil *utils = nil;

+ (instancetype)sharedInstance
{
    dispatch_once(&onceToken, ^{
        
        utils = [[self alloc] initBySuper];
    });
    
    return utils;
}

- (instancetype)initBySuper
{
    self = [super init];
    
    if (self) {
        
        self.bChecked = NO;
        self.msgCheck = ST_OK;
        [self initAFHTTPSessionManager];
    }
    
    return self;
}

-(void)initAFHTTPSessionManager{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:
                                                              @"application/xml",
                                                              @"text/xml",
                                                              @"text/html",
                                                              @"application/json",
                                                              @"text/plain",
                                                              @"image/jpeg",
                                                              @"image/png",
                                                              @"text/javascript",
                                                              @"application/octet-stream",
                                                              @"text/json",
                                                              @"multipart/form-data",
                                                              @"charset=utf-8",
                                                              @"application/xml",nil];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.manager = manager;
}


-(void)checkLicense:(void (^)(BOOL status))callback{
    [_manager GET:@"https://niucube-api.qiniu.com/v1/license/sensetime/ios" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError* error;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData *mLicense = [userDefaults objectForKey:@"senseLicense"];
        
        QNLicenseModel *oldModle =  nil;
        if (mLicense) {
            id json = [NSJSONSerialization JSONObjectWithData:mLicense options:0 error:&error];
            oldModle = [QNLicenseModel mj_objectWithKeyValues:json];
        }
        
        QNLicenseModel *newModle = [QNLicenseModel mj_objectWithKeyValues:(NSDictionary *)responseObject[@"data"]];
        
        if (![oldModle isEqualModle:newModle] || !oldModle){
            if (!newModle && callback){
                callback(NO);
                return;;
            }
            /* 下载地址 */
            NSURL *url = [NSURL URLWithString:newModle.url];
        
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/lic"];
            NSString *filePath = [path stringByAppendingPathComponent:url.lastPathComponent];
            newModle.localPath = url.lastPathComponent;
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            BOOL isDir = NO;
            // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
            BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
            if ( !(isDir == YES && existed == YES) ) {
                // 在 Document 目录下创建一个 head 目录
                [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            [self downLoadLic:[NSURL URLWithString:newModle.url] savePath:filePath callback:^(BOOL status) {
                NSData *mData = newModle.mj_JSONData;
                [userDefaults setValue:mData forKey:@"senseLicense"];
                if(callback){
                    callback(status);
                }
            }];
            

        }else{
            NSError *error = nil;
            
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/lic"];
            NSString *filePath = [path stringByAppendingPathComponent:oldModle.localPath];
            
            NSData *licData = [NSData dataWithContentsOfFile:filePath options:nil error:&error];
            [self checkActiveCodeWithData:licData];
            if (callback) {
                callback(YES);
            }
            
        }
                
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (callback){
            callback(NO);
        }
    }];
}


- (void)downLoadLic:(NSURL *)url savePath:(NSString *)localPath callback:(void (^)(BOOL status))callback{
//    NSString * urlStr = [NSString stringWithFormat:@"http://files.lqfast.com:8030/xxxxx"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:localPath];
                
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
         NSLog(@"下载完成");
        NSData *licData = [NSData dataWithContentsOfFile:localPath];
        [self checkActiveCodeWithData:licData];
        if(callback && !error && licData){
            callback(YES);
        }
    }];
     [downloadTask resume];
}



#pragma mark - check license
- (BOOL)checkActiveCodeWithData:(NSData *)dataLicense{
    NSString *strKeyActiveCode = @"ACTIVE_CODE_ONLINE";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strActiveCode = [userDefaults objectForKey:strKeyActiveCode];
    st_result_t iRet = ST_E_FAIL;
    
    if (strActiveCode.length) {
        iRet = st_mobile_check_activecode_from_buffer(
                                                      [dataLicense bytes],
                                                      (int)[dataLicense length],
                                                      strActiveCode.UTF8String,
                                                      (int)[strActiveCode length]
                                                      );
        
        if (ST_OK == iRet) {
            return YES;
        }
    }
    char active_code[10240];
    int active_code_len = 10240;
    
#if USE_SDK_ONLINE_ACTIVATION
    iRet = st_mobile_generate_activecode_online([[NSBundle mainBundle] pathForResource:@"SENSEMEONLINE" ofType:@"lic"].UTF8String, active_code, &active_code_len);
#else
    iRet = st_mobile_generate_activecode_from_buffer(
                                                     [dataLicense bytes],
                                                     (int)[dataLicense length],
                                                     active_code,
                                                     &active_code_len
                                                     );
    
#endif
    
    strActiveCode = [[NSString alloc] initWithUTF8String:active_code];
    
    
    if (iRet == ST_OK && strActiveCode.length) {
        
        [userDefaults setObject:strActiveCode forKey:strKeyActiveCode];
        [userDefaults synchronize];
        
        return YES;
    }
    
    return NO;
}



- (NSString *)getSHA1StringWithData:(NSData *)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *strSHA1 = [NSMutableString string];
    
    for (int i = 0 ; i < CC_SHA1_DIGEST_LENGTH ; i ++) {
        
        [strSHA1 appendFormat:@"%02x" , digest[i]];
    }
    
    return strSHA1;
}

- (BOOL)checkActiveCodeNative {
    
    NSString *strLicensePath = [[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"];
    NSData *dataLicense = [NSData dataWithContentsOfFile:strLicensePath];
    
    NSString *strKeySHA1 = @"SENSEME";
    NSString *strKeyActiveCode = @"ACTIVE_CODE";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *strStoredSHA1 = [userDefaults objectForKey:strKeySHA1];
    NSString *strLicenseSHA1 = [self getSHA1StringWithData:dataLicense];
    
    return [self checkAndGenerateActiveCodeWithStoreStr:strStoredSHA1
                                            storeStrKey:strKeySHA1
                                          activeCodeStr:strLicenseSHA1
                                       activeCodeStrKey:strKeyActiveCode
                                            licensePath:strLicensePath
                                                bOnline:NO];
}

- (BOOL)checkActiveCodeOnline
{
    NSString *strLicensePath = [[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"];
    NSData *dataLicense = [NSData dataWithContentsOfFile:strLicensePath];
    
    NSString *strKeySHA1 = @"SENSEME";
    NSString *strKeyActiveCode = @"ACTIVE_CODE";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *strStoredSHA1 = [userDefaults objectForKey:strKeySHA1];
    NSString *strLicenseSHA1 = [self getSHA1StringWithData:dataLicense];
    
    return [self checkAndGenerateActiveCodeWithStoreStr:strStoredSHA1
                                            storeStrKey:strKeySHA1
                                          activeCodeStr:strLicenseSHA1
                                       activeCodeStrKey:strKeyActiveCode
                                            licensePath:strLicensePath
                                                bOnline:YES];
    
    
}

- (BOOL)checkAndGenerateActiveCodeWithStoreStr:(NSString *)strStore
                                   storeStrKey:(NSString *)storeKey
                                 activeCodeStr:(NSString *)strLicense
                              activeCodeStrKey:(NSString *)activeCodeKey
                                   licensePath:(NSString *)path
                                       bOnline:(BOOL)online
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    st_result_t iRet = ST_OK;
    
    if (strStore.length > 0 && [strLicense isEqualToString:strStore]) {
        
        // Get current active code
        // In this app active code was stored in NSUserDefaults
        // It also can be stored in other places
        NSData *activeCodeData = [userDefaults objectForKey:activeCodeKey];
        
        // Check if current active code is available
        // use file
        iRet = st_mobile_check_activecode(
                                          path.UTF8String,
                                          (const char *)[activeCodeData bytes],
                                          (int)[activeCodeData length]
                                          );
        
        _bChecked = iRet == ST_OK;
        _msgCheck = iRet;
        
        if (ST_OK == iRet) {
            
            // check success
            return YES;
        }
    }
    
    /*
     1. check fail
     2. new one
     3. update
     */
    
    char active_code[1024];
    int active_code_len = 1024;
    
    // generate one
    // use file
    
    if (online) {
        iRet = st_mobile_generate_activecode_online(path.UTF8String,
                                                    active_code,
                                                    &active_code_len);
    }else{
        iRet = st_mobile_generate_activecode(path.UTF8String,
                                             active_code,
                                             &active_code_len);
    }
    
    _bChecked = iRet == ST_OK;
    _msgCheck = iRet;
    
    if (ST_OK != iRet) {
        
        return NO;
        
    } else {
        
        // Store active code
        NSData *activeCodeData = [NSData dataWithBytes:active_code length:active_code_len];
        
        [userDefaults setObject:activeCodeData forKey:activeCodeKey];
        [userDefaults setObject:strLicense forKey:storeKey];
        
        [userDefaults synchronize];
    }
    
    return YES;
}

- (void)checkActiveCodeNativeOnSuccess:(void (^)(void))checkSuccess
                             onFailure:(void (^)(int checkResult))checkFailure
{
    if ([self checkActiveCodeNative]) {
        checkSuccess();
    }else{
        checkFailure(_msgCheck);
    }
}

- (void)checkActiveCodeOnlineOnSuccess:(void (^)(void))checkSuccess
                             onFailure:(void (^)(int checkResult))checkFailure
{
    
    if ([self checkActiveCodeOnline]) {
        checkSuccess();
    }else{
        checkFailure(_msgCheck);
    }
}

+ (BOOL)isCheckedActiveCode
{
    return (utils != nil) && utils.bChecked;
}

@end
