//
//  QNPKInfo.m
//  QNLiveKit
//
//  Created by xiaodao on 2023/6/14.
//

#import "QNPKInfo.h"

#pragma mark - QNPKInfo

@implementation QNPKInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"createdAt" : @"created_at",
        @"extensions" : @"extends",
        @"relayId" : @"id",
        @"initiatorRoomId": @"init_room_id",
        @"initiatorUserId": @"init_user_id",
        
        @"receiverRoomId": @"recv_room_id",
        @"receiverUserId": @"recv_user_id",
        
        @"startAt": @"start_at",
    };
}

- (long long)getStartTimeStamp {
    //如果startAt为空，则使用createdAt作为开始时间
    return (self.startAt > 0) ? self.startAt : self.createdAt;
}

@end


#pragma mark - QNPKInfo (ToSession)

@implementation QNPKInfo (ToSession)

- (QNPKSession *_Nullable)toSession {
    QNPKSession *session = [[QNPKSession alloc] init];
    session.sessionId = self.relayId;
    session.initiatorRoomId = self.initiatorRoomId;
    session.receiverRoomId = self.receiverRoomId;
    session.extensions = self.extensions;
    session.status = (QNPKStatus)self.status;
    session.startTimeStamp = [self getStartTimeStamp];
    
    QNLiveUser *initiator = [[QNLiveUser alloc] init];
    initiator.user_id = self.initiatorUserId;
    session.initiator = initiator;
    
    QNLiveUser *receiver = [[QNLiveUser alloc] init];
    receiver.user_id = self.receiverUserId;
    session.receiver = receiver;
    return session;
}

@end

