//
//  QNLivePushClient.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QLiveNetworkUtil.h"
#import "QMixStreamManager.h"
#import "QNCameraParams.h"
#import "QNLivePushClient.h"
#import "QNLiveRoomInfo.h"
#import "QNLiveUser.h"
#import "QNMergeOption.h"
#import "QNMicrophoneParams.h"
#import "QRenderView.h"
#import "QRooms.h"

@interface QNLivePushClient () <QNRTCClientDelegate, QNRoomsListener>

@property (nonatomic, strong) QMixStreamManager *mixManager;

@property (nonatomic, weak) id<QNRoomsListener> roomsListener;

@property (nonatomic, strong) QNMergeOption *option;

@property (nonatomic, assign) BOOL isMixing;

@end

@implementation QNLivePushClient

- (void)destroy {
    [QNRTC deinit];
}

// 创建主播端
+ (instancetype)createPushClient {
    static QNLivePushClient *pushClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      pushClient = [[QNLivePushClient alloc] init];
      [QNRTC initRTC:[QNRTCConfiguration defaultConfiguration]];
      QNClientConfig *config = [[QNClientConfig alloc] initWithMode:QNClientModeLive];
      pushClient.rtcClient = [QNRTC createRTCClient:config];
      [pushClient.rtcClient setClientRole:QNClientRoleBroadcaster completeCallback:nil];
      pushClient.rtcClient.delegate = pushClient;

      QLIVELogInfo(@"init");
    });
    return pushClient;
}

// 主播开始直播
- (void)startLive:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable))callBack {
    NSString *action = [NSString stringWithFormat:@"client/live/room/%@", roomID];
    [QLiveNetworkUtil putRequestWithAction:action
        params:@{}
        success:^(NSDictionary *_Nonnull responseData) {
          QNLiveRoomInfo *model = [QNLiveRoomInfo mj_objectWithKeyValues:responseData];
          self.roomInfo = model;

          [QLiveNetworkUtil postRequestWithAction:[NSString stringWithFormat:@"client/live/room/user/%@", roomID]
              params:@{}
              success:^(NSDictionary *_Nonnull responseData) {
              }
              failure:^(NSError *_Nonnull error){
              }];

          self.mixManager = [[QMixStreamManager alloc] initWithPushUrl:self.roomInfo.push_url client:self.rtcClient streamID:self.roomInfo.live_id];
          if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomJoined:)]) {
              [self.roomLifeCycleListener onRoomJoined:model];
          }
          [self.rtcClient join:model.room_token];
          callBack(model);
          QLIVELogInfo(@"join RTC success roomID %@", roomID);
        }
        failure:^(NSError *_Nonnull error) {
          callBack(nil);
        }];
}

// 主播停止直播
- (void)closeRoom {
    NSString *action = [NSString stringWithFormat:@"client/live/room/%@", self.roomInfo.live_id];
    [QLiveNetworkUtil deleteRequestWithAction:action
                                       params:@{}
                                      success:^(NSDictionary *_Nonnull responseData) {
                                        if ([self.roomLifeCycleListener respondsToSelector:@selector(onRoomClose:)]) {
                                            [self.roomLifeCycleListener onRoomClose:self.roomInfo];
                                        }

                                        if ([[QLive getRooms].roomsListener respondsToSelector:@selector(onRoomClose:)]) {
                                            [[QLive getRooms].roomsListener onRoomClose:self.roomInfo];
                                        }
                                      }
                                      failure:^(NSError *_Nonnull error){
                                      }];

    // leave RTC
    [self.localVideoTrack play:nil];
    [self.localVideoTrack stopCapture];
    [self.rtcClient leave];
    QLIVELogInfo(@"close room");
}

// 主播暂时离开
- (void)leaveRoom {
    NSString *action = [NSString stringWithFormat:@"client/live/room/user/%@", self.roomInfo.live_id];
    [QLiveNetworkUtil deleteRequestWithAction:action
                                       params:nil
                                      success:^(NSDictionary *_Nonnull responseData) {

                                      }
                                      failure:^(NSError *_Nonnull error){
                                      }];

    // leave RTC
    [self.localVideoTrack play:nil];
    [self.localVideoTrack stopCapture];
    [self.rtcClient leave];
}

/// 启动视频采集
- (void)enableCamera:(nullable QNCameraParams *)cameraParams renderView:(nullable QRenderView *)renderView {
    if (cameraParams.width) {
        CGSize videoEncodeSize = CGSizeMake(cameraParams.width ?: 720, cameraParams.height ?: 1280);
        QNVideoEncoderConfig *config = [[QNVideoEncoderConfig alloc] initWithBitrate:cameraParams.bitrate ?: 1500 * 1000 videoEncodeSize:videoEncodeSize videoFrameRate:cameraParams.fps ?: 15];
        QNCameraVideoTrackConfig *cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:cameraParams.tag ?: @"camera" config:config multiStreamEnable:NO];
        self.localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
        self.localVideoTrack.videoFrameRate = cameraParams.fps;
    }

    [self.localVideoTrack play:renderView];
    [self.localVideoTrack startCapture];

    if ([self.pushClientListener respondsToSelector:@selector(onCameraStatusChange:)]) {
        [self.pushClientListener onCameraStatusChange:YES];
    }
    QLIVELogInfo(@"start localVideoTrack");
}

/// 切换摄像头
- (void)switchCamera {
    [self.localVideoTrack switchCamera];
    QLIVELogInfo(@"localVideoTrack switchCamera");
}

/// 是否禁止本地摄像头推流
- (void)muteCamera:(BOOL)muted {
    [self.localVideoTrack updateMute:muted];
    if ([self.pushClientListener respondsToSelector:@selector(onCameraStatusChange:)]) {
        [self.pushClientListener onCameraStatusChange:!muted];
    }
    QLIVELogInfo(@"muteCamera (%d)",muted);
}

/// 是否禁止本地麦克风推流
- (void)muteMicrophone:(BOOL)muted {
    [self.localAudioTrack updateMute:muted];
    if ([self.pushClientListener respondsToSelector:@selector(onMicrophoneStatusChange:)]) {
        [self.pushClientListener onMicrophoneStatusChange:!muted];
    }
    QLIVELogInfo(@"muteMicrophone (%d)",muted);
}

- (void)stopMixStream {
    [self.mixManager stopMixStreamJob];
    QLIVELogInfo(@"stopMixStream");
}

// 发布tracks
- (void)publishCameraAndMicrophone {
    [self.rtcClient publish:@[ self.localAudioTrack, self.localVideoTrack ]
           completeCallback:^(BOOL onPublished, NSError *error) {
             if (error) {
                 QLIVELogInfo(@"publish error");
             } else {
                 QLIVELogInfo(@"publish succss");
             }
           }];
}

/// 设置音频帧回调
/// @param listener listener
- (void)setAudioFrameListener:(id<QNLocalAudioTrackDelegate>)listener {
    self.localAudioTrack.delegate = listener;
    QLIVELogInfo(@"setAudioFrameListener");
}

/// 设置视频帧回调
/// @param listener listener
- (void)setVideoFrameListener:(id<QNLocalVideoTrackDelegate>)listener {
    self.localVideoTrack.delegate = listener;
    QLIVELogInfo(@"setVideoFrameListener");
}

#pragma mark--------QNRTCClientDelegate

// 成功创建转推/合流转推任务
- (void)RTCClient:(QNRTCClient *)client didStartLiveStreaming:(NSString *)streamID {
    QLIVELogInfo(@"RTCClient didStartLiveStreaming");
    if (self.mixManager) {
        [self.mixManager updateUserAudioMixStreamingWithTrackId:[QLive createPusherClient].localAudioTrack.trackID];
        CameraMergeOption *option = [CameraMergeOption new];
        option.frame = CGRectMake(0, 0, 720, 1280);
        option.mZ = 0;
        [self.mixManager updateUserVideoMixStreamingWithTrackId:[QLive createPusherClient].localVideoTrack.trackID option:option];
    }

    if ([self.pushClientListener respondsToSelector:@selector(didStartLiveStreaming:)]) {
        [self.pushClientListener didStartLiveStreaming:streamID];
    }
}

// 房间连接状态
- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    QLIVELogInfo(@"RTCClient didConnectionStateChanged state (%d)",(int)state);
    if (state == QNConnectionStateConnected) {
        [self publishCameraAndMicrophone];
        if (self.mixManager) {
            [self.mixManager startMixStreamJob];
        }
    }

    if ([self.pushClientListener respondsToSelector:@selector(onConnectionRoomStateChanged:)]) {
        [self.pushClientListener onConnectionRoomStateChanged:state];
    }
}

// 远端发布track
- (void)RTCClient:(QNRTCClient *)client didUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    QLIVELogInfo(@"RTCClient didUserPublishTracks userID (%@)",userID);
    if (self.mixManager) {
        for (QNRemoteTrack *track in tracks) {
            if (track.kind == QNTrackKindAudio) {
                [self.mixManager updateUserAudioMixStreamingWithTrackId:track.trackID];
            }
        }
    }
    if ([self.pushClientListener respondsToSelector:@selector(onUserPublishTracks:ofUserID:)]) {
        [self.pushClientListener onUserPublishTracks:tracks ofUserID:userID];
    }
}

// 远端取消发布track
- (void)RTCClient:(QNRTCClient *)client didUserUnpublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    QLIVELogInfo(@"RTCClient didUserUnpublishTracks userID (%@)",userID);
    if (self.mixManager) {
        for (QNRemoteTrack *track in tracks) {
            [self.mixManager removeUserVideoMixStreamingWithTrackId:track.trackID];
        }
        [self.mixManager updateMixStreamSize:CGSizeMake(720, 1280)];
    }
}

- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID {
    QLIVELogInfo(@"RTCClient didLeaveOfUserID userID (%@)",userID);
    if ([self.pushClientListener respondsToSelector:@selector(onUserLeaveRTC:)]) {
        [self.pushClientListener onUserLeaveRTC:userID];
    }
}

// 本地音频轨道默认参数
- (QNMicrophoneAudioTrack *)localAudioTrack {
    if (!_localAudioTrack) {
        _localAudioTrack = [QNRTC createMicrophoneAudioTrack];
        [_localAudioTrack setVolume:0.5];
    }
    return _localAudioTrack;
}

// 本地视频轨道默认参数
- (QNCameraVideoTrack *)localVideoTrack {
    if (!_localVideoTrack) {
        CGSize videoEncodeSize = CGSizeMake(720, 1280);
        QNVideoEncoderConfig *config = [[QNVideoEncoderConfig alloc] initWithBitrate:1500 * 1000 videoEncodeSize:videoEncodeSize videoFrameRate:15];
        QNCameraVideoTrackConfig *cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:@"camera" config:config multiStreamEnable:NO];
        _localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
        //        _localVideoTrack.previewMirrorFrontFacing = NO;
        [_localVideoTrack setBeautifyModeOn:YES];
    }
    return _localVideoTrack;
}

- (QMixStreamManager *)getMixStreamManager {
    return self.mixManager;
}

@end
