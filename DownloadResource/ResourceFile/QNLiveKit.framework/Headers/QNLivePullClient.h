//
//  QNLivePullClient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveRoomClient.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "QNLiveTypeDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QNPullClientListener <NSObject>

@optional

- (void)onRoomStatusChange:(QNLiveRoomStatus)liveRoomStatus msg:(NSString *)msg;

@end

@interface QNLivePullClient : QNLiveRoomClient

@property (nonatomic, weak) id <QNPullClientListener> pullClientListener;

/// 创建实例
+ (instancetype)createLivePullClient;
- (void)destroy;

/// 观众加入直播
/// @param callBack 回调
- (void)joinRoom:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable roomInfo))callBack;

/// 离开直播
- (void)leaveRoom:(NSString *)roomID;

@end

NS_ASSUME_NONNULL_END
