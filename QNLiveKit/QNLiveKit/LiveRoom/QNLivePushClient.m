//
//  QNLivePushClient.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QNLivePushClient.h"
#import "QNMixStreamManager.h"
#import "QNLiveRoomInfo.h"
#import "QNMergeOption.h"
#import "RemoteUserVIew.h"

@interface QNLivePushClient ()<QNRTCClientDelegate>

@property (nonatomic, weak) id <QNPushClientListener> pushClientListener;

@property (nonatomic, strong) QNMixStreamManager *mixManager;

@property (nonatomic, strong) QNLiveRoomInfo *roomInfo;

@property (nonatomic, strong) QNMergeOption *option;

@property (nonatomic, assign) BOOL isMixing;

@end

@implementation QNLivePushClient

- (void)deinit {
    [QNRTC deinit];
}

- (instancetype)initWithRoomInfo:(QNLiveRoomInfo *)roomInfo {
    if (self = [super init]) {
        self.roomInfo = roomInfo;
        [QNRTC initRTC:[QNRTCConfiguration defaultConfiguration]];
        QNClientConfig *config = [[QNClientConfig alloc]initWithMode:QNClientModeLive];
        self.rtcClient = [QNRTC createRTCClient:config];
        self.rtcClient.delegate = self;
    }
    return self;    
}

- (instancetype)init {
    if (self = [super init]) {
        [QNRTC initRTC:[QNRTCConfiguration defaultConfiguration]];
        QNClientConfig *config = [[QNClientConfig alloc]initWithMode:QNClientModeLive];
        self.rtcClient = [QNRTC createRTCClient:config];
        self.rtcClient.delegate = self;
    }
    return self;
}

//加入直播
- (void)joinLive:(NSString *)token {
    
    [self.rtcClient setClientRole:QNClientRoleBroadcaster completeCallback:nil];
    [self.rtcClient join:token];
}

- (void)LeaveLive {
    [self.rtcClient leave];
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
    
    QNVideoEncoderConfig *config = [[QNVideoEncoderConfig alloc] initWithBitrate:params.bitrate videoEncodeSize:videoEncodeSize videoFrameRate:params.fps];
    QNCameraVideoTrackConfig * cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:params.tag config:config multiStreamEnable:NO];
    self.localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
    self.localVideoTrack.videoFrameRate = params.fps;
    self.localVideoTrack.previewMirrorFrontFacing = NO;
    [self.localVideoTrack startCapture];
//    self.localVideoTrack.fillMode = QNVideoFillModePreserveAspectRatio;
}

//本地音频轨道参数
- (void)setMicrophoneParams:(QNMicrophoneParams *)params {
    [self.localAudioTrack setVolume:params.volume];
}

/// 切换摄像头
- (void)switchCamera {
    [self.localVideoTrack switchCamera];
}

/// 设置本地预览
- (void)setLocalPreView:(RemoteUserVIew *)view {
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

- (void)stopMixStream {
    [self.mixManager stopMixStreamJob];
}

//发布tracks
- (void)publishCameraAndMicrophone:(void (^)(BOOL, NSError * _Nonnull))callBack {
    
    __weak typeof(self)weakSelf = self;

    [self.rtcClient publish:@[self.localAudioTrack,self.localVideoTrack] completeCallback:^(BOOL onPublished, NSError *error) {
        if (weakSelf.option) {
            [weakSelf.mixManager updateUserAudioMergeOptions:QN_User_id trackId:self.localAudioTrack.trackID isNeed:YES];
            CameraMergeOption *option = [CameraMergeOption new];
            option.frame = CGRectMake(0, 0, 720, 1280);
            option.mZ = 0;
            [self.mixManager updateUserVideoMergeOptions:QN_User_id trackId:self.localVideoTrack.trackID option:option];
        }
        callBack(onPublished,error);
    }];
}

//取消发布tracks
- (void)unpublish:(NSArray<QNLocalTrack *> *)tracks {
    [self.rtcClient unpublish:tracks];
}

- (void)addPushClientListener:(id<QNPushClientListener>)listener {
    self.pushClientListener = listener;
}

//- (void)addAudioFrameListener:(id<QNMicrophoneAudioTrackDataDelegate>)listener {
//    self.localAudioTrack.audioDelegate = listener;
//}

//- (void)addVideoFrameListener:(id<QNCameraTrackVideoDataDelegate>)listener {
//    self.localVideoTrack.videoDelegate = listener;
//}

- (void)beginMixStream:(QNMergeOption *)option {
    self.option = option;
    [self.mixManager startMixStreamJob];
}

#pragma mark --------QNRTCClientDelegate
//成功创建转推/合流转推任务的回调
- (void)RTCClient:(QNRTCClient *)client didStartLiveStreaming:(NSString *)streamID {
    
}
//停止转推/合流转推任务的回调
- (void)RTCClient:(QNRTCClient *)client didStopLiveStreaming:(NSString *)streamID {
    
}
//合流转推出错的回调
- (void)RTCClient:(QNRTCClient *)client didErrorLiveStreaming:(NSString *)streamID errorInfo:(QNLiveStreamingErrorInfo *)errorInfo {
    
}


- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    
    if ([self.pushClientListener respondsToSelector:@selector(onConnectionRoomStateChanged:)]) {
            [self.pushClientListener onConnectionRoomStateChanged:state];
        }
       
}

- (void)RTCClient:(QNRTCClient *)client didSubscribedRemoteVideoTracks:(NSArray<QNRemoteVideoTrack *> *)videoTracks audioTracks:(NSArray<QNRemoteAudioTrack *> *)audioTracks ofUserID:(NSString *)userID {
    
    if ([self.pushClientListener respondsToSelector:@selector(didSubscribedRemoteVideoTracks:audioTracks:ofUserID:)]) {
        [self.pushClientListener didSubscribedRemoteVideoTracks:videoTracks audioTracks:audioTracks ofUserID:userID];
    }
}

- (void)RTCClient:(QNRTCClient *)client didUserUnpublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    if ([self.pushClientListener respondsToSelector:@selector(onUserUnpublishTracks:ofUserID:)]) {
        [self.pushClientListener onUserUnpublishTracks:tracks ofUserID:userID];
    }
}

- (void)RTCClient:(QNRTCClient *)client didMediaRelayStateChanged:(NSString *)relayRoom state:(QNMediaRelayState)state {
    if ([self.pushClientListener respondsToSelector:@selector(didMediaRelayStateChanged:state:)]) {
        [self.pushClientListener didMediaRelayStateChanged:relayRoom state:state];
    }
}

- (void)RTCClient:(QNRTCClient *)client didUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID  {
    
    [self.rtcClient subscribe:tracks];
    
    if ([self.pushClientListener respondsToSelector:@selector(onUserPublishTracks:ofUserID:)]) {
        [self.pushClientListener onUserPublishTracks:tracks ofUserID:userID];
    }
    
    if (self.option) {
        
        for (QNRemoteTrack *track in tracks) {
            if (track.kind == QNTrackKindAudio) {
                [self.mixManager updateUserAudioMergeOptions:userID trackId:track.trackID isNeed:YES];
            } else {
                CameraMergeOption *option = [CameraMergeOption new];
                option.frame = CGRectMake(720-184-30, 200, 184, 184);
                option.mZ = 1;
                [self.mixManager updateUserVideoMergeOptions:userID trackId:track.trackID option:option];
            }
        }
        
    }
}

- (void)RTCClient:(QNRTCClient *)client firstVideoDidDecodeOfTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID {
    [self.rtcClient subscribe:@[videoTrack]];
    if ([self.pushClientListener respondsToSelector:@selector(userFirstVideoDidDecodeOfTrack:remoteUserID:)]) {
        [self.pushClientListener userFirstVideoDidDecodeOfTrack:videoTrack remoteUserID:userID];
    }
}

- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID {
    if ([self.pushClientListener respondsToSelector:@selector(onUserLeaveRTC:)]) {
        [self.pushClientListener onUserLeaveRTC:userID];
    }
}

//设置某个用户的音频混流参数 （isNeed 是否需要混流音频）
- (void)updateUserAudioMergeOptions:(NSString *)uid trackId:(NSString *)trackId isNeed:(BOOL)isNeed {
    [self.mixManager updateUserAudioMergeOptions:uid trackId:trackId isNeed:isNeed];
}

//设置某个用户的摄像头混流参数
- (void)updateUserVideoMergeOptions:(NSString *)uid trackId:(NSString *)trackId option:(CameraMergeOption *)option {
    [self.mixManager updateUserVideoMergeOptions:uid trackId:trackId option:option];
}

- (void)removeUserVideoMergeOptions:(NSString *)uid trackId:(NSString *)trackId {
    [self.mixManager removeUserVideoMergeOptions:uid trackId:trackId];
}

//本地音频轨道默认参数
- (QNMicrophoneAudioTrack *)localAudioTrack {
    if (!_localAudioTrack) {
        _localAudioTrack = [QNRTC createMicrophoneAudioTrack];
        [_localAudioTrack setVolume:0.5];
    }
    return _localAudioTrack;
}

//本地视频轨道默认参数
- (QNCameraVideoTrack *)localVideoTrack {
    if (!_localVideoTrack) {
        CGSize videoEncodeSize = CGSizeMake(720, 1280);
        
        QNVideoEncoderConfig *config = [[QNVideoEncoderConfig alloc] initWithBitrate:400*1000 videoEncodeSize:videoEncodeSize videoFrameRate:15];
        QNCameraVideoTrackConfig * cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:@"camera" config:config multiStreamEnable:NO];
        
        _localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
        _localVideoTrack.videoFrameRate = 15;
        _localVideoTrack.previewMirrorFrontFacing = NO;
        [_localVideoTrack startCapture];
    }
    return _localVideoTrack;
}

- (QNMixStreamManager *)mixManager {
    if (!_mixManager) {
        _mixManager = [[QNMixStreamManager alloc]initWithPushUrl:self.roomInfo.push_url client:self.rtcClient streamID:self.roomInfo.live_id];
        [_mixManager setMixParams:self.option];
    }
    return _mixManager;
}

- (NSMutableArray<QNRemoteVideoTrack *> *)remoteCameraTracks {
    if(!_remoteCameraTracks) {
        _remoteCameraTracks = [NSMutableArray array];
    }
    return _remoteCameraTracks;
}

- (NSMutableArray<QNRemoteVideoTrack *> *)remoteAudioTracks {
    if(!_remoteAudioTracks) {
        _remoteAudioTracks = [NSMutableArray array];
    }
    return _remoteAudioTracks;
}
@end
