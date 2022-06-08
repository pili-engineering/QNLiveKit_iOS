//
//  QNAudienceMicLinker.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveTypeDefines.h"
#import <PLPlayerKit/PLPlayerKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNCameraParams,QNMicrophoneParams;
//监听
@protocol LinkMicListener <NSObject>

// 连麦模式连接状态  连接成功后 连麦器会主动禁用推流器 改用rtc
//- (void)onConnectionStateChanged:(QNRoomConnectionState)state;
//本地角色变化
- (void)lonLocalRoleChange:(BOOL)isLinker;

@end

//观众连麦器
@interface QNAudienceMicLinker : NSObject

//添加连麦监听
- (void)addLinkMicListener:(id<LinkMicListener>)listener;

//移除连麦监听
- (void)removeLinkMicListener:(id<LinkMicListener>)listener;

//开始上麦
- (void)startLink:(QNCameraParams *)cameraParams microphoneParams:(QNMicrophoneParams *)microphoneParams extensions:(NSString *)extensions callBack:(void (^)(void))callBack;

//我是不是麦上用户
- (void)isLinked:(BOOL)isLinked;

//结束连麦
- (void)stopLink;

/// 切换摄像头
- (void)switchCamera;

- (void)muteLocalVideo:(BOOL)muted;

- (void)muteLocalAudio:(BOOL)muted;

- (void)setAudioFrameListener:(id<QNMicrophoneAudioTrackDataDelegate>)listener;

- (void)setVideoFrameListener:(id<QNCameraTrackVideoDataDelegate>)listener;
//绑定原来的拉流预览  连麦后 会禁用原来的拉流预览
- (void)attachPullPlayer:(PLPlayer *)player;
@end

NS_ASSUME_NONNULL_END
