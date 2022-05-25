//
//  QNLiveRoomEngine.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveTypeDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class QNCreateRoomParam,QNLiveRoomInfo,QNDeleteRoomParam,QNLiveUser;

/// 房间生命周期
@protocol QNRoomLifeCycleListener <NSObject>

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

/// 房间业务管理
@interface QNLiveRoomEngine : NSObject

- (instancetype)init;

/// 认证
/// @param callBack 认证回调
- (void)auth:(void (^)(void))callBack;

/// 创建房间
/// @param param 创建房间参数
/// @param callBack 回调房间信息
- (void)createRoom:(QNCreateRoomParam *)param callBack:(void (^)(QNLiveRoomInfo *roomInfo))callBack;

/// 删除房间
/// @param param 删除房间参数
/// @param callBack 回调
- (void)deleteRoom:(QNDeleteRoomParam *)param callBack:(void (^)(void))callBack;

/// 房间列表
/// @param status 房间状态
/// @param pageNumber 页数
/// @param pageSize 页面大小
/// @param callBack 回调房间列表
- (void)listRoomWithStatus:(QNLiveRoomStatus)status pageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(void (^)(NSArray <QNLiveRoomInfo *> *roomList))callBack;

/// 查询房间
/// @param roomId 房间id
/// @param callBack 回调房间列表
- (void)getRoomInfo:(NSString *)roomId callBack:(void (^)(NSArray <QNLiveRoomInfo *> *roomList))callBack;

@end

NS_ASSUME_NONNULL_END
