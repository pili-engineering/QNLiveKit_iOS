//
//  QNUserService.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import "QNUserService.h"
#import "QLiveNetworkUtil.h"

@interface QNUserService ()

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
