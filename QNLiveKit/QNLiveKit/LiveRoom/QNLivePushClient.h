//
//  QNLivePushClient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveRoomClient.h"
#import "QNPushClientListener.h"
#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNCameraParams,QNMicrophoneParams;

@protocol QNPushClientListener <NSObject>

/// 推流连接状态
/// @param state 连接状态
/// @param msg msg
- (void)onConnectionStateChanged:(QNRoomConnectionState)state msg:(NSString *)msg;

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

/// 创建实例
+ (instancetype)createLivePushClient;

/// 启动视频采集
/// @param cameraParams 采集视频参数
- (void)enableCamera:(QNCameraParams *)cameraParams;

/// 启动音频采集
/// @param microphoneParams 采集音频参数
- (void)enableMicrophone:(QNMicrophoneParams *)microphoneParams;

/// 设置连接状态回调
/// @param pushClientListener 回调
- (void)setPushClientListener:(id<QNPushClientListener>)pushClientListener;

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

/// 设置音频帧回调
/// @param listener listener
- (void)setVideoFrameListener:(id<QNMicrophoneAudioTrackDataDelegate>)listener;

/// 设置视频帧回调
/// @param listener listener
- (void)setVideoFrameListener:(id<QNCameraTrackVideoDataDelegate>)listener;

@end

NS_ASSUME_NONNULL_END
