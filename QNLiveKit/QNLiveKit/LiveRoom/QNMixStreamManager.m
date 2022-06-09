//
//  QNMixStreamManager.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import "QNMixStreamManager.h"
#import "QNMergeOption.h"

@interface QNMixStreamManager ()

@property (nonatomic, copy) NSString *publishUrl;
@property (nonatomic, copy) NSString *streamID;
@property (nonatomic, strong)QNRTCClient *client;
//@property (nonatomic, strong)NSMutableArray<QNTranscodingLiveStreamingTrack *> *layouts;
@property (nonatomic, strong)QNDirectLiveStreamingConfig *directConfig;
@property (nonatomic, strong)QNTranscodingLiveStreamingConfig *mergeConfig;

@end

@implementation QNMixStreamManager

- (instancetype)initWithPushUrl:(NSString *)publishUrl client:(QNRTCClient *)client streamID:(NSString *)streamID {
    if (self = [super init]) {
        self.publishUrl = publishUrl;
        self.streamID = streamID;
        self.client = client;
    }
    return self;
}

//启动前台转推，默认实现推本地轨道
- (void)startForwardJob {
    [self.client startLiveStreamingWithDirect:self.directConfig];
}

//停止前台推流
- (void)stopForwardJob {
    [self.client stopLiveStreamingWithDirect:self.directConfig];
}

//开始混流转推
- (void)startMixStreamJob {
    [self.client startLiveStreamingWithTranscoding:self.mergeConfig];
}

//停止混流转推
- (void)stopMixStreamJob {
    [self.client stopLiveStreamingWithTranscoding:self.mergeConfig];
}

//设置混流参数
- (void)setMixParams:(QNMergeOption *)params {
    self.mergeConfig.width = params.width;
    self.mergeConfig.height = params.height;
    self.mergeConfig.bitrateBps = params.cameraMergeOption.mixBitrate;
    self.mergeConfig.background = params.backgroundInfo;
}

//设置某个用户的音频混流参数
- (void)updateUserAudioMergeOptions:(NSString *)uid trackId:(NSString *)trackId isNeed:(BOOL)isNeed {

    QNTranscodingLiveStreamingTrack *layout = [[QNTranscodingLiveStreamingTrack alloc] init];
    layout.trackId = trackId;
    if (isNeed) {
        [self.client setTranscodingLiveStreamingID:self.streamID withTracks:@[layout]];
    } else {
        [self.client removeTranscodingLiveStreamingID:self.streamID withTracks:@[layout]];
    }
            
}

//设置某个用户的摄像头混流参数
- (void)updateUserVideoMergeOptions:(NSString *)uid trackId:(NSString *)trackId option:(CameraMergeOption *)option {
    
    QNTranscodingLiveStreamingTrack *layout = [[QNTranscodingLiveStreamingTrack alloc] init];
    layout.trackId = trackId;
    layout.frame = option.frame;
    layout.zIndex = option.mZ;
    layout.fillMode= option.fillMode;
    [self.client setTranscodingLiveStreamingID:self.streamID withTracks:@[layout]];

}


- (QNDirectLiveStreamingConfig *)directConfig {
    if (!_directConfig) {
        _directConfig = [[QNDirectLiveStreamingConfig alloc]init];
        _directConfig.streamID = self.streamID;
        _directConfig.publishUrl = self.publishUrl;
        for (QNTrack *track in self.client.publishedTracks) {
            if (track.kind == QNTrackKindAudio) {
                _directConfig.audioTrack = track;
            } else {
                _directConfig.videoTrack = track;
            }
        }
    }
    return _directConfig;
}

- (QNTranscodingLiveStreamingConfig *)mergeConfig {
    if (!_mergeConfig) {
        _mergeConfig = [QNTranscodingLiveStreamingConfig defaultConfiguration];
        QNTranscodingLiveStreamingImage *bgInfo = [[QNTranscodingLiveStreamingImage alloc] init];
        bgInfo.frame = CGRectMake(0, 0, 414, 736);
        bgInfo.imageUrl = @"http://qrnlrydxa.hn-bkt.clouddn.com/am_room_bg.png";
        _mergeConfig.background = bgInfo;
        _mergeConfig.minBitrateBps = 1000*1000;
        _mergeConfig.maxBitrateBps = 1000*1000;
        _mergeConfig.width = 414;
        _mergeConfig.height = 736;
        _mergeConfig.fillMode = QNVideoFillModePreserveAspectRatioAndFill;
        _mergeConfig.publishUrl = self.publishUrl;
        _mergeConfig.streamID = self.streamID;
    }
    return _mergeConfig;
}

//- (NSMutableArray<QNTranscodingLiveStreamingTrack *> *)layouts {
//    if (!_layouts) {
//        _layouts = [NSMutableArray array];
//    }
//    return _layouts;
//}
@end
