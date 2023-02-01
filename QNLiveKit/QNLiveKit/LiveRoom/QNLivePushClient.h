//
//  QNLivePushClient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <QNLiveKit/QNLiveKit.h>
#import <QNRTCKit/QNRTCKit.h>
#import "QNLiveRoomClient.h"

NS_ASSUME_NONNULL_BEGIN

@class QNCameraParams,QNMicrophoneParams,QNLiveRoomInfo,QNMergeOption,CameraMergeOption,QNRemoteAudioTrack,QRenderView,QMixStreamManager;

@protocol QNPushClientListener <NSObject>

@optional

/// 房间连接状态
/// @param state 连接状态
- (void)onConnectionRoomStateChanged:(QNConnectionState)state;

// 远端用户发布音/视频
- (void)onUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID;

// 成功创建混流转推
- (void)didStartLiveStreaming:(NSString *)streamID;

// 有人离开rtc房间
- (void)onUserLeaveRTC:(NSString *)userID;

/// 摄像头状态回调
/// @param isOpen isOpen
- (void)onCameraStatusChange:(BOOL)isOpen;

/// 本地麦克风状态回调
/// @param isOpen isOpen
- (void)onMicrophoneStatusChange:(BOOL)isOpen;

@end

@interface QNLivePushClient : QNLiveRoomClient

@property (nonatomic, strong) QNRTCClient *rtcClient;

@property (nonatomic, weak) id <QNPushClientListener> pushClientListener;
//本地音频track
@property (nonatomic, strong) QNMicrophoneAudioTrack *localAudioTrack;
//本地视频track
@property (nonatomic, strong) QNCameraVideoTrack *localVideoTrack;

//是否使用了内置美颜功能
@property (nonatomic, assign) BOOL needBeauty;

//初始化
+ (instancetype)createPushClient;
//销毁
- (void)destroy;

// 主播开始直播
- (void)startLive:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable roomInfo))callBack;
// 主播停止直播
- (void)closeRoom;
// 主播暂时离开直播
- (void)leaveRoom;
#pragma mark ---- 推流
/// 启动视频采集
- (void)enableCamera:(nullable QNCameraParams *)cameraParams renderView:(nullable QRenderView *)renderView;
/// 切换摄像头
- (void)switchCamera;
/// 是否禁止本地摄像头推流
- (void)muteCamera:(BOOL)muted;
/// 是否禁止本地麦克风推流
- (void)muteMicrophone:(BOOL)muted;
/// 设置音频帧回调
- (void)setAudioFrameListener:(id<QNLocalAudioTrackDelegate>)listener;
/// 设置视频帧回调
- (void)setVideoFrameListener:(id<QNLocalVideoTrackDelegate>)listener;

#pragma mark ---- 获取混流器
- (QMixStreamManager *)getMixStreamManager;

@end

NS_ASSUME_NONNULL_END
