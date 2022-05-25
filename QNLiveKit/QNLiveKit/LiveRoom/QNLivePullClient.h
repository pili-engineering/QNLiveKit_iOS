//
//  QNLivePullClient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveRoomClient.h"
#import "QNPullClientListener.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "QNLiveTypeDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QNPullClientListener <NSObject>

- (void)onRoomStatusChange:(QNLiveRoomStatus)liveRoomStatus msg:(NSString *)msg;

@end

@interface QNLivePullClient : QNLiveRoomClient

/// 创建实例
+ (instancetype)createLivePullClient;

/// 拉流监听
/// @param listener listener
- (void)setPullClientListener:(id<QNPullClientListener>)listener;

/// 绑定播放器
/// @param player description
- (void)setPullPreview:(PLPlayer *)player;

/// 获取播放器
- (PLPlayer *)getPullPreview;

@end

NS_ASSUME_NONNULL_END
