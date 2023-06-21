//
//  QNPKSession.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QNPKSession.h"
#import "QInvitationModel.h"
#import "LinkInvitation.h"

#pragma mark - QNPKSession

@implementation QNPKSession

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"sessionId" : @"relay_id",
        @"status" : @"relay_status",
        @"extensions": @"extension",
    };
}

@end


#pragma mark - QNPKSession (fromInvitation)

@implementation QNPKSession (fromInvitation)

// QInvitationModel -> QNPKSession
+ (instancetype)fromInvitationModel:(QInvitationModel *)invitationModel {
    QNPKSession *session = [[QNPKSession alloc] init];
    session.initiator = invitationModel.invitation.linkInvitation.initiator;
    session.receiver = invitationModel.invitation.linkInvitation.receiver;
    session.initiatorRoomId = invitationModel.invitation.linkInvitation.initiatorRoomId;
    session.receiverRoomId = invitationModel.invitation.linkInvitation.receiverRoomId;
    return session;
}

@end

