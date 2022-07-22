//
//  QMixStreamManager.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMergeOption,CameraMergeOption;
//混流器
@interface QMixStreamManager : NSObject

- (instancetype)initWithPushUrl:(NSString *)publishUrl client:(QNRTCClient *)client streamID:(NSString *)streamID;
//启动前台转推，默认实现推本地轨道
- (void)startForwardJob;
//停止前台推流
- (void)stopForwardJob;
//开始混流转推
- (void)startMixStreamJob;
//停止混流转推
- (void)stopMixStreamJob;
//设置混流参数
- (void)setMixParams:(QNMergeOption *)params;
//更新混流画布大小
- (void)updateMixStreamSize:(CGSize)size;
//设置某个音频track混流
- (void)updateUserAudioMixStreamingWithTrackId:(NSString *)trackId;
//设置某个视频track混流
- (void)updateUserVideoMixStreamingWithTrackId:(NSString *)trackId option:(CameraMergeOption *)option;
//删除某条track的混流
- (void)removeUserVideoMixStreamingWithTrackId:(NSString *)trackId;

@end

NS_ASSUME_NONNULL_END
