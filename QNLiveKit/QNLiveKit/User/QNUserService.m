//
//  QNUserService.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import "QNUserService.h"
#import "QLiveNetworkUtil.h"

@interface QNUserService ()

@property (atomic, strong, readwrite) QNLiveUser *loginUser;

@property (nonatomic, strong) NSCache *cache;

@end

@implementation QNUserService

+(instancetype)sharedInstance {
    static QNUserService * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void)fetchLoginUserComplete:(void (^)(QNLiveUser * _Nonnull))complete failure:(QNFailureCallback)failure {
    [QLiveNetworkUtil getRequestWithAction:@"client/user/profile" params:nil success:^(NSDictionary * _Nonnull responseData) {
        QNLiveUser *user = [QNLiveUser mj_objectWithKeyValues:responseData];
        [self saveDefaultsUser:user];
        self.loginUser = user;
        complete(user);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"fetchLoginUser error %@", error);
        error = [QNErrorUtil errorWithCode:QNLiveErrorInvalidToken message:@"fetch login user error" underlying:error];
        failure(error);
    }];
}

- (void)saveDefaultsUser:(QNLiveUser *)user {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user.user_id forKey:LIVE_ACCOUNT_ID_KEY];
    [defaults setObject:user.im_userid forKey:LIVE_IM_USER_ID_KEY];
    [defaults setObject:user.im_username forKey:LIVE_IM_USER_NAME_KEY];
    [defaults setObject:user.im_password forKey:LIVE_IM_USER_PASSWORD_KEY];
    [defaults setObject:user.nick forKey:LIVE_NICKNAME_KEY];
    [defaults setObject:user.avatar forKey:LIVE_USER_AVATAR_KEY];
    [defaults synchronize];
}

- (void)getUserByID:(NSString *)userId complete:(void (^)(QNLiveUser *user))complete {
    QNLiveUser *user = [self.cache objectForKey:userId];
    if (user) {
        complete(user);
        return;
    }
    
    NSString *action = [NSString stringWithFormat:@"client/user/user/%@", userId];
    [QLiveNetworkUtil getRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        QNLiveUser *user = [QNLiveUser mj_objectWithKeyValues:responseData];
        [self.cache setObject:user forKey:userId];
        complete(user);
    } failure:^(NSError * _Nonnull error) {
        complete(nil);
    }];
}

- (NSCache *)cache {
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        _cache.countLimit = 200;
    }
    return _cache;
}


- (void)setUser:(QNLiveUser *)userInfo complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure {
    
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (userInfo.nick.length > 0) {
        params[@"nick"] = userInfo.nick;
    }
    
    if (userInfo.avatar.length > 0) {
        params[@"avatar"] = userInfo.avatar;
    }
    
    if (userInfo.extension.count > 0) {
        NSMutableDictionary *extDic = [NSMutableDictionary new];
        [userInfo.extension enumerateObjectsUsingBlock:^(Extension * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            extDic[obj.key] = extDic[obj.value];
        }];
        params[@"extends"] = [extDic copy];
    }
    
    
    
    
    [QLiveNetworkUtil putRequestWithAction:@"client/user/user" params:params success:^(NSDictionary * _Nonnull responseData) {
        [self updateLoginUserInfo:userInfo];
        
        complete();
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"update user info error %@", error);
        error = [QNErrorUtil errorWithCode:QNLiveErrorUpdateUserInfo message:@"update user info error" underlying:error];
        failure(error);
    }];
}

- (void)updateLoginUserInfo:(QNLiveUser *)userInfo {
    if (userInfo.nick.length > 0 || userInfo.avatar.length > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (userInfo.nick > 0) {
            [defaults setObject:userInfo.nick forKey:LIVE_NICKNAME_KEY];
        }
        
        if (userInfo.avatar.length > 0) {
            [defaults setObject:userInfo.avatar forKey:LIVE_USER_AVATAR_KEY];
        }
        [defaults synchronize];
    }
    
    if (userInfo.nick.length > 0) {
        self.loginUser.nick = userInfo.nick;
    }
    
    if (userInfo.avatar.length > 0) {
        self.loginUser.avatar = userInfo.avatar;
    }
    
    if (userInfo.extension.count > 0) {
        self.loginUser.extension = userInfo.extension;
    }
}
@end
