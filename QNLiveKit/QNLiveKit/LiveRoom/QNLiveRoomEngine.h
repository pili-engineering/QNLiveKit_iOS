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

+ (void)initWithToken:(NSString *)token;

/// 创建房间
/// @param param 创建房间参数
/// @param callBack 回调房间信息
+ (void)createRoom:(QNCreateRoomParam *)param callBack:(void (^)(QNLiveRoomInfo *roomInfo))callBack;

/// 删除房间
/// @param callBack 回调
+ (void)deleteRoom:(NSString *)liveId callBack:(void (^)(void))callBack;

/// 房间列表
/// @param pageNumber 页数
/// @param pageSize 页面大小
/// @param callBack 回调房间列表
+ (void)listRoomWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(void (^)(NSArray<QNLiveRoomInfo *> * list))callBack;

@end

NS_ASSUME_NONNULL_END
