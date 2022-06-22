//
//  QNLivePushClient.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QNLivePushClient.h"
#import "QMixStreamManager.h"
#import "QNLiveRoomInfo.h"
#import "QNMergeOption.h"
#import "QRenderView.h"
#import "QNLiveNetworkUtil.h"
#import "QNLiveUser.h"
#import "QNLiveRoomInfo.h"
#import "QNMicrophoneParams.h"
#import "QNCameraParams.h"

@interface QNLivePushClient ()<QNRTCClientDelegate>

@property (nonatomic, strong) QMixStreamManager *mixManager;

@property (nonatomic, strong) QNLiveRoomInfo *roomInfo;

@property (nonatomic, strong) QNMergeOption *option;

@property (nonatomic, assign) BOOL isMixing;

@end

@implementation QNLivePushClient

- (void)destroy {
    [QNRTC deinit];
}

//创建主播端
+ (instancetype)createPushClient {
    static QNLivePushClient *pushClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        pushClient = [[QNLivePushClient alloc]init];
        [QNRTC initRTC:[QNRTCConfiguration defaultConfiguration]];
        QNClientConfig *config = [[QNClientConfig alloc]initWithMode:QNClientModeLive];
        pushClient.rtcClient = [QNRTC createRTCClient:config];
        [pushClient.rtcClient setClientRole:QNClientRoleBroadcaster completeCallback:nil];
        pushClient.rtcClient.delegate = pushClient;
    });
    return pushClient;
}

/// 主播开始直播
/// @param callBack 回调
- (void)startLive:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo * _Nullable))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client/live/room/%@",roomID];
    [QNLiveNetworkUtil putRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];
        self.roomInfo = model;
        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomJoined:)]) {
            [self.roomLifeCycleListener onRoomJoined:model];
        }
        [self.rtcClient join:model.room_token];
        callBack(model);
        
        } failure:^(NSError * _Nonnull error) {
            callBack(nil);
        }];
}

/// 停止直播
- (void)closeRoom:(NSString *)roomID{
    
    NSString *action = [NSString stringWithFormat:@"client//live/room/%@",roomID];
    [QNLiveNetworkUtil deleteRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        
        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomClose)]) {
            [self.roomLifeCycleListener onRoomClose];
        }
        
        } failure:^(NSError * _Nonnull error) {
        }];
    [self LeaveLive];
}

//加入直播
- (void)joinLive:(NSString *)token userData:(NSString *)userData{
    [self.rtcClient join:token userData:userData];
}

- (void)LeaveLive {
    [self.rtcClient leave];
}

/// 启动视频采集
- (void)enableCamera:(nullable QNCameraParams *)cameraParams renderView:(nullable QRenderView *)renderView {
    if (cameraParams.width) {
        CGSize videoEncodeSize = CGSizeMake(cameraParams.width?:720, cameraParams.height?:1280);
        QNVideoEncoderConfig *config = [[QNVideoEncoderConfig alloc] initWithBitrate:cameraParams.bitrate?:400*1000 videoEncodeSize:videoEncodeSize videoFrameRate:cameraParams.fps?:15];
        QNCameraVideoTrackConfig * cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:cameraParams.tag?:@"camera" config:config multiStreamEnable:NO];
        self.localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
        self.localVideoTrack.videoFrameRate = cameraParams.fps;
    }

    [self.localVideoTrack startCapture];
    [self.localVideoTrack play:renderView];
    
    if ([self.pushClientListener respondsToSelector:@selector(onCameraStatusChange:)]) {
        [self.pushClientListener onCameraStatusChange:YES];
    }
}


/// 切换摄像头
- (void)switchCamera {
    [self.localVideoTrack switchCamera];
}

/// 是否禁止本地摄像头推流
- (void)muteCamera:(BOOL)muted {
    [self.localVideoTrack updateMute:muted];
    if ([self.pushClientListener respondsToSelector:@selector(onCameraStatusChange:)]) {
        [self.pushClientListener onCameraStatusChange:!muted];
    }
}

/// 是否禁止本地麦克风推流
- (void)muteMicrophone:(BOOL)muted{
    [self.localAudioTrack updateMute:muted];
    if ([self.pushClientListener respondsToSelector:@selector(onMicrophoneStatusChange:)]) {
        [self.pushClientListener onMicrophoneStatusChange:!muted];
    }
}

- (void)stopMixStream {
    [self.mixManager stopMixStreamJob];
}

//发布tracks
- (void)publishCameraAndMicrophone {
    
    __weak typeof(self)weakSelf = self;

    [self.rtcClient publish:@[self.localAudioTrack,self.localVideoTrack] completeCallback:^(BOOL onPublished, NSError *error) {
        
    }];
}

/// 设置音频帧回调
/// @param listener listener
- (void)setAudioFrameListener:(id<QNLocalAudioTrackDelegate>)listener {
    self.localAudioTrack.delegate = listener;
}

/// 设置视频帧回调
/// @param listener listener
- (void)setVideoFrameListener:(id<QNLocalVideoTrackDelegate>)listener {
    self.localVideoTrack.delegate = listener;
}

- (void)beginMixStream:(QNMergeOption *)option{
    self.option = option;
    [self.mixManager startMixStreamJob];
    
}

#pragma mark --------QNRTCClientDelegate
//成功创建转推/合流转推任务的回调
- (void)RTCClient:(QNRTCClient *)client didStartLiveStreaming:(NSString *)streamID {
    
    if ([self.pushClientListener respondsToSelector:@selector(didStartLiveStreaming:)]) {
        [self.pushClientListener didStartLiveStreaming:streamID];
    }
        
    
}

- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    
    if (state == QNConnectionStateConnected) {
        [self publishCameraAndMicrophone];
    }
    
    if ([self.pushClientListener respondsToSelector:@selector(onConnectionRoomStateChanged:)]) {
            [self.pushClientListener onConnectionRoomStateChanged:state];
    }
    
}

- (void)RTCClient:(QNRTCClient *)client didUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID  {
    
    [self.rtcClient subscribe:tracks];
    
    if ([self.pushClientListener respondsToSelector:@selector(onUserPublishTracks:ofUserID:)]) {
        [self.pushClientListener onUserPublishTracks:tracks ofUserID:userID];
    }
    
//    if (self.option) {
//        
//        for (QNRemoteTrack *track in tracks) {
//            if (track.kind == QNTrackKindAudio) {
//                [self.mixManager updateUserAudioMixStreamingWithTrackId:track.trackID];
//            } else {
//                CameraMergeOption *option = [CameraMergeOption new];
//                option.frame = CGRectMake(720-184-30, 200, 184, 184);
//                option.mZ = 1;
//                [self.mixManager updateUserVideoMixStreamingWithTrackId:track.trackID option:option];
//            }
//        }
//        
//    }
}

- (void)RTCClient:(QNRTCClient *)client didUserUnpublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    if ([self.pushClientListener respondsToSelector:@selector(onUserUnpublishTracks:ofUserID:)]) {
        [self.pushClientListener onUserUnpublishTracks:tracks ofUserID:userID];
    }
}

- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID {
    if ([self.pushClientListener respondsToSelector:@selector(onUserLeaveRTC:)]) {
        [self.pushClientListener onUserLeaveRTC:userID];
    }
}

//设置某个用户的音频混流参数 （isNeed 是否需要混流音频）
- (void)updateUserAudioMixStreamingWithTrackId:(NSString *)trackId {
    [self.mixManager updateUserAudioMixStreamingWithTrackId:trackId];
}

//设置某个用户的摄像头混流参数
- (void)updateUserVideoMixStreamingWithTrackId:(NSString *)trackId option:(CameraMergeOption *)option {
    [self.mixManager updateUserVideoMixStreamingWithTrackId:trackId option:option];
}

- (void)removeUserVideoMixStreamingWithTrackId:(NSString *)trackId {
    [self.mixManager removeUserVideoMixStreamingWithTrackId:trackId];
}

//本地音频轨道默认参数
- (QNMicrophoneAudioTrack *)localAudioTrack {
    if (!_localAudioTrack) {
        _localAudioTrack = [QNRTC createMicrophoneAudioTrack];
        [_localAudioTrack setVolume:0.5];
    }
    return _localAudioTrack;
}

- (void)updateMixStreamSize:(CGSize)size {
    [self.mixManager stopMixStreamJob];
    
    self.option.width = size.width;
    self.option.height = size.height;
    [_mixManager setMixParams:self.option];
    [self.mixManager startMixStreamJob];
}

//本地视频轨道默认参数
- (QNCameraVideoTrack *)localVideoTrack {
    if (!_localVideoTrack) {
        CGSize videoEncodeSize = CGSizeMake(720, 1280);        
        QNVideoEncoderConfig *config = [[QNVideoEncoderConfig alloc] initWithBitrate:400*1000 videoEncodeSize:videoEncodeSize videoFrameRate:15];
        QNCameraVideoTrackConfig * cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:@"camera" config:config multiStreamEnable:NO];
        _localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
    }
    return _localVideoTrack;
}

- (QMixStreamManager *)mixManager {
    if (!_mixManager) {
        _mixManager = [[QMixStreamManager alloc]initWithPushUrl:self.roomInfo.push_url client:self.rtcClient streamID:self.roomInfo.live_id];
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
