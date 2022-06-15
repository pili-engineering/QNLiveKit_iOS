//
//  QLive.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveTypeDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveUser,QNLivePushClient,QNLivePullClient,QRooms;

/// 房间业务管理
@interface QLive : NSObject
// 初始化
+ (void)initWithToken:(NSString *)token;
//绑定用户信息
+ (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(nullable NSDictionary *)extension callBack:(nullable void (^)(void))callBack;
//创建主播端
+ (QNLivePushClient *)createPusherClient;
//创建观众端
+ (QNLivePullClient *)createPlayerClient;
//获得直播场景
+ (QRooms *)getRooms;

//获取自己的信息
+ (void)getSelfUser:(void (^)(QNLiveUser *user))callBack;

@end

NS_ASSUME_NONNULL_END
