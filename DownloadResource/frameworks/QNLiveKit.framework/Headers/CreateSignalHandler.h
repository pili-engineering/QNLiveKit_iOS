//
//  QNSendMsgTool.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//  消息创建器

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageObject,QGiftModel,QNLiveUser,QInvitationModel,QNPKSession,GoodsModel;

//快速创建消息/信令
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
- (QNIMMessageObject *)createInviteMessageWithInvitationName:(NSString *)invitationName receiveRoomId:(NSString *)receiveRoomId receiveUser:(nonnull QNLiveUser *)receiveUser;

//取消邀请信令
- (QNIMMessageObject *)createCancelInviteMessageWithInvitationName:(NSString *)invitationName receiveRoomId:(NSString *)receiveRoomId receiveUser:(nonnull QNLiveUser *)receiveUser;

//接受邀请信令
- (QNIMMessageObject *)createAcceptInviteMessageWithInvitationName:(NSString *)invitationName invitationModel:(QInvitationModel *)invitationModel;

//拒绝邀请信令
- (QNIMMessageObject *)createRejectInviteMessageWithInvitationName:(NSString *)invitationName invitationModel:(QInvitationModel *)invitationModel;

//开始pk信令
-(QNIMMessageObject *)createStartPKMessage:(QNPKSession *)pkSession singleMsg:(BOOL)singleMsg;

//结束pk信令 
- (QNIMMessageObject *)createStopPKMessage:(QNPKSession *)pkSession;

//切换讲解商品
- (QNIMMessageObject *)createExplainGoodMsg:(GoodsModel *)model;

//刷新商品
- (QNIMMessageObject *)createRefreshGoodMsg;

@end

NS_ASSUME_NONNULL_END
