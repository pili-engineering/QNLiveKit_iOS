//
//  QPKService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveService.h"
#import "QNPKExtendsModel.h"
#import "QNPKInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^QNPKSuccessBlock)(QNPKSession * _Nullable pkSession);
typedef void (^QNPKFailureBlock)(NSError *error);
typedef void (^QNPKTimeoutBlock)(void);

@class QNPKSession, QInvitationModel;

#pragma mark - PKServiceListener

@protocol PKServiceListener <NSObject>

@optional
//收到PK邀请
- (void)onReceivePKInvitation:(QInvitationModel *)model;
//PK邀请被拒绝
- (void)onReceivePKInvitationReject:(QInvitationModel *)model;
//PK邀请被接受
- (void)onReceivePKInvitationAccept:(QNPKSession *)pkSession;
//PK开始
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession;
//pk结束
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession;
//pk扩展字段有变化
- (void)onReceivePKExtendsChange:(QNPKExtendsModel *)model;

@end


#pragma mark - QPKService

@interface QPKService : QNLiveService

@property (nonatomic, weak) id<PKServiceListener> delegate;

//申请pk
- (void)applyPK:(NSString *)receiveRoomId receiveUser:(QNLiveUser *)receiveUser;
//接受PK申请
- (void)acceptPK:(QInvitationModel *)invitationModel;
//拒绝PK申请
- (void)rejectPK:(QInvitationModel *)invitationModel;
//结束pk
- (void)stopPK:(nullable void (^)(void))success failure:(nullable QNPKFailureBlock)failure;
//开始PK
- (void)startPK:(QNPKSession *)pkSession timeoutInterval:(double)timeoutInterval success:(nullable QNPKSuccessBlock)success failure:(nullable QNPKFailureBlock)failure timeout:(nullable QNPKTimeoutBlock)timeout;

@end

NS_ASSUME_NONNULL_END
