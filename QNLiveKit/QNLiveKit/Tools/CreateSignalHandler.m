//
//  QNSendMsgTool.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "CreateSignalHandler.h"
#import "QInvitationModel.h"
#import "QGiftMsgModel.h"
#import "QIMModel.h"
#import <QNIMSDK/QNIMSDK.h>
#import "PubChatModel.h"
#import "QNMicLinker.h"
#import "LinkOptionModel.h"
#import "LinkInvitation.h"
#import "QIMModel.h"
#import "QNPKSession.h"
#import "GoodsModel.h"

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
    
    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_welcome;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//生成离开房间消息
- (QNIMMessageObject *)createLeaveRoomMessage {
    
    PubChatModel *model = [self messageWithAction:liveroom_bye_bye content:@"离开房间"];
    
    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_welcome;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//生成聊天消息
- (QNIMMessageObject *)createChatMessage:(NSString *)content {
    
    PubChatModel *model = [self messageWithAction:liveroom_pubchat content:content];
    
    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_pubchat;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//生成点赞消息
- (QNIMMessageObject *)createLikeMessage:(NSString *)content {
    
    PubChatModel *model = [self messageWithAction:liveroom_like content:content];
    
    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_pubchat;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//生成自定义消息
- (QNIMMessageObject *)createCustomMessage:(NSString *)content {
    
    PubChatModel *model = [self messageWithAction:liveroom_pubchat_custom content:content];
    
    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_pubchat;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//生成弹幕消息
- (QNIMMessageObject *)createDanmuMessage:(NSString *)content {

    PubChatModel *model = [self messageWithAction:living_danmu content:content];
    
    QIMModel *messageModel = [QIMModel new];
    messageModel.action = living_danmu;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    
    return message;
}

//生成礼物消息
- (QNIMMessageObject *)createGiftMessage:(QGiftModel *)giftModel number:(NSInteger)number extMsg:(NSString *)extMsg {
    
    QGiftMsgModel *giftMsgModel = [QGiftMsgModel new];
    giftMsgModel.senderUid = LIVE_User_id;
    giftMsgModel.senderName = LIVE_User_nickname;
    giftMsgModel.senderAvatar = LIVE_User_avatar;
    giftMsgModel.senderRoomId = self.toId;
    giftMsgModel.sendGift = giftModel;
    giftMsgModel.number = number;
    giftMsgModel.extMsg = extMsg;
    
    QIMModel *model = [QIMModel new];
    model.action = @"living_gift";
    model.data = giftMsgModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
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

    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_miclinker_kick;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}


//开关麦信令（音频）
- (QNIMMessageObject *)createMicStatusMessage:(BOOL)openAudio {
    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = LIVE_User_id;
    model.mute = !openAudio;

    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_miclinker_microphone_mute;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//开关麦信令（视频）
- (QNIMMessageObject *)createCameraStatusMessage:(BOOL)openVideo {
    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = LIVE_User_id;
    model.mute = !openVideo;

    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_miclinker_camera_mute;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//禁音频
- (QNIMMessageObject *)createForbiddenAudio:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg {
    
    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = userId;
    model.mute = isForbidden;

    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_miclinker_microphone_forbidden;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//禁视频
- (QNIMMessageObject *)createForbiddenVideo:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg{
    
    LinkOptionModel *model = [LinkOptionModel new];
    model.uid = userId;
    model.mute = isForbidden;

    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_miclinker_camera_forbidden;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//发送邀请信令
- (QNIMMessageObject *)createInviteMessageWithInvitationName:(NSString *)invitationName receiveRoomId:(NSString *)receiveRoomId receiveUser:(nonnull QNLiveUser *)receiveUser {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:invite_send invitationName:invitationName receiveRoomId:receiveRoomId receiveUser:receiveUser];
    return message;
}

//发送取消邀请信令
- (QNIMMessageObject *)createCancelInviteMessageWithInvitationName:(NSString *)invitationName receiveRoomId:(NSString *)receiveRoomId receiveUser:(nonnull QNLiveUser *)receiveUser{
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:invite_cancel invitationName:invitationName receiveRoomId:receiveRoomId receiveUser:receiveUser];
    return message;
}

//发送接受邀请信令
- (QNIMMessageObject *)createAcceptInviteMessageWithInvitationName:(NSString *)invitationName invitationModel:(QInvitationModel *)invitationModel {
    QNIMMessageObject *message = [self createDealInvitationMessageWithAction:invite_accept invitationModel:invitationModel];
    return message;
}

//发送拒绝邀请信令
- (QNIMMessageObject *)createRejectInviteMessageWithInvitationName:(NSString *)invitationName invitationModel:(QInvitationModel *)invitationModel{
    
    QNIMMessageObject *message = [self createDealInvitationMessageWithAction:invite_reject invitationModel:invitationModel];
    return message;
}

//开始pk
-(QNIMMessageObject *)createStartPKMessage:(QNPKSession *)pkSession singleMsg:(BOOL)singleMsg {
    
    QIMModel *model = [QIMModel new];
    model.action = liveroom_pk_start;
    model.data = pkSession.mj_keyValues;
    
    if (singleMsg) {
        QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:pkSession.receiver.im_userid.longLongValue type:QNIMMessageTypeSingle conversationId:pkSession.receiver.im_userid.longLongValue];
        message.senderName = LIVE_User_nickname;
        return message;
    }
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;

}

//结束pk
- (QNIMMessageObject *)createStopPKMessage:(QNPKSession *)pkSession{
    
    QIMModel *model = [QIMModel new];
    model.action = liveroom_pk_stop;
    model.data = pkSession.mj_keyValues;
    
    //告诉对面主播
    NSString *toID = [pkSession.initiator.im_userid isEqualToString:LIVE_IM_userId] ? pkSession.receiver.im_userid : pkSession.initiator.im_userid;
    QNIMMessageObject *singleMessage = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:toID.longLongValue type:QNIMMessageTypeSingle conversationId:toID.longLongValue];
    singleMessage.senderName = LIVE_User_nickname;
    [[QNIMChatService sharedOption] sendMessage:singleMessage];
    
    //告诉观众
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    
    return message;
}

- (QNIMMessageObject *)createDealInvitationMessageWithAction:(NSString *)action invitationModel:(QInvitationModel *)invitationModel {
    
    QIMModel *model = [QIMModel new];
    model.action = action;
    model.data = invitationModel.mj_keyValues;

    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:invitationModel.invitation.msg.initiator.im_userid.longLongValue type:QNIMMessageTypeSingle conversationId:invitationModel.invitation.msg.initiator.im_userid.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//生成邀请信令
- (QNIMMessageObject *)createInviteMessageWithAction:(NSString *)action invitationName:(NSString *)invitationName receiveRoomId:(NSString *)receiveRoomId receiveUser:(QNLiveUser *)receiveUser {
    
    LinkInvitation *link = [LinkInvitation new];
    link.initiator = self.user;
    link.receiver = receiveUser;
    link.initiatorRoomId = self.roomId;
    link.receiverRoomId = receiveRoomId;
    
    QInvitationInfo *info = [QInvitationInfo new];
//    info.channelId = self.toId;
    info.initiatorUid = LIVE_User_id;
    info.msg = link;
//    info.receiver =  receiverId;
    info.timeStamp = [self getNowTimeTimestamp3];
    
    QInvitationModel *invitationData = [QInvitationModel new];
    invitationData.invitationName = invitationName;
    invitationData.invitation = info;
    
    QIMModel *model = [QIMModel new];
    model.action = action;
    model.data = invitationData.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:receiveUser.im_userid.longLongValue type:QNIMMessageTypeSingle conversationId:receiveUser.im_userid.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
    
}

//切换讲解商品消息
- (QNIMMessageObject *)createExplainGoodMsg:(GoodsModel *)model {

    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_shopping_explaining;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    return message;
}

//商品列表更新
- (QNIMMessageObject *)createRefreshGoodMsg {
    
    QIMModel *messageModel = [QIMModel new];
    messageModel.action = liveroom_shopping_refresh;
    messageModel.data = [NSDictionary dictionary];
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
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
    
    QIMModel *messageModel = [QIMModel new];
    messageModel.action = action;
    if ([action isEqualToString:liveroom_miclinker_join]) {
        messageModel.data = mic.mj_keyValues;
    } else {
        messageModel.data = @{@"uid" : LIVE_User_id};
    }
    
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:LIVE_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = LIVE_User_nickname;
    
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
    user.user_id = LIVE_User_id;
    user.nick = LIVE_User_nickname;
    user.avatar = LIVE_User_avatar;
    user.im_userid = LIVE_IM_userId;
    user.im_username = LIVE_IM_userName;
    return user;
}

@end
