//
//  QNLiveRoomClient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveRoomEngine.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveUser,QNLiveRoomInfo;

/// 房间生命周期
@protocol QNRoomLifeCycleListener <NSObject>

@optional
/// 进入房间回调
/// @param user 用户
- (void)onRoomEnter:(QNLiveUser *)user;

/// 加入房间回调
/// @param roomInfo 房间信息
- (void)onRoomJoined:(QNLiveRoomInfo *)roomInfo;

/// 离开回调
- (void)onRoomLeave:(QNLiveUser *)user;

/// 销毁回调
- (void)onRoomClose;

@end

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

/// 开始直播
/// @param roomId 房间号
/// @param callBack 回调
- (void)startLive:(NSString *)roomId callBack:(void (^)(QNLiveRoomInfo * roomInfo))callBack;

/// 加入直播
/// @param roomId 房间id
/// @param callBack 回调
- (void)joinRoom:(NSString *)roomId callBack:(void (^)(QNLiveRoomInfo * roomInfo))callBack;

/// 离开直播
/// @param callBack 回调
- (void)leaveRoom:(NSString *)roomId callBack:(void (^)(void))callBack;

/// 停止直播
/// @param callBack 回调
- (void)closeRoom:(NSString *)roomId callBack:(void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
