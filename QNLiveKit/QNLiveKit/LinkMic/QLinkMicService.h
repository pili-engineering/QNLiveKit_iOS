//
//  QLinkMicService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <UIKit/UIKit.h>
#import "QNLiveService.h"
#import "QNMicLinker.h"
#import "QNLiveRoomInfo.h"
#import "QInvitationModel.h"
#import "QNLiveUser.h"
#import "LinkOptionModel.h"

NS_ASSUME_NONNULL_BEGIN

//麦位监听
@protocol MicLinkerListener <NSObject>
@optional
/// 有人上麦
- (void)onUserJoinLink:(QNMicLinker *)micLinker;

/// 有人下麦
- (void)onUserLeaveLink:(QNMicLinker *)micLinker;

/// 有人麦克风变化
- (void)onUserMicrophoneStatusChange:(NSString *)uid mute:(BOOL)mute;

/// 有人摄像头状态变化
- (void)onUserCameraStatusChange:(NSString *)uid mute:(BOOL)mute;

/// 有人被踢
- (void)onUserBeKick:(LinkOptionModel *)micLinker;

//收到连麦邀请
- (void)onReceiveLinkInvitation:(QInvitationModel *)model;

//连麦邀请被接受
- (void)onReceiveLinkInvitationAccept:(QInvitationModel *)model;

//连麦邀请被拒绝
- (void)onReceiveLinkInvitationReject:(QInvitationModel *)model;

@end

//连麦服务
@interface QLinkMicService : QNLiveService

@property (nonatomic, weak)id<MicLinkerListener> micLinkerListener;

@property (nonatomic, strong) NSMutableArray<QNMicLinker *> *linkMicList;


- (instancetype)initWithRoomInfo:(QNLiveRoomInfo *)roomInfo;
//获取当前房间所有连麦用户
- (void)getAllLinker:(void (^)(NSArray <QNMicLinker *> *list))callBack;

//上麦
- (void)onMic:(BOOL)mic camera:(BOOL)camera extends:(nullable NSDictionary *)extends;

//下麦
- (void)downMic;

//踢人
- (void)kickOutUser:(NSString *)uid msg:(nullable NSString *)msg callBack:(nullable void (^)(QNMicLinker * _Nullable))callBack ;

//开关麦 type:mic/camera  flag:on/off
- (void)updateMicStatusType:(NSString *)type flag:(BOOL)flag;

//申请连麦
- (void)ApplyLink:(QNLiveUser *)receiveUser;

//接受连麦
- (void)AcceptLink:(QInvitationModel *)invitationModel;

//拒绝连麦
- (void)RejectLink:(QInvitationModel *)invitationModel;

// 是否在连麦中
- (BOOL)isMicLinked:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END
