//
//  QNPKRespModel.m
//  QNLiveKit
//
//  Created by xiaodao on 2023/6/16.
//

#import "QNPKRespModel.h"

@implementation QNPKRespModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"sessionId" : @"relay_id",
        @"status" : @"relay_status",
        @"pkToken": @"relay_token",
    };
}

@end

