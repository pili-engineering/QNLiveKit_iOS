//
//  QNLiveRoomClient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNRoomLifeCycleListener.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveUser,QNLiveService;

@interface QNLiveRoomClient : NSObject

/// 注册需要的服务
/// @param serviceClasses 服务列表
- (void)registerService:(NSArray *)serviceClasses;

/// 获取服务
- (NSArray *)getService;

/// 添加房间生命周期监听
/// @param lifeCycleListener listener
- (void)addRoomLifeCycleListener:(id<QNRoomLifeCycleListener>)lifeCycleListener;

/// 移除房间生命周期监听
/// @param lifeCycleListener listener
- (void)removeRoomLifeCycleListener:(id<QNRoomLifeCycleListener>)lifeCycleListener;

/// 加入房间
/// @param user 用户
/// @param roomId 房间id
/// @param callBack 回调
- (void)joinRoom:(QNLiveUser *)user roomId:(NSString *)roomId callBack:(void (^)(void))callBack;

/// 离开房间
/// @param callBack 回调
- (void)leaveRoom:(void (^)(void))callBack;

/// 关闭房间
/// @param callBack 回调
- (void)closeRoom:(void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
