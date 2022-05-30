//
//  QNLivePushClient.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QNLivePushClient.h"

@interface QNLivePushClient ()<QNPushClientListener,QNRTCClientDelegate>

@property (nonatomic, weak) id <QNPushClientListener> pushClientListener;

@property (nonatomic, strong) QNRTCClient *rtcClient;

@end

@implementation QNLivePushClient

static QNLivePushClient *client;

+(instancetype)createLivePushClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        client = [[QNLivePushClient alloc]init];
        [QNRTC configRTC:[QNRTCConfiguration defaultConfiguration]];
        client.rtcClient = [QNRTC createRTCClient];
        client.rtcClient.delegate = client;
    });
    return client;
}

//加入直播
- (void)joinLive:(NSString *)token {
    [self.rtcClient join:token];
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
    [self.localVideoTrack updateMute:mute];
    if ([self.pushClientListener respondsToSelector:@selector(onCameraStatusChange:)]) {
        [self.pushClientListener onCameraStatusChange:!muted];
    }
}

/// 是否禁止本地麦克风推流
- (void)muteLocalMicrophone:(BOOL)muted{
    [self.localAudioTrack updateMute:mute];
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
- (void)unpublish:(NSArray<QNTrack *> *)tracks {
    [self.rtcClient publish:tracks];
}

- (void)setPushClientListener:(id<QNPushClientListener>)pushClientListener {
    self.pushClientListener = pushClientListener;
}

- (void)setAudioFrameListener:(id<QNMicrophoneAudioTrackDataDelegate>)listener {
    self.localAudioTrack.audioDelegate = listener;
}

- (void)setVideoFrameListener:(id<QNCameraTrackVideoDataDelegate>)listener {
    self.localVideoTrack.videoDelegate = self;
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
        [_localVideoTrack play:self.preview];
    }
    return _localVideoTrack;
}

//本地录制轨道默认参数
- (QNScreenVideoTrack *)localScreenTrack {
    if (!_localScreenTrack) {
        if (![QNScreenVideoTrack isScreenRecorderAvailable]) {
//            [MBProgressHUD showText:@"当前设备不支持屏幕录制"];
            return nil;
        }
        CGSize videoEncodeSize = CGSizeMake(540, 960);
        QNScreenVideoTrackConfig * screenConfig = [[QNScreenVideoTrackConfig alloc] initWithSourceTag:@"screen" bitrate:400*1000 videoEncodeSize:videoEncodeSize];
        _localScreenTrack = [QNRTC createScreenVideoTrackWithConfig:screenConfig];
        _localScreenTrack.screenRecorderFrameRate = 15;
        _localScreenTrack.screenDelegate = self;

    }
    return _localScreenTrack;
}

@end
