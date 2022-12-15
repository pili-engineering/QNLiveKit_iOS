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


+ (void)initWithToken:(NSString *)token serverURL:(nonnull NSString *)serverURL errorBack:(nullable void (^)(NSError * _Nullable))errorBack{
    if (token.length == 0) {
        NSError *error = [QNErrorUtil errorWithCode:QNLiveErrorInvalidToken message:@"empty token"];
        errorBack(error);
        return;
    }
    
    QLiveConfig *config = [[QLiveConfig alloc] init];
    config.serverURL = serverURL;
    
    [QLive initWithConfig:config complete:^{
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



+ (void)initWithConfig:(QLiveConfig *)config complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    [QLive saveDefaultsConfig:config];
    
    [QNAppService getAppInfoWithComplete:^(QNAppInfo * _Nonnull appInfo) {
        [QLive initApp:appInfo complete:complete failure:failure];
    } failure:^(NSError * _Nullable error) {
        NSLog(@"get appInfo error %@", error);
        error = [QNErrorUtil errorWithCode:QNLiveErrorFetchAppInfo message:@"get appInfo error" underlying:error];
        failure(error);
    }];
}


/// 必要信息存入 defaults
/// @param config  配置信息
+ (void)saveDefaultsConfig:(QLiveConfig *)config {
    NSString *appendUrl = [config.serverURL stringByAppendingString:@"/%@"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:appendUrl forKey:Live_URL];
    [userDefaults synchronize];
}


/// 根据应用信息，执行全局初始化
/// @param appInfo 应用信息
/// @param complete 成功回调
/// @param failure 失败回调
+ (void)initApp:(QNAppInfo *)appInfo complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    [QLive initImWithAppID:appInfo.IMAppID];
    
    complete();
}

+ (void)initImWithAppID:(NSString *)imAppId {
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


+ (void)setBeauty:(BOOL)needBeauty {
    QNLivePushClient *pushClient = [QNLivePushClient createPushClient];
    pushClient.needBeauty = needBeauty;
}


+ (void)authWithToken:(NSString *)token complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    if (token.length == 0) {
        NSLog(@"empty token");
        NSError *error = [QNErrorUtil errorWithCode:QNLiveErrorInvalidToken message:@"empty token"];
        failure(error);
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:Live_Token];
    [defaults synchronize];
    
    [[QNUserService sharedInstance] fetchLoginUserComplete:^(QNLiveUser * _Nonnull user) {
        [[QNIMClient sharedClient] signInByName:user.im_username password:user.im_password completion:^(QNIMError * error) {
            NSLog(@"---七牛IM服务器连接状态-%li",[QNIMClient sharedClient].connectStatus);
            if (error) {
                NSError *loginError = [QNErrorUtil errorWithCode:QNLiveErrorLoginImFail message:@"login im failed" underlying:error];
                failure(loginError);
            }
        }];
    } failure:^(NSError * _Nullable error) {
        failure(error);
    }];
}

+ (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(nullable NSDictionary *)extension {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"nick"] = nick;
    params[@"avatar"] = avatar;
    params[@"extends"] = extension;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:nick forKey:LIVE_NICKNAME_KEY];
    [defaults setObject:avatar forKey:LIVE_USER_AVATAR_KEY];
    
    [defaults synchronize];
    
    [QLiveNetworkUtil putRequestWithAction:@"client/user/user" params:params success:^(NSDictionary * _Nonnull responseData) {
                      
        } failure:^(NSError * _Nonnull error) {

        }];
}

//创建主播端
+ (QNLivePushClient *)createPusherClient {
    
    QNLivePushClient *pushClient = [QNLivePushClient createPushClient];    
    return pushClient;
}
//创建观众端
+ (QNLivePullClient *)createPlayerClient {
    QNLivePullClient *pullClient = [[QNLivePullClient alloc]init];
    return pullClient;
    
}
//获得直播场景
+ (QRooms *)getRooms {
    static QRooms *rooms;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        rooms = [[QRooms alloc]init];
    });
    return rooms;
}

//获取自己的信息
//+ (void)getSelfUser:(void (^)(QNLiveUser * _Nullable, NSError * _Nullable))callBack {
//    
//    [QLiveNetworkUtil getRequestWithAction:@"client/user/profile" params:nil success:^(NSDictionary * _Nonnull responseData) {
//        
//        QNLiveUser *user = [QNLiveUser mj_objectWithKeyValues:responseData];
//        
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:user.user_id forKey:LIVE_ACCOUNT_ID_KEY];
//        [defaults setObject:user.im_userid forKey:LIVE_IM_USER_ID_KEY];
//        [defaults setObject:user.im_username forKey:LIVE_IM_USER_NAME_KEY];
//        [defaults setObject:user.im_password forKey:LIVE_IM_USER_PASSWORD_KEY];
//        [defaults setObject:user.nick forKey:LIVE_NICKNAME_KEY];
//        [defaults setObject:user.avatar forKey:LIVE_USER_AVATAR_KEY];
//        [defaults synchronize];
//        
//        callBack(user,nil);
//        
//        } failure:^(NSError * _Nonnull error) {
//            callBack(nil,error);
//        }];
//}



@end
