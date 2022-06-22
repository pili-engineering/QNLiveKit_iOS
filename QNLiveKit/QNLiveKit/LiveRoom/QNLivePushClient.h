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

- (void)onUserUnpublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID;

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

@property (nonatomic, strong) QNMicrophoneAudioTrack *localAudioTrack;
@property (nonatomic, strong) QNCameraVideoTrack *localVideoTrack;

@property (nonatomic, strong) NSMutableArray <QNRemoteVideoTrack *> *remoteCameraTracks;
@property (nonatomic, strong) NSMutableArray <QNRemoteAudioTrack *> *remoteAudioTracks;

+ (instancetype)createPushClient;
- (void)destroy;

/// 作为主播开始直播
- (void)startLive:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable roomInfo))callBack;
/// 作为主播停止直播
- (void)closeRoom:(NSString *)roomID;

// 作为观众加入直播
- (void)joinLive:(NSString *)token userData:(NSString *)userData;
// 作为观众离开直播
- (void)LeaveLive;

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

#pragma mark ---- 混流

//开始混流
- (void)beginMixStream:(QNMergeOption *)option;
//更新混流画布大小
- (void)updateMixStreamSize:(CGSize)size;
//设置某个用户的音频混流参数
- (void)updateUserAudioMixStreamingWithTrackId:(NSString *)trackId;
//设置某个用户的摄像头混流参数
- (void)updateUserVideoMixStreamingWithTrackId:(NSString *)trackId option:(CameraMergeOption *)option;
//删除某个摄像头混流
- (void)removeUserVideoMixStreamingWithTrackId:(NSString *)trackId;
//结束混流
- (void)stopMixStream;

@end

NS_ASSUME_NONNULL_END
