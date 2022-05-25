//
//  QNLinkMicService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <UIKit/UIKit.h>
#import "QNLiveService.h"
#import "QNMicLinker.h"
#import "QNLinkMicInvitationHandler.h"
#import "QNAudienceMicLinker.h"
#import "QNAnchorHostMicLinker.h"
#import "QNAnchorForwardMicLinker.h"

NS_ASSUME_NONNULL_BEGIN

//麦位监听
@protocol MicLinkerListener <NSObject>

/// 观众初始化进入直播间 回调给观众当前有哪些人在连麦
- (void)onInitLinkers:(NSArray <QNMicLinker *> *)linkers;

/// 有人上麦
- (void)onUserJoinLink:(QNMicLinker *)micLinker;

/// 有人下麦
- (void)onUserLeave:(QNMicLinker *)micLinker;

/// 有人麦克风变化
- (void)onUserMicrophoneStatusChange:(QNMicLinker *)micLinker;

/// 有人摄像头状态变化
- (void)onUserCameraStatusChange:(QNMicLinker *)micLinker;

/// 有人被踢
- (void)onUserBeKick:(QNMicLinker *)micLinker msg:(NSString *)msg;

/// 有人扩展字段变化
- (void)onUserExtension:(QNMicLinker *)micLinker extension:(NSString *)extension;

@end

//连麦服务
@interface QNLinkMicService : QNLiveService

@property (nonatomic, weak)id<MicLinkerListener> delegate;

//获取当前房间所有连麦用户
- (NSArray <QNMicLinker *> *)getAllLinker;

//设置某人的连麦视频预览
- (void)setUserPreview:(QNVideoView *)preview uid:(NSString *)uid;

//踢人
- (void)kickOutUser:(NSString *)uid msg:(NSString *)msg callBack:(void (^)(void))callBack;

//更新扩展字段
- (void)updateExtension:(NSString *)extension micLinker:(QNMicLinker *)micLinker callBack:(void (^)(void))callBack;

//添加连麦监听
- (void)addMicLinkerListener:(id<MicLinkerListener>)listener;

//移除连麦监听
- (void)removeMicLinkerListener:(id<MicLinkerListener>)listener;

//获取连麦邀请处理器
- (QNLinkMicInvitationHandler *)getLinkMicInvitationHandler;

//观众向主播连麦
- (QNAudienceMicLinker *)getAudienceMicLinker;

//主播处理自己被连麦
- (QNAnchorHostMicLinker *)getAnchorHostMicLinker;

//主播向主播的跨房连麦
- (QNAnchorForwardMicLinker *)getAnchorForwardMicLinker;
@end

NS_ASSUME_NONNULL_END
