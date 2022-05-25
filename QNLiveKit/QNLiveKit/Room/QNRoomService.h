//
//  UserService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveUser,QNLiveRoomInfo;

@protocol RoomServiceListener <NSObject>
//直播间某个属性变化
- (BOOL)onRoomExtensions:(NSString *)extension;

@end

@interface QNRoomService : QNLiveService

//添加监听
- (void)addRoomServiceListener:(id<RoomServiceListener>)listener;

//移除监听
- (void)removeRoomServiceListener:(id<RoomServiceListener>)listener;

//获取当前房间
- (QNLiveRoomInfo *)getRoomInfo;

//刷新房间信息
- (void)refreshRoomInfo:(void (^)(QNLiveRoomInfo *roomInfo))callBack;

//更新直播扩展信息
- (void)updateRoomExtension:(NSString *)extension callBack:(void (^)(void))callBack;

//当前房间在线用户
- (void)getOnlineUser:(void (^)(NSArray <QNLiveUser *> *list))callBack;

//某个房间在线用户
- (void)getOnlineUser:(NSString *)roomId callBack:(void (^)(NSArray <QNLiveUser *> *list))callBack;

//使用用户ID搜索房间用户
- (void)searchUserByUserId:(NSString *)uid callBack:(void (^)(QNLiveUser *user))callBack;

//使用用户im uid 搜索用户
- (void)searchUserByIMUid:(NSString *)imUid callBack:(void (^)(QNLiveUser *user))callBack;


@end

NS_ASSUME_NONNULL_END
