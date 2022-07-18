//
//  QPKService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveService.h"

NS_ASSUME_NONNULL_BEGIN

@class QNPKSession,QInvitationModel;

@protocol PKServiceListener <NSObject>
@optional
//收到PK邀请
- (void)onReceivePKInvitation:(QInvitationModel *)model;
//PK邀请被接受
- (void)onReceivePKInvitationAccept:(QNPKSession *)model;
//PK邀请被拒绝
- (void)onReceivePKInvitationReject:(QInvitationModel *)model;
//PK开始
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession;
//pk结束
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession;

@end

@interface QPKService : QNLiveService

@property (nonatomic, weak)id<PKServiceListener> delegate;

//申请pk
- (void)applyPK:(NSString *)receiveRoomId receiveUser:(QNLiveUser *)receiveUser;

//接受PK申请
- (void)AcceptPK:(QInvitationModel *)invitationModel;

//拒绝PK申请
- (void)sendPKReject:(QInvitationModel *)invitationModel;

//结束pk
- (void)stopPK:(nullable void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
