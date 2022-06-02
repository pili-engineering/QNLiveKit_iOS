//
//  QNSendMsgTool.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//  消息创建器

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageObject,QNGiftModel;

@interface QNMessageCreater : NSObject

- (instancetype)initWithToId:(NSString *)toId;

//加入房间消息
- (QNIMMessageObject *)createJoinRoomMessage;

//离开房间消息
- (QNIMMessageObject *)createLeaveRoomMessage;

//聊天消息
- (QNIMMessageObject *)createChatMessage:(NSString *)content;

//弹幕消息
- (QNIMMessageObject *)createDanmuMessage:(NSString *)content;

//礼物消息
- (QNIMMessageObject *)createGiftMessage:(QNGiftModel *)giftModel number:(NSInteger)number extMsg:(NSString *)extMsg;

//点赞消息
- (QNIMMessageObject *)createHeartMessage:(NSInteger)count;

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

//踢麦信令
- (QNIMMessageObject *)createKickOutMicMessageWithUid:(NSString *)uid msg:(NSString *)msg;

//踢出房间信令
- (QNIMMessageObject *)createKickOutRoomMessage:(NSString *)uid msg:(NSString *)msg;

//邀请信令
- (QNIMMessageObject *)createInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId;

//取消邀请信令
- (QNIMMessageObject *)createCancelInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId;

//接受邀请信令
- (QNIMMessageObject *)createAcceptInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId;

//拒绝邀请信令
- (QNIMMessageObject *)createRejectInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId;


@end

NS_ASSUME_NONNULL_END
