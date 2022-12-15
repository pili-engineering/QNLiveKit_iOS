//
//  QLive.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QLive.h"
#import "QNCreateRoomParam.h"
#import "QNLiveRoomInfo.h"
#import "QNLiveUser.h"
#import "QNLivePushClient.h"
#import "QNLivePullClient.h"
#import "QRooms.h"
#import <QNIMSDK/QNIMSDK.h>
#import "QNAppService.h"

@interface QLive ()


@end

@implementation QLive

+ (instancetype)sharedInstance {
    static QLive * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)initWithToken:(NSString *)token serverURL:(nonnull NSString *)serverURL errorBack:(nullable void (^)(NSError * _Nullable))errorBack {
    [[QLive sharedInstance] initWithToken:token serverURL:serverURL errorBack:errorBack];
}

+ (void)initWithConfig:(QLiveConfig *)config tokenGetter:(id<QLiveTokenGetter>)tokenGetter complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    [[QLive sharedInstance] initWithConfig:config tokenGetter:tokenGetter complete:complete failure:failure];
}

+ (void)authWithToken:(NSString *)token complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    [[QLive sharedInstance] authWithToken:token complete:complete failure:failure];
}

+ (void)setBeauty:(BOOL)needBeauty {
    [[QLive sharedInstance] setBeauty:needBeauty];
}

+ (QNLiveUser *)getLoginUser {
    return [QNUserService sharedInstance].loginUser;
}

+ (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(nullable NSDictionary *)extension {
    [[QLive sharedInstance] setUser:avatar nick:nick extension:extension];
}

+ (void)setUser:(QNLiveUser *)userInfo complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    [[QLive sharedInstance] setUser:userInfo complete:complete failure:failure];
}


/// 创建主播端
+ (QNLivePushClient *)createPusherClient {
    return [[QLive sharedInstance] createPusherClient];
}

/// 创建观众端
+ (QNLivePullClient *)createPlayerClient {
    return [[QLive sharedInstance] createPlayerClient];
}

//获得直播场景
+ (QRooms *)getRooms {
    return [[QLive sharedInstance] getRooms];
}


- (void)initWithToken:(NSString *)token serverURL:(nonnull NSString *)serverURL errorBack:(nullable void (^)(NSError * _Nullable))errorBack{
    if (token.length == 0) {
        NSError *error = [QNErrorUtil errorWithCode:QNLiveErrorInvalidToken message:@"empty token"];
        errorBack(error);
        return;
    }
    
    QLiveConfig *config = [[QLiveConfig alloc] init];
    config.serverURL = serverURL;
    
    [QLive initWithConfig:config tokenGetter:nil complete:^{
        [QLive authWithToken:token complete:^{
            
        } failure:^(NSError * _Nullable error) {
            if (errorBack) {
                errorBack(error);
            }
        }];
    } failure:^(NSError * _Nullable error) {
        errorBack(error);
    }];
}



- (void)initWithConfig:(QLiveConfig *)config tokenGetter:(id<QLiveTokenGetter> _Nullable)tokenGetter complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    self.tokenGetter = tokenGetter;
    
    [self saveDefaultsConfig:config];
    
    [QNAppService getAppInfoWithComplete:^(QNAppInfo * _Nonnull appInfo) {
        [self initApp:appInfo complete:complete failure:failure];
    } failure:^(NSError * _Nullable error) {
        NSLog(@"get appInfo error %@", error);
        error = [QNErrorUtil errorWithCode:QNLiveErrorFetchAppInfo message:@"get appInfo error" underlying:error];
        failure(error);
    }];
}


/// 必要信息存入 defaults
/// @param config  配置信息
- (void)saveDefaultsConfig:(QLiveConfig *)config {
    NSString *appendUrl = [config.serverURL stringByAppendingString:@"/%@"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:appendUrl forKey:Live_URL];
    [userDefaults synchronize];
}


/// 根据应用信息，执行全局初始化
/// @param appInfo 应用信息
/// @param complete 成功回调
/// @param failure 失败回调
- (void)initApp:(QNAppInfo *)appInfo complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    [self initImWithAppID:appInfo.IMAppID];
    
    complete();
}

- (void)initImWithAppID:(NSString *)imAppId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* dataDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"ChatData"];
    if (![fileManager fileExistsAtPath:dataDir]) {
        [fileManager createDirectoryAtPath:dataDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"UserCache"];
    if (![fileManager fileExistsAtPath:cacheDir]) {
        [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"dataDir = %@", dataDir);
    NSLog(@"cacheDir = %@", cacheDir);

    NSString* phoneName = [[UIDevice currentDevice] name];
    NSString* localizedModel = [[UIDevice currentDevice] localizedModel];
    NSString* systemName = [[UIDevice currentDevice] systemName];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSString *phone = [NSString stringWithFormat:@"设备名称:%@;%@;%@;%@", phoneName,localizedModel,systemName,phoneVersion];
    
    QNSDKConfig *config = [[QNSDKConfig alloc]initConfigWithDataDir:dataDir cacheDir:cacheDir pushCertName:@"" userAgent:phone];
    config.appID = imAppId;
    [[QNIMClient sharedClient] registerWithSDKConfig:config];
}


- (void)setBeauty:(BOOL)needBeauty {
    QNLivePushClient *pushClient = [QNLivePushClient createPushClient];
    pushClient.needBeauty = needBeauty;
}


- (void)authWithToken:(NSString *)token complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    if (token.length == 0) {
        NSLog(@"empty token");
        NSError *error = [QNErrorUtil errorWithCode:QNLiveErrorInvalidToken message:@"empty token"];
        failure(error);
        return;
    }
    
    [self saveDefaultsToken:token];
    
    [[QNUserService sharedInstance] fetchLoginUserComplete:^(QNLiveUser * _Nonnull user) {
        [[QNIMClient sharedClient] signInByName:user.im_username password:user.im_password completion:^(QNIMError * error) {
            NSLog(@"---七牛IM服务器连接状态-%li",[QNIMClient sharedClient].connectStatus);
            if (error && error.errorCode != 0) {
                NSError *loginError = [QNErrorUtil errorWithCode:QNLiveErrorLoginImFail message:@"login im failed" underlying:error];
                failure(loginError);
            }
        }];
    } failure:^(NSError * _Nullable error) {
        failure(error);
    }];
}

- (void)saveDefaultsToken:(NSString *)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:Live_Token];
    [defaults synchronize];
}

- (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(nullable NSDictionary *)extension {
    QNLiveUser *user = [[QNLiveUser alloc] init];
    user.nick = nick;
    user.avatar = avatar;
    if (extension) {
        NSMutableArray<Extension *> *extList = [[NSMutableArray alloc] init];
        [extension enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if (key && obj) {
                Extension *ext = [[Extension alloc] init];
                ext.key = key;
                ext.value = obj;
                [extList addObject:ext];
            }
        }];
        
        user.extension = [extList copy];
    }
    
    [[QNUserService sharedInstance] setUser:user complete:^{
        NSLog(@"set user info success");
    } failure:^(NSError * _Nullable error) {
        NSLog(@"set user info error %@", error);
    }];
}

- (void)setUser:(QNLiveUser *)userInfo complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    [[QNUserService sharedInstance] setUser:userInfo complete:complete failure:failure];
}

//创建主播端
- (QNLivePushClient *)createPusherClient {
    
    QNLivePushClient *pushClient = [QNLivePushClient createPushClient];    
    return pushClient;
}

//创建观众端
- (QNLivePullClient *)createPlayerClient {
    QNLivePullClient *pullClient = [[QNLivePullClient alloc]init];
    return pullClient;
    
}

//获得直播场景
- (QRooms *)getRooms {
    static QRooms *rooms;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        rooms = [[QRooms alloc]init];
    });
    return rooms;
}

- (void)refreshToken {
    if (self.tokenGetter) {
        [self.tokenGetter getTokenInfoWithComplete:^(NSString * _Nonnull token) {
            [self saveDefaultsToken:token];
        } failure:^(NSError * _Nullable error) {
            
        }];
    }
}
@end
