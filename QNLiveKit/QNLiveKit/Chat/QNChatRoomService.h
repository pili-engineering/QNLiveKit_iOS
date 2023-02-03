//
//  QNChatRoomService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveService.h"


NS_ASSUME_NONNULL_BEGIN

@class PubChatModel,QNLiveUser,QNPKSession,QInvitationModel,QNIMMessageObject,QNIMError,QNIMGroupBannedMember,QNIMGroupMember;
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
//私聊消息
- (void)sendCustomC2CMsg:(NSString *)msg memberID:(NSString *)memberID callBack:(void (^)(QNIMMessageObject *msg))callBack;
// 自定义群聊
- (void)sendCustomGroupMsg:(NSString *)msg callBack:(void (^)(QNIMMessageObject *msg))callBack;

// 踢人
- (void)kickUserMsg:(NSString *)msg memberID:(NSString *)memberID callBack:(void(^)(QNIMError *error))aCompletionBlock;

//禁言
- (void)muteUserMsg:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute callBack:(void(^)(QNIMError *error))aCompletionBlock;

// 禁言列表
- (void)getBannedMembersCompletion:(void(^)(NSArray<QNIMGroupBannedMember *> *bannedMemberList,
                                        QNIMError *error))aCompletionBlock;

//@param-isBlock:是否拉黑    @param-memberID:成员im ID    @param-callBack:回调
- (void)blockUserMemberId:(NSString *)memberId isBlock:(BOOL)isBlock callBack:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 获取黑名单
 **/
- (void)getBlockListForceRefresh:(BOOL)forceRefresh
                     completion:(void(^)(NSArray<QNIMGroupMember *> *groupMember,QNIMError *error))aCompletionBlock;

/**
  添加管理员
 */
- (void)addAdminsWithAdmins:(NSArray<NSNumber *> *)admins
          message:(NSString *)message
                  completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
  移除管理员
 */
- (void)removeAdminsWithAdmins:(NSArray<NSNumber *> *)admins
          message:(NSString *)message
                  completion:(void(^)(QNIMError *error))aCompletionBlock;

@end

NS_ASSUME_NONNULL_END
