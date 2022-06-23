//
//  QNLinkMicInvitationHandler.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LinkInvitation;

//邀请监听
@protocol InvitationHandlerListener <NSObject>
//邀请已发送
- (void)onReceivedApply:(LinkInvitation *)invitation;
//邀请已取消
- (void)onApplyCanceled:(LinkInvitation *)invitation;
//邀请超时
- (void)onApplyTimeOut:(LinkInvitation *)invitation;
//邀请被接受
- (void)onAccept:(LinkInvitation *)invitation;
//邀请被拒绝
- (void)onReject:(LinkInvitation *)invitation;

@end

@interface QNLinkMicInvitationHandler : NSObject

- (void)addInvitationHandlerLister:(id<InvitationHandlerListener>)listener;

- (void)removeInvitationHandlerLister:(id<InvitationHandlerListener>)listener;
//邀请/申请连麦
- (void)apply:(long long)expiration receiverRoomId:(NSString *)receiverRoomId receiverUid:(NSString *)receiverUid extensions:(NSString *)extensions callBack:(void (^)(LinkInvitation *invitation))callBack;
//取消申请
- (void)cancelApply:(NSString *)invitationId callBack:(void (^)(void))callBack;
//接受连麦
- (void)accept:(NSString *)invitationId extensions:(NSString *)extensions callBack:(void (^)(void))callBack;
//拒绝连麦
- (void)reject:(NSString *)invitationId extensions:(NSString *)extensions callBack:(void (^)(void))callBack;
@end

NS_ASSUME_NONNULL_END
