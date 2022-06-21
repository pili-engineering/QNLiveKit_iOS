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

@class QNCameraParams,QNMicrophoneParams,QNLiveRoomInfo,QNMergeOption,CameraMergeOption,QNRemoteAudioTrack,QRenderView;

@protocol QNPushClientListener <NSObject>

@optional

/// 房间连接状态
/// @param state 连接状态
- (void)onConnectionRoomStateChanged:(QNConnectionState)state;

// 远端用户发布音/视频
- (void)onUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID;

//远端用户首帧解码
- (void)userFirstVideoDidDecodeOfTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID;
//远端用户取消渲染
- (void)userdidDetachRenderTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID;

- (void)onUserUnpublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID;

- (void)didMediaRelayStateChanged:(NSString *)relayRoom state:(QNMediaRelayState)state;

- (void)didStartLiveStreaming:(NSString *)streamID;

//订阅成功
- (void)didSubscribedRemoteVideoTracks:(NSArray<QNRemoteVideoTrack *> *)videoTracks audioTracks:(NSArray<QNRemoteAudioTrack *> *)audioTracks ofUserID:(NSString *)userID;

// 有人离开rtc房间
- (void)onUserLeaveRTC:(NSString *)userID;

/// 房间状态
/// @param liveRoomStatus status
/// @param msg msg
- (void)onRoomStateChanged:(QNLiveRoomStatus)liveRoomStatus msg:(NSString *)msg;

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

@property (nonatomic, strong) QNMicrophoneAudioTrack *localAudioTrack;
@property (nonatomic, strong) QNCameraVideoTrack *localVideoTrack;

@property (nonatomic, strong) NSMutableArray <QNRemoteVideoTrack *> *remoteCameraTracks;
@property (nonatomic, strong) NSMutableArray <QNRemoteAudioTrack *> *remoteAudioTracks;

+ (instancetype)createPushClient;
- (void)destroy;

/// 主播开始直播
/// @param callBack 回调
- (void)startLive:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable roomInfo))callBack;

/// 停止直播
- (void)closeRoom:(NSString *)roomID;

- (void)joinLive:(NSString *)token userData:(NSString *)userData;
- (void)LeaveLive;

/// 启动视频采集
- (void)enableCamera:(nullable QNCameraParams *)cameraParams renderView:(nullable QRenderView *)renderView;
- (void)enableMicrophone:(nullable QNMicrophoneParams *)microphoneParams;

/// 切换摄像头
- (void)switchCamera;

/// 是否禁止本地摄像头推流
/// @param muted muted
- (void)muteCamera:(BOOL)muted;

/// 是否禁止本地麦克风推流
/// @param muted muted
- (void)muteMicrophone:(BOOL)muted;

/// 设置音频帧回调
/// @param listener listener
- (void)setAudioFrameListener:(id<QNLocalAudioTrackDelegate>)listener;

/// 设置视频帧回调
/// @param listener listener
- (void)setVideoFrameListener:(id<QNLocalVideoTrackDelegate>)listener;

- (void)beginMixStream:(QNMergeOption *)option;
- (void)publishCameraAndMicrophone;



//更新混流画布大小
- (void)updateMixStreamSize:(CGSize)size;

//设置某个用户的音频混流参数 （isNeed 是否需要混流音频）
- (void)updateUserAudioMergeOptions:(NSString *)uid trackId:(NSString *)trackId isNeed:(BOOL)isNeed;

//设置某个用户的摄像头混流参数
- (void)updateUserVideoMergeOptions:(NSString *)uid trackId:(NSString *)trackId option:(CameraMergeOption *)option;
- (void)removeUserVideoMergeOptions:(NSString *)uid trackId:(NSString *)trackId;

- (void)stopMixStream;

@end

NS_ASSUME_NONNULL_END
