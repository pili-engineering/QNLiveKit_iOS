//
//  QNSendMsgTool.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "CreateSignalHandler.h"
#import "QNInvitationModel.h"
#import "QNGiftMsgModel.h"
#import "QNIMModel.h"
#import <QNIMSDK/QNIMSDK.h>
#import "PubChatModel.h"
#import "QNMicLinker.h"
#import "LinkOptionModel.h"
#import "QNIMModel.h"
#import "QNPKSession.h"

@interface CreateSignalHandler ()

@property(nonatomic, copy)NSString *toId;

@property(nonatomic, copy)NSString *roomId;

@end

@implementation CreateSignalHandler

- (instancetype)initWithToId:(NSString *)toId roomId:(NSString *)roomId{
    if (self = [super init]) {
        self.toId = toId;
        self.roomId = roomId;
    }
    return self;
}

//生成加入房间消息
- (QNIMMessageObject *)createJoinRoomMessage {
    
    PubChatModel *model = [self messageWithAction:liveroom_welcome content:@"加入房间"];
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_welcome;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成离开房间消息
- (QNIMMessageObject *)createLeaveRoomMessage {
    
    PubChatModel *model = [self messageWithAction:liveroom_bye_bye content:@"离开房间"];
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_welcome;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成聊天消息
- (QNIMMessageObject *)createChatMessage:(NSString *)content {
    
    PubChatModel *model = [self messageWithAction:liveroom_pubchat content:content];
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_pubchat;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;    
    return message;
}

//生成点赞消息
- (QNIMMessageObject *)createLikeMessage:(NSString *)content {
    
    PubChatModel *model = [self messageWithAction:liveroom_like content:content];
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_pubchat;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成自定义消息
- (QNIMMessageObject *)createCustomMessage:(NSString *)content {
    
    PubChatModel *model = [self messageWithAction:liveroom_pubchat_custom content:content];
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_pubchat;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成弹幕消息
- (QNIMMessageObject *)createDanmuMessage:(NSString *)content {

    PubChatModel *model = [self messageWithAction:liveroom_danmaku content:content];
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_pubchat;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    
    return message;
}

//生成礼物消息
- (QNIMMessageObject *)createGiftMessage:(QNGiftModel *)giftModel number:(NSInteger)number extMsg:(NSString *)extMsg {
    
    QNGiftMsgModel *giftMsgModel = [QNGiftMsgModel new];
    giftMsgModel.senderUid = QN_User_id;
    giftMsgModel.senderName = QN_User_nickname;
    giftMsgModel.senderAvatar = QN_User_avatar;
    giftMsgModel.senderRoomId = self.toId;
    giftMsgModel.sendGift = giftModel;
    giftMsgModel.number = number;
    giftMsgModel.extMsg = extMsg;
    
    QNIMModel *model = [QNIMModel new];
    model.action = @"living_gift";
    model.data = giftMsgModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//发送上麦信令
- (QNIMMessageObject *)createOnMicMessage {
    QNIMMessageObject *message = [self sendMicMessage:liveroom_miclinker_join openAudio:YES openVideo:YES];
    return message;
}

//发送下麦信令
- (QNIMMessageObject *)createDownMicMessage {
    QNIMMessageObject *message = [self sendMicMessage:liveroom_miclinker_left openAudio:NO openVideo:NO];
    return message;
}

//连麦踢人信令
- (QNIMMessageObject *)createKickMessage:(NSString *)uid msg:(NSString *)msg {
    
    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = uid;
    model.msg = msg;

    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_miclinker_kick;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}


//开关麦信令（音频）
- (QNIMMessageObject *)createMicStatusMessage:(BOOL)openAudio {
    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = QN_User_id;
    model.mute = !openAudio;

    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_miclinker_microphone_mute;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//开关麦信令（视频）
- (QNIMMessageObject *)createCameraStatusMessage:(BOOL)openVideo {
    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = QN_User_id;
    model.mute = !openVideo;

    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_miclinker_camera_mute;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//禁音频
- (QNIMMessageObject *)createForbiddenAudio:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg {
    
    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = userId;
    model.mute = isForbidden;

    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_miclinker_microphone_forbidden;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//禁视频
- (QNIMMessageObject *)createForbiddenVideo:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg{
    
    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = userId;
    model.mute = isForbidden;

    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = liveroom_miclinker_camera_forbidden;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//发送邀请信令
- (QNIMMessageObject *)createInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:invite_send invitationName:invitationName receiverId:receiverId receiveRoomId:receiveRoomId receiverIMId:receiverIMId];
    return message;
}

//发送取消邀请信令
- (QNIMMessageObject *)createCancelInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId{
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:invite_cancel invitationName:invitationName receiverId:receiverId receiveRoomId:receiveRoomId receiverIMId:receiverIMId];
    return message;
}

//发送接受邀请信令
- (QNIMMessageObject *)createAcceptInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:invite_accept invitationName:invitationName receiverId:receiverId receiveRoomId:receiveRoomId receiverIMId:receiverIMId];
    return message;
}

//发送拒绝邀请信令
- (QNIMMessageObject *)createRejectInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId{
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:invite_reject invitationName:invitationName receiverId:receiverId receiveRoomId:receiveRoomId receiverIMId:receiverIMId];
    return message;
}

-(QNIMMessageObject *)createStartPKMessageWithReceiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId relayId:(NSString *)relayId relayToken:(NSString *)relayToken {
    
    QNPKSession *session = [QNPKSession new];
    session.relay_id = relayId;
    session.relay_token = relayToken;
    session.initiatorRoomId = self.roomId;
    session.receiverRoomId = receiveRoomId;
    session.initiator = self.user;
    
    QNLiveUser *user = [QNLiveUser new];
    user.user_id = receiverId;
    user.im_userid = receiverIMId;
    
    session.receiver = user;
    
    QNIMModel *model = [QNIMModel new];
    model.action = liveroom_pk_start;
    model.data = session.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:receiverIMId.longLongValue type:QNIMMessageTypeSingle conversationId:receiverIMId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;

}

//生成邀请信令
- (QNIMMessageObject *)createInviteMessageWithAction:(NSString *)action invitationName:(NSString *)invitationName receiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId {
    
    QNLiveUser *receiver = [QNLiveUser new];
    receiver.user_id = receiverId;
    
    LinkInvitation *link = [LinkInvitation new];
    link.initiator = self.user;
    link.receiver = receiver;
    link.initiatorRoomId = self.roomId;
    link.receiverRoomId = receiveRoomId;
    
    QNInvitationInfo *info = [QNInvitationInfo new];
    info.channelId = self.toId;
    info.initiatorUid = QN_User_id;
    info.msg = link;
    info.receiver =  receiverId;
    info.timeStamp = [self getNowTimeTimestamp3];
    
    QNInvitationModel *invitationData = [QNInvitationModel new];
    invitationData.invitationName = invitationName;
    invitationData.invitation = info;
    
    QNIMModel *model = [QNIMModel new];
    model.action = action;
    model.data = invitationData.mj_keyValues;
    
    if ([invitationName isEqualToString:liveroom_pk_invitation]) {
        QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:receiverIMId.longLongValue type:QNIMMessageTypeSingle conversationId:receiverIMId.longLongValue];
        message.senderName = QN_User_nickname;
        return message;
    }
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成进房/离房/点赞/聊天/弹幕消息
- (PubChatModel *)messageWithAction:(NSString *)action content:(NSString *)content {
    
    PubChatModel *model = [PubChatModel new];
    model.sendUser = self.user;
    model.content = content;
    model.senderRoomId = self.roomId;
    model.action = action;
    
    return model;
    
}

//上下麦信令
- (QNIMMessageObject *)sendMicMessage:(NSString *)action openAudio:(BOOL)openAudio openVideo:(BOOL)openVideo {

    QNMicLinker *mic = [QNMicLinker new];
    mic.user = self.user;
    mic.camera = openVideo;
    mic.mic = openAudio;
    mic.userRoomId = self.roomId;
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = action;
    messageModel.data = mic.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    
    return message;
    
}

- (NSString *)getNowTimeTimestamp3{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;

    [formatter setDateStyle:NSDateFormatterMediumStyle];

    [formatter setTimeStyle:NSDateFormatterShortStyle];

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制

   NSTimeZone*timeZone=[NSTimeZone timeZoneWithName:@"Asia/Shanghai"];

    [formatter setTimeZone:timeZone];

    NSDate *datenow = [NSDate date];

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];

    return timeSp;

}

- (QNLiveUser *)user {
    
    QNLiveUser *user = [QNLiveUser new];
    user.user_id = QN_User_id;
    user.nick = QN_User_nickname;
    user.avatar = QN_User_avatar;
    user.im_userid = QN_IM_userId;
    user.im_username = QN_IM_userName;
    return user;
}

@end
