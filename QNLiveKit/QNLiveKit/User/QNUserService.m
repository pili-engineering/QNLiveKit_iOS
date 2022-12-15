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
@end
