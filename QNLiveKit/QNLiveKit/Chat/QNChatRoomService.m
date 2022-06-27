//
//  QNChatRoomService.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import "QNChatRoomService.h"
#import "CreateSignalHandler.h"
#import "QIMModel.h"
#import "QNLiveUser.h"
#import "LinkOptionModel.h"
#import "QInvitationModel.h"
#import "QNPKSession.h"
#import <QNIMSDK/QNIMSDK.h>

@interface QNChatRoomService ()<QNIMChatServiceProtocol>

@property (nonatomic, copy) NSString *groupId;

@property(nonatomic, copy)NSString *roomId;

@property (nonatomic, assign) long long lastMessageId;

@property (nonatomic, assign) BOOL isMember;

@property (nonatomic,strong)CreateSignalHandler *creater;

@property (nonatomic, weak)id<QNChatRoomServiceListener> chatRoomListener;


@end

@implementation QNChatRoomService

- (instancetype)initWithGroupId:(NSString *)groupId roomId:(NSString *)roomId{
    if (self = [super init]) {
        self.groupId = groupId;
        self.roomId = roomId;
        [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.groupId message:@"" completion:^(QNIMError * _Nonnull error) {
            if (!error) {
                self.isMember = YES;
            }
        }];
    }
    return self;
}

//添加聊天监听
- (void)addChatServiceListener:(id<QNChatRoomServiceListener>)listener{
    
    [[QNIMChatService sharedOption] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.chatRoomListener = listener;
}

//移除聊天监听
- (void)removeChatServiceListener{
    [[QNIMGroupService sharedOption] leaveGroupWithGroupId:self.groupId completion:^(QNIMError * _Nonnull error) {
        if (!error) {
            self.isMember = NO;
        }
    }];
    [[QNIMChatService sharedOption] removeDelegate:self];
    self.chatRoomListener = nil;
}

//发公聊消息
- (void)sendPubChatMsg:(NSString *)msg callBack:(nonnull void (^)(QNIMMessageObject * _Nonnull))callBack{

    if (self.isMember) {
        QNIMMessageObject *message = [self.creater createChatMessage:msg];
        [[QNIMChatService sharedOption] sendMessage:message];
        callBack(message);
    } else {
        [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.groupId message:@"" completion:^(QNIMError * _Nonnull error) {
            if (!error) {
                self.isMember = YES;
                QNIMMessageObject *message = [self.creater createChatMessage:msg];
                [[QNIMChatService sharedOption] sendMessage:message];
                callBack(message);
            }
        }];
    }
}

- (void)memberSendMsg:(void (^)(void))callBack {
    if (self.isMember) {
        callBack();
    } else {
        [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.groupId message:@"" completion:^(QNIMError * _Nonnull error) {
            if (!error) {
                self.isMember = YES;                
            }
            callBack();
        }];
    }
}

- (void)sendWelComeMsg:(void (^)(QNIMMessageObject * _Nonnull))callBack {
    
    [self memberSendMsg:^{
        QNIMMessageObject *message = [self.creater createJoinRoomMessage];
        [[QNIMChatService sharedOption] sendMessage:message];
        callBack(message);
    }];
   
}

- (void)sendLeaveMsg {
    if (self.isMember) {
        QNIMMessageObject *message = [self.creater createLeaveRoomMessage];
        [[QNIMChatService sharedOption] sendMessage:message];
    } else {
        [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.groupId message:@"" completion:^(QNIMError * _Nonnull error) {
            if (!error) {
                self.isMember = YES;
                QNIMMessageObject *message = [self.creater createLeaveRoomMessage];
                [[QNIMChatService sharedOption] sendMessage:message];
            }
        }];
    }
    
}



//发送连麦邀请
- (void)sendLinkMicInvitation:(QNLiveUser *)receiveUser {
    QNIMMessageObject *message = [self.creater  createInviteMessageWithInvitationName:liveroom_linkmic_invitation receiveRoomId:self.roomId receiveUser:receiveUser];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//接受连麦
- (void)sendLinkMicAccept:(QInvitationModel *)invitationModel{
    invitationModel.invitationName = liveroom_linkmic_invitation;
    QNIMMessageObject *message = [self.creater createAcceptInviteMessageWithInvitationName:liveroom_linkmic_invitation invitationModel:invitationModel];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//拒绝连麦
- (void)sendLinkMicReject:(QInvitationModel *)invitationModel {
    invitationModel.invitationName = liveroom_linkmic_invitation;
    QNIMMessageObject *message = [self.creater createRejectInviteMessageWithInvitationName:liveroom_linkmic_invitation invitationModel:invitationModel];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//发送PK申请
- (void)sendPKInvitation:(NSString *)receiveRoomId receiveUser:(nonnull QNLiveUser *)receiveUser {
        
    QNIMMessageObject *message = [self.creater  createInviteMessageWithInvitationName:liveroom_pk_invitation receiveRoomId:receiveRoomId receiveUser:receiveUser] ;
    [[QNIMChatService sharedOption] sendMessage:message];
        
}
//接受PK申请
- (void)sendPKAccept:(QInvitationModel *)invitationModel {
        
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

-(void)createStartPKMessage:(QNPKSession *)pkSession singleMsg:(BOOL)singleMsg {
    QNIMMessageObject *message = [self.creater  createStartPKMessage:pkSession singleMsg:singleMsg];
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (void)createStopPKMessage:(QNPKSession *)pkSession  {
    QNIMMessageObject *message = [self.creater createStopPKMessage:pkSession];
    [[QNIMChatService sharedOption] sendMessage:message];
}

//踢人
- (void)kickUser:(NSString *)msg memberId:(NSString *)memberId{
    
}
//禁言
- (void)muteUser:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute {
    
}

    
#pragma mark QNIMChatServiceProtocol
    
//消息发送状态改变
- (void)messageStatusChanged:(QNIMMessageObject *)message error:(QNIMError *)error {
//    if ([self.chatRoomListener respondsToSelector:@selector(messageStatus:error:)]) {
//        [self.chatRoomListener messageStatus:message error:error];
//    }
}
    
//收到远端发来的消息
- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    
    
    QNIMMessageObject *msg = messages.firstObject;
    
    if (self.lastMessageId == msg.msgId) {
        return;
    }
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:msg.content.mj_keyValues];
    
    if ([imModel.action isEqualToString:liveroom_pubchat]) {
        //公聊消息
        PubChatModel *model = [PubChatModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onReceivedPuChatMsg:message:)]) {
            [self.chatRoomListener onReceivedPuChatMsg:model message:msg];
        }
    } else if ([imModel.action isEqualToString:liveroom_welcome]) {
        //欢迎消息
        PubChatModel *model = [PubChatModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onUserJoin:message:)]) {
            [self.chatRoomListener onUserJoin:model.sendUser message:msg];
        }
    } else if ([imModel.action isEqualToString:liveroom_bye_bye]) {
        //离开消息
        PubChatModel *model = [PubChatModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onUserLeave:message:)]) {
            [self.chatRoomListener onUserLeave:model.sendUser message:msg];
        }
    } else if ([imModel.action isEqualToString:liveroom_pubchat_custom]) {
        //自定义消息
//        PubChatModel *model = [PubChatModel mj_objectWithKeyValues:imModel.data];
        
//        if ([self.chatRoomListener respondsToSelector:@selector(onUserLeave:)]) {
//            [self.chatRoomListener onUserLeave:model.sendUser];
//        }
    } else if ([imModel.action isEqualToString:living_danmu]) {
        //弹幕消息
        PubChatModel *model = [PubChatModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onReceivedDamaku:)]) {
            [self.chatRoomListener onReceivedDamaku:model];
        }
    } else if ([imModel.action isEqualToString:liveroom_miclinker_kick]) {
        //被踢消息
        LinkOptionModel *model = [LinkOptionModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onUserBeKicked:msg:)]) {
            [self.chatRoomListener onUserBeKicked:model.uid msg:model.msg];
        }
    } else if ([imModel.action isEqualToString:liveroom_miclinker_join]) {
        //上麦消息
        QNMicLinker *model = [QNMicLinker mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onReceivedOnMic:)]) {
            [self.chatRoomListener onReceivedOnMic:model];
        }
    } else if ([imModel.action isEqualToString:liveroom_miclinker_left]) {
        //下麦消息
        QNMicLinker *model = [QNMicLinker mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onReceivedDownMic:)]) {
            [self.chatRoomListener onReceivedDownMic:model];
        }
    } else if ([imModel.action isEqualToString:liveroom_miclinker_microphone_mute]) {
        //开关音频消息
        LinkOptionModel *model = [LinkOptionModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onReceivedAudioMute:user:)]) {
            [self.chatRoomListener onReceivedAudioMute:model.mute user:model.uid];
        }
    } else if ([imModel.action isEqualToString:liveroom_miclinker_camera_mute]) {
        //开关视频消息
        LinkOptionModel *model = [LinkOptionModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onReceivedVideoMute:user:)]) {
            [self.chatRoomListener onReceivedVideoMute:model.mute user:model.uid];
        }
    }  else if ([imModel.action isEqualToString:liveroom_miclinker_microphone_forbidden]) {
        //音频被禁消息
        LinkOptionModel *model = [LinkOptionModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onReceivedAudioBeForbidden:user:)]) {
            [self.chatRoomListener onReceivedAudioBeForbidden:model.forbidden user:model.uid];
        }
    }  else if ([imModel.action isEqualToString:liveroom_miclinker_camera_forbidden]) {
        //视频被禁消息
        LinkOptionModel *model = [LinkOptionModel mj_objectWithKeyValues:imModel.data];
        
        if ([self.chatRoomListener respondsToSelector:@selector(onReceivedVideoBeForbidden:user:)]) {
            [self.chatRoomListener onReceivedVideoBeForbidden:model.forbidden user:model.uid];
        }
    }  else if ([imModel.action isEqualToString:invite_send]) {
        //连麦邀请消息
        QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
        if ([model.invitation.msg.receiver.user_id isEqualToString:QN_User_id]) {
            
            if ([model.invitationName isEqualToString:liveroom_linkmic_invitation]) {
                if ([self.chatRoomListener respondsToSelector:@selector(onReceiveLinkInvitation:)]) {
                    [self.chatRoomListener onReceiveLinkInvitation:model];
                }
            }
        }
        if ([model.invitationName isEqualToString:liveroom_pk_invitation]) {
            if ([self.chatRoomListener respondsToSelector:@selector(onReceivePKInvitation:)]) {
                [self.chatRoomListener onReceivePKInvitation:model];
            }
        }
                
    }  else if ([imModel.action isEqualToString:invite_accept]) {
        //连麦邀请被接受
        QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
            
        if ([model.invitationName isEqualToString:liveroom_linkmic_invitation]) {
                if ([self.chatRoomListener respondsToSelector:@selector(onReceiveLinkInvitationAccept:)]) {
                    [self.chatRoomListener onReceiveLinkInvitationAccept:model];
                }
            } else if ([model.invitationName isEqualToString:liveroom_pk_invitation]) {
                if ([self.chatRoomListener respondsToSelector:@selector(onReceivePKInvitationAccept:)]) {
                    [self.chatRoomListener onReceivePKInvitationAccept:model];
                }
            }
        
    }  else if ([imModel.action isEqualToString:invite_reject]) {
        //连麦邀请被拒绝
        QInvitationModel *model = [QInvitationModel mj_objectWithKeyValues:imModel.data];
        
            
            if ([model.invitationName isEqualToString:liveroom_linkmic_invitation]) {
                if ([self.chatRoomListener respondsToSelector:@selector(onReceiveLinkInvitationReject:)]) {
                    [self.chatRoomListener onReceiveLinkInvitationReject:model];
                }
            } else if ([model.invitationName isEqualToString:liveroom_pk_invitation]) {
                if ([self.chatRoomListener respondsToSelector:@selector(onReceivePKInvitationReject:)]) {
                    [self.chatRoomListener onReceivePKInvitationReject:model];
                }
                        
            }
        
    }  else if ([imModel.action isEqualToString:liveroom_pk_start]) {
        //开始pk
        QNPKSession *model = [QNPKSession mj_objectWithKeyValues:imModel.data];
                    
        if ([self.chatRoomListener respondsToSelector:@selector(onReceiveStartPKSession:)]) {
            [self.chatRoomListener onReceiveStartPKSession:model];
        }
    
    }  else if ([imModel.action isEqualToString:liveroom_pk_stop]) {
        //结束pk
        QNPKSession *model = [QNPKSession mj_objectWithKeyValues:imModel.data];
                    
        if ([self.chatRoomListener respondsToSelector:@selector(onReceiveStopPKSession:)]) {
            [self.chatRoomListener onReceiveStopPKSession:model];
        }
    
    }
    
    self.lastMessageId=msg.msgId;

}

- (CreateSignalHandler *)creater {
    if (!_creater) {
        _creater = [[CreateSignalHandler alloc]initWithToId:self.groupId roomId:self.roomId];
    }
    return _creater;
}

@end
