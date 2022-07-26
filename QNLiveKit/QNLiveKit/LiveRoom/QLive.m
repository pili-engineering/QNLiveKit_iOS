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
#import "QLiveNetworkUtil.h"
#import "QNLivePushClient.h"
#import "QNLivePullClient.h"
#import "QRooms.h"
#import <QNIMSDK/QNIMSDK.h>

@interface QLive ()

@end

@implementation QLive

+ (void)initWithToken:(NSString *)token serverURL:(nonnull NSString *)serverURL errorBack:(nullable void (^)(NSError * _Nullable))errorBack{
    if (token.length == 0) {
        return;
    }
    [QLive initializeQNIM];
    NSString *appendUrl = [serverURL stringByAppendingString:@"/%@"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:Live_Token];
    [defaults setObject:appendUrl forKey:Live_URL];
    [defaults synchronize];
    
    [QLive getSelfUser:^(QNLiveUser * _Nullable user, NSError * _Nullable QError) {
        
        if (user) {
            [[QNIMClient sharedClient] signInByName:user.im_username password:user.im_password completion:^(QNIMError * _Nonnull error) {
                NSLog(@"---七牛IM服务器连接状态-%li",[QNIMClient sharedClient].connectStatus);
                if (error) {
                    NSError *qnError = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:error.errorCode userInfo:@{NSLocalizedDescriptionKey : error.errorMessage}];
                    if (errorBack) {
                        errorBack(qnError);
                    }
                }
            }];
        } else {
            if (errorBack) {
                errorBack(QError);
            }
        }
    }];
}

+ (void)initializeQNIM{
    
    NSString* dataDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"ChatData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
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

    [QLiveNetworkUtil getRequestWithAction:@"client/app/config" params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        QNSDKConfig *config = [[QNSDKConfig alloc]initConfigWithDataDir:dataDir cacheDir:cacheDir pushCertName:@"" userAgent:phone];
        config.appID = responseData[@"im_app_id"];
        [[QNIMClient sharedClient] registerWithSDKConfig:config];
        
    } failure:^(NSError * _Nonnull error) {

    }];
    
}

+ (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(nullable NSDictionary *)extension {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"nick"] = nick;
    params[@"avatar"] = avatar;
    params[@"extends"] = extension;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:nick forKey:QN_NICKNAME_KEY];
    [defaults setObject:avatar forKey:QN_USER_AVATAR_KEY];
    
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
+ (void)getSelfUser:(void (^)(QNLiveUser * _Nullable, NSError * _Nullable))callBack {
    
    [QLiveNetworkUtil getRequestWithAction:@"client/user/profile" params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        QNLiveUser *user = [QNLiveUser mj_objectWithKeyValues:responseData];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:user.im_userid forKey:QN_IM_USER_ID_KEY];
        [defaults setObject:user.im_username forKey:QN_IM_USER_NAME_KEY];
        [defaults setObject:user.im_password forKey:QN_IM_USER_PASSWORD_KEY];
        [defaults synchronize];
        
        callBack(user,nil);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil,error);
        }];
}



@end
