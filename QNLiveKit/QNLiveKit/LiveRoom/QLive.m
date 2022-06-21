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
#import "QNLiveNetworkUtil.h"
#import "QNLivePushClient.h"
#import "QNLivePullClient.h"
#import "QRooms.h"

@interface QLive ()

@end

@implementation QLive

+ (void)initWithToken:(NSString *)token {
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:Live_Token];
    [defaults synchronize];
}

+ (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(nullable NSDictionary *)extension{
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"nick"] = nick;
    params[@"avatar"] = avatar;
    params[@"extends"] = extension;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:nick forKey:QN_NICKNAME_KEY];
    [defaults setObject:avatar forKey:QN_USER_AVATAR_KEY];
    
    [defaults synchronize];
    
    [QNLiveNetworkUtil putRequestWithAction:@"client/user/user" params:params success:^(NSDictionary * _Nonnull responseData) {
        
        [QLive getSelfUser:^(QNLiveUser *user) {
            
            [[QNIMClient sharedClient] signInByName:user.im_username password:user.im_password completion:^(QNIMError * _Nonnull error) {
                NSLog(@"---七牛IM服务器连接状态-%li",[QNIMClient sharedClient].connectStatus);
            }];
        }];
        
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
+ (void)getSelfUser:(void (^)(QNLiveUser * _Nonnull))callBack {
    
    [QNLiveNetworkUtil getRequestWithAction:@"client/user/profile" params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        QNLiveUser *user = [QNLiveUser mj_objectWithKeyValues:responseData];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:user.im_userid forKey:QN_IM_USER_ID_KEY];
        [defaults setObject:user.im_username forKey:QN_IM_USER_NAME_KEY];
        [defaults setObject:user.im_password forKey:QN_IM_USER_PASSWORD_KEY];
        [defaults synchronize];
        
        callBack(user);
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}



@end
