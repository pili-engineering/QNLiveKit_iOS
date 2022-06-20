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
#import "QRenderView.h"
#import "QNLiveNetworkUtil.h"
#import "QNLiveUser.h"
#import "QNLiveRoomInfo.h"
#import "QNMicrophoneParams.h"
#import "QNCameraParams.h"

@interface QNLivePushClient ()<QNRTCClientDelegate>

@property (nonatomic, strong) QNMixStreamManager *mixManager;

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


- (void)enableMicrophone:(nullable QNMicrophoneParams *)microphoneParams {
    [self.localAudioTrack setVolume:microphoneParams.volume ?: 0.5];
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
    
        [self.mixManager updateUserAudioMergeOptions:QN_User_id trackId:self.localAudioTrack.trackID isNeed:YES];
        CameraMergeOption *option = [CameraMergeOption new];
        option.frame = CGRectMake(0, 0, 720, 1280);
        option.mZ = 0;
        [self.mixManager updateUserVideoMergeOptions:QN_User_id trackId:self.localVideoTrack.trackID option:option];
    
}
//停止转推/合流转推任务的回调
- (void)RTCClient:(QNRTCClient *)client didStopLiveStreaming:(NSString *)streamID {
    
}
//合流转推出错的回调
- (void)RTCClient:(QNRTCClient *)client didErrorLiveStreaming:(NSString *)streamID errorInfo:(QNLiveStreamingErrorInfo *)errorInfo {
    
}


- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    
    if (state == QNConnectionStateConnected) {
        [self publishCameraAndMicrophone];
    }
    
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
