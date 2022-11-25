//
//  QNLikeService.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/24.
//

#import "QNLikeService.h"
#import "QLiveNetworkUtil.h"
#import "QNLikeResult.h"

@interface QNLikeService ()

@end

@implementation QNLikeService

+ (instancetype)sharedInstance {
    static QNLikeService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)giveLike:(NSString *)liveId
           count:(NSInteger)count
        complete:(GiveLikeCompleteBlock)complete
         failure:(void (^)(NSError *error))failure {
    NSString *action = [NSString stringWithFormat:@"client/live/room/%@/like", liveId];
    NSDictionary *params = @{
        @"count":@(count),
    };
    [QLiveNetworkUtil putRequestWithAction:action params:params success:^(NSDictionary * _Nonnull responseData) {
        QNLikeResult *result = [QNLikeResult mj_objectWithKeyValues:responseData];
        complete(result.count, result.total);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

@end
