//
//  QNChatRoomService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveService.h"


NS_ASSUME_NONNULL_BEGIN

@class PubChatModel,QNLiveUser,QNPKSession,QInvitationModel,QNIMMessageObject,QNIMError;
//聊天室监听
@protocol QNChatRoomServiceListener <NSObject>
@optional
//有人加入聊天室
- (void)onUserJoin:(QNLiveUser *)user message:(QNIMMessageObject *)message;
//有人离开聊天室
- (void)onUserLeave:(QNLiveUser *)user message:(QNIMMessageObject *)message;
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
- (void)onReceiveLinkInvitation:(QInvitationModel *)model;
//连麦邀请被接受
- (void)onReceiveLinkInvitationAccept:(QInvitationModel *)model;
//连麦邀请被拒绝
- (void)onReceiveLinkInvitationReject:(QInvitationModel *)model;

//收到PK邀请
- (void)onReceivePKInvitation:(QInvitationModel *)model;
//PK邀请被接受
- (void)onReceivePKInvitationAccept:(QInvitationModel *)model;
//PK邀请被拒绝
- (void)onReceivePKInvitationReject:(QInvitationModel *)model;
//收到开始跨房PK信令
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession;
//收到停止跨房PK信令
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession;

@end

@interface QNChatRoomService : QNLiveService

//初始化
- (instancetype)initWithGroupId:(NSString *)groupId roomId:(NSString *)roomId;
//添加聊天监听
- (void)addChatServiceListener:(id<QNChatRoomServiceListener>)listener;
//移除聊天监听
- (void)removeChatServiceListener;

#pragma mark ----状态消息
//发公聊消息
- (void)sendPubChatMsg:(NSString *)msg callBack:(void (^)(QNIMMessageObject *msg))callBack;
//发进房消息
- (void)sendWelComeMsg:(void (^)(QNIMMessageObject *msg))callBack;
//发离开消息
- (void)sendLeaveMsg;
//踢人
- (void)kickUser:(NSString *)msg memberId:(NSString *)memberId;
//禁言
- (void)muteUser:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute;

#pragma mark ----连麦消息
//发送连麦申请
- (void)sendLinkMicInvitation:(QNLiveUser *)receiveUser;
//接受连麦申请
- (void)sendLinkMicAccept:(QInvitationModel *)invitationModel;
//拒绝连麦申请
- (void)sendLinkMicReject:(QInvitationModel *)invitationModel;

#pragma mark ----PK消息
//发送PK申请
- (void)sendPKInvitation:(NSString *)receiveRoomId receiveUser:(QNLiveUser *)receiveUser;
//接受PK申请
- (void)sendPKAccept:(QInvitationModel *)invitationModel;
//拒绝PK申请
- (void)sendPKReject:(QInvitationModel *)invitationModel;
//开始pk信令 singleMsg：是否只发给对方主播
-(void)createStartPKMessage:(QNPKSession *)pkSession singleMsg:(BOOL)singleMsg ;
//结束pk信令
- (void)createStopPKMessage:(QNPKSession *)pkSession;

@end

NS_ASSUME_NONNULL_END
