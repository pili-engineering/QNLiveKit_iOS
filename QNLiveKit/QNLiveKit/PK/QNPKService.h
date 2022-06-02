//
//  QNPKService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveService.h"

NS_ASSUME_NONNULL_BEGIN

@class QNPKSession,PKMixStreamAdapter,QNPKInvitationHandler;
//麦位监听
@protocol PKServiceListener <NSObject>

/// 用户进入房间 初始化返回当前房间的正在的pk
- (void)onInitPKer:(QNPKSession *)pkSession;
//开始pk
- (void)onStart:(QNPKSession *)pkSession;
//结束pk
- (void)onStop:(QNPKSession *)pkSession;
//收对方的流超时
- (void)onWaitPeerTimeOut:(QNPKSession *)pkSession;
//扩展自定义字段更新
- (void)onPKExtensionUpdate:(QNPKSession *)pkSession extension:(NSString *)extension;

@end

@interface QNPKService : QNLiveService

//设置混流适配器
- (void)setPKMixStreamAdapter:(PKMixStreamAdapter *)adapter;

//添加监听
- (void)addPKServiceListener:(id<PKServiceListener>)listener;

//移除监听
- (void)removePKServiceListener:(id<PKServiceListener>)listener;

//开始pk  timeoutTimestamp 等待对方流超时时间时间戳 毫秒
- (void)start:(long long)timeoutTimestamp receiverRoomId:(NSString *)receiverRoomId receiverUid:(NSString *)receiverUid extensions:(NSString *)extensions callBack:(void (^)(QNPKSession *pkSession))callBack;

//同意跨房申请
- (void)agreePK:(NSString *)relayID callBack:(void (^)(QNPKSession *pkSession))callBack;

//结束pk
- (void)stop:(void (^)(void))callBack;

//设置某人的连麦视频预览
- (void)setPeerAnchorPreView:(QNVideoView *)preview uid:(NSString *)uid;

//获得pk邀请处理器
- (QNPKInvitationHandler *)getPKInvitationHandler;
@end

NS_ASSUME_NONNULL_END
