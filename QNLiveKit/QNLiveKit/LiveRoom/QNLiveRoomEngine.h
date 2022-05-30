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

/// 房间业务管理
@interface QNLiveRoomEngine : NSObject

+ (void)initWithToken:(NSString *)token callBack:(void (^)(void))callBack;

/// 绑定自己用户信息
/// @param nickName 昵称
/// @param avatar 头像
/// @param callBack 回调
+ (void)updateUserInfo:(NSString *)nickName avatar:(NSString *)avatar callBack:(void (^)(void))callBack;

/// 创建房间
/// @param param 创建房间参数
/// @param callBack 回调房间信息
+ (void)createRoom:(QNCreateRoomParam *)param callBack:(void (^)(QNLiveRoomInfo *roomInfo))callBack;

/// 删除房间
/// @param param 删除房间参数
/// @param callBack 回调
+ (void)deleteRoom:(QNDeleteRoomParam *)param callBack:(void (^)(void))callBack;

/// 房间列表
/// @param status 房间状态
/// @param pageNumber 页数
/// @param pageSize 页面大小
/// @param callBack 回调房间列表
+ (void)listRoomWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(void (^)(NSArray<QNLiveRoomInfo *> * list))callBack;
/// 查询房间信息
/// @param roomId 房间id
/// @param callBack 回调房间信息
+ (void)getRoomInfo:(NSString *)roomId callBack:(void (^)(QNLiveRoomInfo *roomInfo))callBack;

@end

NS_ASSUME_NONNULL_END
