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

//添加聊天监听
- (void)addChatServiceListener:(id<QNChatRoomServiceListener>)listener{
    
    self.groupId = self.roomInfo.chat_id;
    self.roomId = self.roomInfo.live_id;
    [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.groupId message:@"" completion:^(QNIMError * _Nonnull error) {
        if (!error) {
            self.isMember = YES;
        }
    }];
    
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

//禁言
- (void)muteUser:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute {
    
}

    
#pragma mark QNIMChatServiceProtocol
    
//收到远端发来的消息
- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    
    QNIMMessageObject *msg = messages.firstObject;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveIMMessageNotification object:nil userInfo:msg.content.mj_keyValues];
    
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
    } 
    

}

- (CreateSignalHandler *)creater {
    if (!_creater) {
        _creater = [[CreateSignalHandler alloc]initWithToId:self.groupId roomId:self.roomId];
    }
    return _creater;
}

@end
