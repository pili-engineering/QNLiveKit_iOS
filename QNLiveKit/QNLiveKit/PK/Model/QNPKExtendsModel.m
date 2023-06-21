//
//  QNPKExtendsModel.m
//  QNLiveKit
//
//  Created by xiaodao on 2023/6/14.
//

#import "QNPKExtendsModel.h"

#pragma mark - QNPKExtendsModel

@implementation QNPKExtendsModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"initiatorRoomId": @"init_room_id",
        @"receiverRoomId": @"recv_room_id"
    };
}

@end


#pragma mark - QNPKIntegralModel

@implementation QNPKIntegralModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"initiatorRoomId": @"init_room_id",
        @"initiatorUserId": @"init_user_id",
        @"initiatorScore": @"init_score",
        
        @"receiverRoomId": @"recv_room_id",
        @"receiverUserId": @"recv_user_id",
        @"receiverScore": @"recv_score",
    };
}

@end

