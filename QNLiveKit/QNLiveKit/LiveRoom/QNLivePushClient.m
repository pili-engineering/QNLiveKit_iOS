//
//  QNLivePushClient.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QNLivePushClient.h"

@interface QNLivePushClient ()<QNRTCClientDelegate>

@property (nonatomic, weak) id <QNPushClientListener> pushClientListener;

@property (nonatomic, strong) QNRTCClient *rtcClient;

@property (nonatomic, copy) NSString *token;
@end

@implementation QNLivePushClient

- (instancetype)initWithToken:(NSString *)token{
    if (self = [super init]) {
        self.token = token;
        [QNRTC configRTC:[QNRTCConfiguration defaultConfiguration]];
        self.rtcClient = [QNRTC createRTCClient];
        self.rtcClient.delegate = self;
    }
    return self;
}


//加入直播
- (void)joinLive {
    [self.rtcClient join:self.token];
}

/// 启动视频采集
- (void)enableCamera {
    [self.localVideoTrack startCapture];
    if ([self.pushClientListener respondsToSelector:@selector(onCameraStatusChange:)]) {
        [self.pushClientListener onCameraStatusChange:YES];
    }
}

/// 关闭视频采集
- (void)disableCamera {
    [self.localVideoTrack stopCapture];
    if ([self.pushClientListener respondsToSelector:@selector(onCameraStatusChange:)]) {
        [self.pushClientListener onCameraStatusChange:NO];
    }
}

//本地视频轨道参数
- (void)setCameraParams:(QNCameraParams *)params {
    CGSize videoEncodeSize = CGSizeMake(params.width, params.height);
    QNCameraVideoTrackConfig * cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:@"camera" bitrate:params.bitrate videoEncodeSize:videoEncodeSize];
    self.localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
    self.localVideoTrack.videoFrameRate = params.fps;
    self.localVideoTrack.previewMirrorFrontFacing = NO;
    [self.localVideoTrack startCapture];
    self.localVideoTrack.fillMode = QNVideoFillModePreserveAspectRatio;
}

//本地音频轨道参数
- (void)setMicrophoneParams:(QNMicrophoneParams *)params {
    [self.localAudioTrack setVolume:params.volume];
    self.localAudioTrack.tag = params.tag.length == 0 ? @"audio" : params.tag;
}

/// 切换摄像头
- (void)switchCamera {
    [self.localVideoTrack switchCamera];
}

/// 设置本地预览
- (void)setLocalPreView:(QNGLKView *)view {
    [self.localVideoTrack play:view];
}

/// 是否禁止本地摄像头推流
- (void)muteLocalCamera:(BOOL)muted {
    [self.localVideoTrack updateMute:muted];
    if ([self.pushClientListener respondsToSelector:@selector(onCameraStatusChange:)]) {
        [self.pushClientListener onCameraStatusChange:!muted];
    }
}

/// 是否禁止本地麦克风推流
- (void)muteLocalMicrophone:(BOOL)muted{
    [self.localAudioTrack updateMute:muted];
    if ([self.pushClientListener respondsToSelector:@selector(onMicrophoneStatusChange:)]) {
        [self.pushClientListener onMicrophoneStatusChange:!muted];
    }
}

//发布tracks
- (void)publishCameraAndMicrophone:(void (^)(BOOL, NSError * _Nonnull))callBack {
    [self.rtcClient publish:@[self.localAudioTrack,self.localVideoTrack] completeCallback:^(BOOL onPublished, NSError *error) {
        callBack(onPublished,error);
    }];
}

//取消发布tracks
- (void)unpublish:(NSArray<QNLocalTrack *> *)tracks {
    [self.rtcClient publish:tracks];
}

- (void)addPushClientListener:(id<QNPushClientListener>)listener {
    self.pushClientListener = listener;
}

- (void)addAudioFrameListener:(id<QNMicrophoneAudioTrackDataDelegate>)listener {
    self.localAudioTrack.audioDelegate = listener;
}

- (void)addVideoFrameListener:(id<QNCameraTrackVideoDataDelegate>)listener {
    self.localVideoTrack.videoDelegate = listener;
}

#pragma mark --------QNRTCClientDelegate

- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    if ([self.pushClientListener respondsToSelector:@selector(onConnectionStateChanged:)]) {
        [self.pushClientListener onConnectionStateChanged:state];
    }
}

//本地音频轨道默认参数
- (QNMicrophoneAudioTrack *)localAudioTrack {
    if (!_localAudioTrack) {
        _localAudioTrack = [QNRTC createMicrophoneAudioTrack];
        [_localAudioTrack setVolume:0.5];
        _localAudioTrack.tag =  @"audio";
    }
    return _localAudioTrack;
}

//本地视频轨道默认参数
- (QNCameraVideoTrack *)localVideoTrack {
    if (!_localVideoTrack) {
        CGSize videoEncodeSize = CGSizeMake(540, 960);
        QNCameraVideoTrackConfig * cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:@"camera" bitrate:400*1000 videoEncodeSize:videoEncodeSize];
        _localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
        _localVideoTrack.videoFrameRate = 15;
        _localVideoTrack.previewMirrorFrontFacing = NO;
        [_localVideoTrack startCapture];
    }
    return _localVideoTrack;
}

@end
