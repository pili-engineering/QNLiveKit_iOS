//
//  QNPKInvitationHandler.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <Foundation/Foundation.h>

@class LinkInvitation;

NS_ASSUME_NONNULL_BEGIN

//pk邀请监听
@protocol PKInvitationHandlerListener <NSObject>
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

@interface QNPKInvitationHandler : NSObject

- (void)addPKInvitationHandlerListener:(id<PKInvitationHandlerListener>)listener;

- (void)removePKInvitationHandlerListener:(id<PKInvitationHandlerListener>)listener;

//邀请/申请pk
- (void)apply:(long long)expiration receiverRoomId:(NSString *)receiverRoomId receiverUid:(NSString *)receiverUid extensions:(NSString *)extensions callBack:(void (^)(LinkInvitation *invitation))callBack;
//取消申请
- (void)cancelApply:(NSString *)invitationId callBack:(void (^)(void))callBack;
//接受pk
- (void)accept:(NSString *)invitationId extensions:(NSString *)extensions callBack:(void (^)(void))callBack;
//拒绝pk
- (void)reject:(NSString *)invitationId extensions:(NSString *)extensions callBack:(void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
