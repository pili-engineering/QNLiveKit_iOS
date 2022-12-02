//
//  QNLiveRoomClient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveUser,QNLiveRoomInfo,QLinkMicService;

/// 房间生命周期
@protocol QNRoomLifeCycleListener <NSObject>

@optional

/// 加入房间回调
/// @param roomInfo 房间信息
- (void)onRoomJoined:(QNLiveRoomInfo *)roomInfo;

//直播间某个属性变化
- (BOOL)onRoomExtensions:(NSString *)extension;

/// 房间被销毁
- (void)onRoomClose:(QNLiveRoomInfo *)roomInfo;

@end

@interface QNLiveRoomClient : NSObject

@property (nonatomic, strong) QNLiveRoomInfo *roomInfo;

@property (nonatomic, weak) id <QNRoomLifeCycleListener> roomLifeCycleListener;

/// 获取房间所有用户
/// @param roomId 房间id
/// @param pageNumber 页数
/// @param pageSize 页面大小
/// @param callBack 回调用户列表
- (void)getUserList:(NSString *)roomId pageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(void (^)(NSArray<QNLiveUser *> * _Nonnull))callBack;

//房间心跳
- (void)roomHeartBeart:(NSString *)roomId;

//更新直播扩展信息
- (void)updateRoom:(NSString *)roomId extension:(NSString *)extension callBack:(void (^)(void))callBack;

//某个房间在线用户
- (void)getOnlineUser:(NSString *)roomId callBack:(void (^)(NSArray <QNLiveUser *> *list))callBack;

//使用用户ID搜索房间用户
- (void)searchUserByUserId:(NSString *)uid callBack:(void (^)(QNLiveUser *user))callBack;

//使用用户im uid 搜索用户
- (void)searchUserByIMUid:(NSString *)imUid callBack:(void (^)(QNLiveUser *user))callBack;



@end

NS_ASSUME_NONNULL_END
