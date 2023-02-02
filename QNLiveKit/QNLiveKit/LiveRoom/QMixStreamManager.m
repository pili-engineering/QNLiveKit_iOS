//
//  QMixStreamManager.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import "QMixStreamManager.h"
#import "QNMergeOption.h"

@interface QMixStreamManager ()

@property (nonatomic, copy) NSString *publishUrl;
@property (nonatomic, copy) NSString *streamID;
@property (nonatomic, strong)QNRTCClient *client;
//@property (nonatomic, strong)NSMutableArray<QNTranscodingLiveStreamingTrack *> *layouts;
@property (nonatomic, strong)QNDirectLiveStreamingConfig *directConfig;
@property (nonatomic, strong)QNTranscodingLiveStreamingConfig *mergeConfig;

@end

@implementation QMixStreamManager

- (instancetype)initWithPushUrl:(NSString *)publishUrl client:(QNRTCClient *)client streamID:(NSString *)streamID {
    if (self = [super init]) {
        self.publishUrl = publishUrl;
        self.streamID = streamID;
        self.client = client;
    }
    return self;
}

//启动前台转推，默认实现推本地轨道
- (void)startForwardJob{
    [self.client startLiveStreamingWithDirect:self.directConfig];
}

//停止前台推流
- (void)stopForwardJob{
    [self.client stopLiveStreamingWithDirect:self.directConfig];
}

//开始混流转推
- (void)startMixStreamJob {
    static int serialnum = 0;
    serialnum ++;
    if ([self.publishUrl containsString:@"?"]) {
        self.mergeConfig.publishUrl = [NSString stringWithFormat:@"%@&serialnum=%d",self.publishUrl,serialnum];
    }else{
        self.mergeConfig.publishUrl = [NSString stringWithFormat:@"%@?serialnum=%d",self.publishUrl,serialnum];
    }
    QLIVELogInfo(@"MixStream startMixStreamJob url(%@)",self.mergeConfig.publishUrl);
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
}

//更新混流画布大小
- (void)updateMixStreamSize:(CGSize)size {
    [self stopMixStreamJob];
    QNMergeOption *option = [[QNMergeOption alloc]init];
    option.width = size.width;
    option.height = size.height;
    [self setMixParams:option];
    [self startMixStreamJob];
}

//设置某个用户的音频混流参数
- (void)updateUserAudioMixStreamingWithTrackId:(NSString *)trackId {
    QNTranscodingLiveStreamingTrack *layout = [[QNTranscodingLiveStreamingTrack alloc] init];
    layout.trackID = trackId;    
    [self.client setTranscodingLiveStreamingID:self.streamID withTracks:@[layout]];
                
}

//移除用户的混流
- (void)removeUserVideoMixStreamingWithTrackId:(NSString *)trackId {
    QNTranscodingLiveStreamingTrack *layout = [[QNTranscodingLiveStreamingTrack alloc] init];
    layout.trackID = trackId;
    [self.client removeTranscodingLiveStreamingID:self.streamID withTracks:@[layout]];
}

//设置某个用户的摄像头混流参数
- (void)updateUserVideoMixStreamingWithTrackId:(NSString *)trackId option:(CameraMergeOption *)option {
    
    QNTranscodingLiveStreamingTrack *layout = [[QNTranscodingLiveStreamingTrack alloc] init];
    layout.trackID = trackId;
    layout.frame = option.frame;
    layout.zOrder = option.mZ;
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
                _directConfig.audioTrack = (QNLocalAudioTrack *)track;
            } else {
                _directConfig.videoTrack = (QNLocalVideoTrack *)track;
            }
        }
    }
    return _directConfig;
}

- (QNTranscodingLiveStreamingConfig *)mergeConfig {
    if (!_mergeConfig) {
        _mergeConfig = [QNTranscodingLiveStreamingConfig defaultConfiguration];
        _mergeConfig.minBitrateBps = 1000*1000;
        _mergeConfig.maxBitrateBps = 1000*1000;
        _mergeConfig.width = 720;
        _mergeConfig.height = 1280;
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
