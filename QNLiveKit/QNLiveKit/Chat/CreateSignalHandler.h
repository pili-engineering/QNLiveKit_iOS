//
//  QNSendMsgTool.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//  消息创建器

#import <Foundation/Foundation.h>

static NSString * const liveroom_welcome = @"liveroom-welcome";
static NSString * const liveroom_bye_bye = @"liveroom-bye-bye";
static NSString * const liveroom_like = @"liveroom-like";
static NSString * const liveroom_pubchat = @"liveroom-pubchat";
static NSString * const liveroom_pubchat_custom = @"liveroom-pubchat-custom";
static NSString * const liveroom_danmaku = @"liveroom_danmaku";

static NSString * const liveroom_miclinker_join = @"liveroom_miclinker_join";
static NSString * const liveroom_miclinker_left = @"liveroom_miclinker_left";
static NSString * const liveroom_miclinker_kick = @"liveroom_miclinker_kick";//连麦踢人
static NSString * const liveroom_miclinker_microphone_mute = @"liveroom_miclinker_microphone_mute";//本地麦克风状态
static NSString * const liveroom_miclinker_camera_mute = @"liveroom_miclinker_camera_mute";//本地摄像头状态
static NSString * const liveroom_miclinker_microphone_forbidden = @"liveroom_miclinker_microphone_forbidden";//管理员禁用
static NSString * const liveroom_miclinker_camera_forbidden = @"liveroom_miclinker_camera_forbidden";
static NSString * const liveroom_miclinker_extension_change = @"liveroom_miclinker_extension_change";

static NSString * const liveroom_linkmic_invitation = @"liveroom_linkmic_invitation";//连麦邀请信令
static NSString * const liveroom_pk_invitation = @"liveroom_pk_invitation";//pk邀请信令
static NSString * const liveroom_pk_start = @"liveroom_pk_start";
static NSString * const liveroom_pk_stop = @"liveroom_pk_stop";

static NSString * const invite_send = @"invite_send";
static NSString * const invite_cancel = @"invite_cancel";
static NSString * const invite_accept = @"invite_accept";
static NSString * const invite_reject = @"invite_reject";

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageObject,QNGiftModel;

@interface CreateSignalHandler : NSObject

- (instancetype)initWithToId:(NSString *)toId roomId:(NSString *)roomId;

//加入房间消息
- (QNIMMessageObject *)createJoinRoomMessage;

//离开房间消息
- (QNIMMessageObject *)createLeaveRoomMessage;

//聊天消息
- (QNIMMessageObject *)createChatMessage:(NSString *)content;

//生成自定义消息
- (QNIMMessageObject *)createCustomMessage:(NSString *)content;

//礼物消息
- (QNIMMessageObject *)createGiftMessage:(QNGiftModel *)giftModel number:(NSInteger)number extMsg:(NSString *)extMsg;

//点赞消息
- (QNIMMessageObject *)createLikeMessage:(NSString *)content;

//弹幕消息
- (QNIMMessageObject *)createDanmuMessage:(NSString *)content;

//踢麦信令
- (QNIMMessageObject *)createKickMessage:(NSString *)uid msg:(NSString *)msg;

//上麦信令
- (QNIMMessageObject *)createOnMicMessage;

//下麦信令
- (QNIMMessageObject *)createDownMicMessage;

//开关麦信令（音频）
- (QNIMMessageObject *)createMicStatusMessage:(BOOL)openAudio;

//开关麦信令（视频）
- (QNIMMessageObject *)createCameraStatusMessage:(BOOL)openVideo;

//禁麦信令（音频）
- (QNIMMessageObject *)createForbiddenAudio:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg;

//禁麦信令（视频）
- (QNIMMessageObject *)createForbiddenVideo:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg;

//邀请信令
- (QNIMMessageObject *)createInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId;

//取消邀请信令
- (QNIMMessageObject *)createCancelInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId;

//接受邀请信令
- (QNIMMessageObject *)createAcceptInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId;

//拒绝邀请信令
- (QNIMMessageObject *)createRejectInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId;

//开始pk信令
-(QNIMMessageObject *)createStartPKMessageWithReceiverId:(NSString *)receiverId receiveRoomId:(NSString *)receiveRoomId receiverIMId:(NSString *)receiverIMId relayId:(NSString *)relayId relayToken:(NSString *)relayToken ;

@end

NS_ASSUME_NONNULL_END
