//
//  QNLiveRoomClient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

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

//直播间某个属性变化
- (BOOL)onRoomExtensions:(NSString *)extension;

/// 离开回调
- (void)onRoomLeave:(QNLiveUser *)user;

/// 销毁回调
- (void)onRoomClose;

@end

@interface QNLiveRoomClient : NSObject

@property (nonatomic, weak) id <QNRoomLifeCycleListener> roomLifeCycleListener;

/// 获取房间所有用户
/// @param pageNumber 页数
/// @param pageSize 页面大小
/// @param callBack 回调用户列表
- (void)getUserListWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(void (^)(NSArray<QNLiveUser *> * list))callBack;

//房间心跳
- (void)roomHeartBeart;

//更新直播扩展信息
- (void)updateRoomExtension:(NSString *)extension callBack:(void (^)(void))callBack;

//某个房间在线用户
- (void)getOnlineUser:(NSString *)roomId callBack:(void (^)(NSArray <QNLiveUser *> *list))callBack;

//获取自己的信息
- (void)getSelfUser:(void (^)(QNLiveUser *user))callBack;

//使用用户ID搜索房间用户
- (void)searchUserByUserId:(NSString *)uid callBack:(void (^)(QNLiveUser *user))callBack;

//使用用户im uid 搜索用户
- (void)searchUserByIMUid:(NSString *)imUid callBack:(void (^)(QNLiveUser *user))callBack;

@end

NS_ASSUME_NONNULL_END
