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
//收到弹幕消息
- (void)onReceivedDamaku:(PubChatModel *)msg;
//收到点赞消息
- (void)onReceivedLikeMsg:(QNIMMessageObject *)msg;
//收到礼物消息
- (void)onreceivedGiftMsg:(QNIMMessageObject *)msg;

@end

@interface QNChatRoomService : QNLiveService

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
//禁言
//- (void)muteUser:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute;

@end

NS_ASSUME_NONNULL_END
