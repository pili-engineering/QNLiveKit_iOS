//
//  QRooms.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNCreateRoomParam,QNLiveRoomInfo;

//场景回调
@protocol QNRoomsListener <NSObject>

@optional

/// 有直播房间被创建
- (void)onRoomCreated:(QNLiveRoomInfo *)roomInfo;

/// 有直播房间被关闭
- (void)onRoomClose:(QNLiveRoomInfo *)roomInfo;

@end

@interface QRooms : NSObject

@property (nonatomic, weak) id <QNRoomsListener> roomsListener;

/// 创建房间
/// @param param 创建房间参数
/// @param callBack 回调房间信息
- (void)createRoom:(QNCreateRoomParam *)param callBack:(nullable void (^)(QNLiveRoomInfo *roomInfo))callBack;

/// 删除房间
/// @param callBack 回调
- (void)deleteRoom:(NSString *)liveId callBack:(void (^)(void))callBack;

/// 房间列表
/// @param pageNumber 页数
/// @param pageSize 页面大小
/// @param callBack 回调房间列表
- (void)listRoom:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(nullable void (^)(NSArray<QNLiveRoomInfo *> * list))callBack;

/// 查询房间信息
/// @param callBack 回调房间信息
- (void)getRoomInfo:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *roomInfo))callBack;

@end

NS_ASSUME_NONNULL_END
