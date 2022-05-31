//
//  QNLivePushClient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <QNLiveKit/QNLiveKit.h>
#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNCameraParams,QNMicrophoneParams;

@protocol QNPushClientListener <NSObject>

@optional

/// 推流连接状态
/// @param state 连接状态
- (void)onConnectionStateChanged:(QNConnectionState)state;

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

@interface QNLivePushClient : NSObject

@property (nonatomic, strong) QNMicrophoneAudioTrack *localAudioTrack;
@property (nonatomic, strong) QNCameraVideoTrack *localVideoTrack;

@property (nonatomic, strong) QNRemoteVideoTrack *remoteCameraTrack;
@property (nonatomic, strong) QNRemoteAudioTrack *remoteAudioTrack;

- (instancetype)initWithToken:(NSString *)token;

//加入直播
- (void)joinLive;

/// 启动视频采集
- (void)enableCamera;

/// 关闭视频采集
- (void)disableCamera;

//本地视频轨道参数
- (void)setCameraParams:(QNCameraParams *)params;

//本地音频轨道参数
- (void)setMicrophoneParams:(QNMicrophoneParams *)params;

/// 切换摄像头
- (void)switchCamera;

/// 设置本地预览
/// @param view view
- (void)setLocalPreView:(QNGLKView *)view;

/// 是否禁止本地摄像头推流
/// @param muted muted
- (void)muteLocalCamera:(BOOL)muted;

/// 是否禁止本地麦克风推流
/// @param muted muted
- (void)muteLocalMicrophone:(BOOL)muted;

//发布音频和视频tracks
- (void)publishCameraAndMicrophone:(void (^)(BOOL onPublished, NSError *error))callBack;

//取消发布tracks
- (void)unpublish:(NSArray<QNLocalTrack *> *)tracks;

/// 设置连接状态回调
/// @param listener 回调
- (void)addPushClientListener:(id<QNPushClientListener>)listener;

/// 设置音频帧回调
/// @param listener listener
- (void)addAudioFrameListener:(id<QNMicrophoneAudioTrackDataDelegate>)listener;

/// 设置视频帧回调
/// @param listener listener
- (void)addVideoFrameListener:(id<QNCameraTrackVideoDataDelegate>)listener;

@end

NS_ASSUME_NONNULL_END
