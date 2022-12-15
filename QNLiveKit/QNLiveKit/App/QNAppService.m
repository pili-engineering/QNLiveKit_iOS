//
//  QNAppService.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/12/14.
//

#import "QNAppService.h"
#import "QLiveNetworkUtil.h"

@implementation QNAppInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"IMAppID" : @"im_app_id",
    };
}

@end

@implementation QNAppService

+ (void)getAppInfoWithComplete:(QNGetAppInfoComplete)complete failure:(QNFailureCallback)failure {
    [QLiveNetworkUtil getRequestWithAction:@"client/app/config" params:nil success:^(NSDictionary * _Nonnull responseData) {
        QNAppInfo *appInfo = [QNAppInfo mj_objectWithKeyValues:responseData];
        complete(appInfo);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

@end
