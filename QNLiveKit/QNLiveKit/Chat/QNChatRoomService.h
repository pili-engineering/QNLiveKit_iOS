//
//  QNChatRoomService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveService.h"
#import <QNIMSDK/QNIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class PubChatModel,QNLiveUser,QNPKSession,QNInvitationModel;
//聊天室监听
@protocol QNChatRoomServiceListener <NSObject>
@optional
//有人加入聊天室
- (void)onUserJoin:(QNLiveUser *)user message:(QNIMMessageObject *)message;
//有人离开聊天室
- (void)onUserLeave:(QNLiveUser *)user message:(QNIMMessageObject *)message;
//收到c2c消息
- (void)onReceivedC2CMsg:(NSString *)msg fromId:(NSString *)fromId toId:(NSString *)toId message:(QNIMMessageObject *)message;
//收到公聊消息
- (void)onReceivedPuChatMsg:(PubChatModel *)msg message:(QNIMMessageObject *)message;
//收到点赞消息
- (void)onReceivedLikeMsgFrom:(QNLiveUser *)sendUser;
//收到弹幕消息
- (void)onReceivedDamaku:(PubChatModel *)msg;
//有人被踢
- (void)onUserBeKicked:(NSString *)uid msg:(NSString *)msg;
//有人上麦
- (void)onReceivedOnMic:(QNMicLinker *)linker;
//有人下麦
- (void)onReceivedDownMic:(QNMicLinker *)linker;
//有人开关音频
- (void)onReceivedAudioMute:(BOOL)mute user:(NSString *)uid;
//有人开关视频
- (void)onReceivedVideoMute:(BOOL)mute user:(NSString *)uid;
//收到被禁音频的消息
- (void)onReceivedAudioBeForbidden:(BOOL)forbidden user:(NSString *)uid;
//收到被禁视频的消息
- (void)onReceivedVideoBeForbidden:(BOOL)forbidden user:(NSString *)uid;
//有人被禁言
- (void)onUserBeMuted:(BOOL)isMuted memberId:(NSString *)memberId duration:(long long)duration;
//新增了管理员
- (void)onAdminAdd:(NSString *)memberId;
//移除了管理员
- (void)onAdminRemoved:(NSString *)memberId reason:(NSString *)reason;

//收到连麦邀请
- (void)onReceiveLinkInvitation:(QNInvitationModel *)model;
//连麦邀请被接受
- (void)onReceiveLinkInvitationAccept:(QNInvitationModel *)model;
//连麦邀请被拒绝
- (void)onReceiveLinkInvitationReject:(QNInvitationModel *)model;

//收到PK邀请
- (void)onReceivePKInvitation:(QNInvitationModel *)model;
//PK邀请被接受
- (void)onReceivePKInvitationAccept:(QNInvitationModel *)model;
//PK邀请被拒绝
- (void)onReceivePKInvitationReject:(QNInvitationModel *)model;

//收到开始跨房信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession;
//收到停止跨房信令
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession;
- (void)messageStatus:(QNIMMessageObject *)message error:(QNIMError *)error;

@end

@interface QNChatRoomService : QNLiveService

//初始化
- (instancetype)initWithGroupId:(NSString *)groupId roomId:(NSString *)roomId ;

@property (nonatomic, weak)id<QNChatRoomServiceListener> chatRoomListener;

//添加聊天监听
- (void)addChatServiceListener:(id<QNChatRoomServiceListener>)listener;

//移除聊天监听
- (void)removeChatServiceListener:(id<QNChatRoomServiceListener>)listener;

//发c2c消息
- (void)sendCustomC2CMsg:(QNIMMessageObject *)msg memberId:(NSString *)memberId;
//发群消息
- (void)sendPubChatMsg:(NSString *)msg callBack:(void (^)(QNIMMessageObject *msg))callBack;
- (void)sendWelComeMsg:(void (^)(QNIMMessageObject *msg))callBack;
- (void)sendLeaveMsg:(void (^)(QNIMMessageObject *msg))callBack;

- (void)sendOnMicMsg;
- (void)sendDownMicMsg;
//发送连麦申请
- (void)sendLinkMicInvitation:(QNLiveUser *)receiveUser;
//接受连麦申请
- (void)sendLinkMicAccept:(QNInvitationModel *)invitationModel;
//拒绝连麦申请
- (void)sendLinkMicReject:(QNInvitationModel *)invitationModel;
//发送PK申请
- (void)sendPKInvitation:(NSString *)receiveRoomId receiveUser:(QNLiveUser *)receiveUser;
//接受PK申请
- (void)sendPKAccept:(QNInvitationModel *)invitationModel;
//拒绝PK申请
- (void)sendPKReject:(QNInvitationModel *)invitationModel;

//开始pk信令
-(void)createStartPKMessage:(QNPKSession *)pkSession ;

//结束pk信令
- (void)createStopPKMessage:(QNPKSession *)pkSession receiveUser:(nonnull QNLiveUser *)receiveUser;
//踢人
- (void)kickUser:(NSString *)msg memberId:(NSString *)memberId;
//禁言
- (void)muteUser:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute;
//添加管理员
- (void)addAdmin:(NSString *)memberId callBack:(void (^)(void))callBack;
//移除管理员
- (void)removeAdmin:(NSString *)msg memberId:(NSString *)memberId callBack:(void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
