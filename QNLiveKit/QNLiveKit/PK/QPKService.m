//
//  QPKService.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import "QPKService.h"
#import "QLiveNetworkUtil.h"
#import "QNLiveUser.h"
#import "CreateSignalHandler.h"
#import "QIMModel.h"
#import "LinkOptionModel.h"
#import "QInvitationModel.h"
#import <QNIMSDK/QNIMSDK.h>


@interface QPKService ()

@property (nonatomic,strong)CreateSignalHandler *creater;

@property (nonatomic,strong)QNPKSession *pkSession;
@end

@implementation QPKService

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIMMessageNotification:) name:ReceiveIMMessageNotification object:nil];
    }
    return self;
}

- (void)receiveIMMessageNotification:(NSNotification *)notice {
    
    NSDictionary *dic = notice.userInfo;
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:dic.mj_keyValues];
    
    if ([imModel.action isEqualToString:invite_send]) {
       //收到pk邀请消息
       QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
       if ([model.invitation.msg.receiver.user_id isEqualToString:QN_User_id]) {
           if ([model.invitationName isEqualToString:liveroom_pk_invitation]) {
               if ([self.delegate respondsToSelector:@selector(onReceivePKInvitation:)]) {
                   [self.delegate onReceivePKInvitation:model];
               }
           }
       }
   }  else if ([imModel.action isEqualToString:invite_accept]) {
       //pk邀请被接受
       QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];

        if ([model.invitationName isEqualToString:liveroom_pk_invitation]) {
               
            QNPKSession *session = [QNPKSession mj_objectWithKeyValues:model.invitation.msg.mj_keyValues];
            
            [self startWithPKSession:session callBack:^(QNPKSession * _Nullable pkSession) {
                
                session.relay_id = pkSession.relay_id;
                session.relay_token = pkSession.relay_token;
                session.relay_status = pkSession.relay_status;

                if ([self.delegate respondsToSelector:@selector(onReceivePKInvitationAccept:)]) {
                        [self.delegate onReceivePKInvitationAccept:session];
                }
                
                [self beginPK:session callBack:nil];
            }];
        }
   }  else if ([imModel.action isEqualToString:invite_reject]) {
       //pk邀请被拒绝
       QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
                  
        if ([model.invitationName isEqualToString:liveroom_pk_invitation]) {
            if ([self.delegate respondsToSelector:@selector(onReceivePKInvitationReject:)]) {
                [self.delegate onReceivePKInvitationReject:model];
            }                       
        }
   }  else if ([imModel.action isEqualToString:liveroom_pk_start]) {
       //开始pk
       QNPKSession *model = [QNPKSession mj_objectWithKeyValues:imModel.data];
       
       if ([QN_User_id isEqualToString:model.initiator.user_id] || [QN_User_id isEqualToString:model.receiver.user_id]) {
           
           [self getPKToken:model.relay_id callBack:^(QNPKSession * session) {
               
               model.relay_id = session.relay_id;
               model.relay_token = session.relay_token;
               model.relay_status = session.relay_status;
               
               if ([self.delegate respondsToSelector:@selector(onReceiveStartPKSession:)]) {
                   [self.delegate onReceiveStartPKSession:model];
               }
                [self beginPK:model callBack:nil];
                [self PKStarted];
           }];
           
       } else {
           if ([self.delegate respondsToSelector:@selector(onReceiveStartPKSession:)]) {
               [self.delegate onReceiveStartPKSession:model];
           }
       }
   }  else if ([imModel.action isEqualToString:liveroom_pk_stop]) {
       //结束pk
       QNPKSession *model = [QNPKSession mj_objectWithKeyValues:imModel.data];
                   
       if ([self.delegate respondsToSelector:@selector(onReceiveStopPKSession:)]) {
           [self.delegate onReceiveStopPKSession:model];
       }
   }
}

- (void)beginPK:(QNPKSession *)pkSession callBack:(nullable void (^)(void))callBack {

    QNRoomMediaRelayConfiguration *config = [[QNRoomMediaRelayConfiguration alloc]init];
    
    QNRoomMediaRelayInfo *srcRoomInfo = [QNRoomMediaRelayInfo new];
    srcRoomInfo.roomName = self.roomInfo.title;
    srcRoomInfo.token = self.roomInfo.room_token;
    
    QNRoomMediaRelayInfo *destInfo = [QNRoomMediaRelayInfo new];
    destInfo.roomName = [self getRelayNameWithToken:pkSession.relay_token];
    destInfo.token = pkSession.relay_token;
    
    config.srcRoomInfo = srcRoomInfo;
    [config setDestRoomInfo:destInfo forRoomName:self.roomInfo.title];

    [[QLive createPusherClient].rtcClient startRoomMediaRelay:config completeCallback:^(NSDictionary *state, NSError *error) {
        [self sendStartPKMessage:pkSession singleMsg:NO];
    }];
    
}

- (NSString *)getRelayNameWithToken:(NSString *)token {
    if (token.length == 0) {
        return @"";
    }
    NSArray *arr = [token componentsSeparatedByString:@":"];
    NSString *tokenDataStr = arr.lastObject;
    NSData *data = [[NSData alloc]initWithBase64EncodedString:tokenDataStr options:0];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *roomName = dic[@"roomName"];
    return roomName;
}

- (void)startWithPKSession:(QNPKSession *)pkSession callBack:(nullable void (^)(QNPKSession * _Nullable pkSession))callBack {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"recv_room_id"] = pkSession.receiverRoomId;
    params[@"recv_user_id"] = pkSession.receiver.user_id;
    params[@"init_room_id"] = self.roomInfo.live_id;
    [QLiveNetworkUtil postRequestWithAction:@"client/relay/start" params:params success:^(NSDictionary * _Nonnull responseData) {
        
        QNPKSession *model = [QNPKSession mj_objectWithKeyValues:responseData];
        model.receiverRoomId = pkSession.receiverRoomId;
        model.initiatorRoomId = self.roomInfo.live_id;
        model.initiator = pkSession.initiator;
        model.receiver = pkSession.receiver;

        self.pkSession = model;
        [self sendStartPKMessage:model singleMsg:YES];
        
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {

        }];
}

//发送PK申请
- (void)applyPK:(NSString *)receiveRoomId receiveUser:(nonnull QNLiveUser *)receiveUser {
        
    QNIMMessageObject *message = [self.creater  createInviteMessageWithInvitationName:liveroom_pk_invitation receiveRoomId:receiveRoomId receiveUser:receiveUser] ;
    [[QNIMChatService sharedOption] sendMessage:message];
        
}
//接受PK申请
- (void)AcceptPK:(QInvitationModel *)invitationModel {
        
    invitationModel.invitationName = liveroom_pk_invitation;
    QNIMMessageObject *message = [self.creater  createAcceptInviteMessageWithInvitationName:liveroom_pk_invitation invitationModel:invitationModel];
    [[QNIMChatService sharedOption] sendMessage:message];
        
}

//拒绝PK申请
- (void)sendPKReject:(QInvitationModel *)invitationModel {
    invitationModel.invitationName = liveroom_pk_invitation;
    QNIMMessageObject *message = [self.creater  createRejectInviteMessageWithInvitationName:liveroom_pk_invitation invitationModel:invitationModel];
    [[QNIMChatService sharedOption] sendMessage:message];
        
}

//发送开始pk信令
-(void)sendStartPKMessage:(QNPKSession *)pkSession singleMsg:(BOOL)singleMsg {
    QNIMMessageObject *message = [self.creater  createStartPKMessage:pkSession singleMsg:singleMsg];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//发送结束pk信令
- (void)createStopPKMessage:(QNPKSession *)pkSession  {
    QNIMMessageObject *message = [self.creater createStopPKMessage:pkSession];
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (void)getPKToken:(NSString *)relayID callBack:(nullable void (^)(QNPKSession * _Nullable))callBack {
    NSString *action = [NSString stringWithFormat:@"client/relay/%@/token",relayID];
    [QLiveNetworkUtil getRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        QNPKSession *model = [QNPKSession mj_objectWithKeyValues:responseData];
        self.pkSession = model;
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

- (void)PKStarted {
    NSString *action = [NSString stringWithFormat:@"client/relay/%@/started",self.pkSession.relay_id];
    [QLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {        
        } failure:^(NSError * _Nonnull error) {
        }];
}

//结束pk
- (void)stopPK:(nullable void (^)(void))callBack {
    
    [self createStopPKMessage:self.pkSession];
    [[QLive createPusherClient].rtcClient stopRoomMediaRelay:^(NSDictionary *state, NSError *error) {}];
    [[[QLive createPusherClient] getMixStreamManager] updateMixStreamSize:CGSizeMake(720, 1280)];

    NSString *action = [NSString stringWithFormat:@"client/relay/%@/stop",self.pkSession.relay_id];
    [QLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        } failure:^(NSError * _Nonnull error) {

        }];
}



- (CreateSignalHandler *)creater {
    if (!_creater) {
        _creater = [[CreateSignalHandler alloc]initWithToId:self.roomInfo.chat_id roomId:self.roomInfo.live_id];
    }
    return _creater;
}

- (QNLiveUser *)selfUser {
    QNLiveUser *user = [QNLiveUser new];
    user.user_id = QN_User_id;
    user.nick = QN_User_nickname;
    user.avatar = QN_User_avatar;
    user.im_userid = QN_IM_userId;
    user.im_username = QN_IM_userName;
    return user;
}

@end
