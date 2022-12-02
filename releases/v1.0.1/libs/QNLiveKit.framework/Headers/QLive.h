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

/// 初始化
/// @param token token
/// @param serverURL 域名
/// @param errorBack 错误回调
+ (void)initWithToken:(NSString *)token serverURL:(NSString *)serverURL errorBack:(nullable void (^)(NSError *_Nullable error))errorBack;
//是否需要使用内置美颜功能，默认为NO
+ (void)setBeauty:(BOOL)needBeauty;
//绑定用户信息
+ (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(nullable NSDictionary *)extension;
//创建主播端
+ (QNLivePushClient *)createPusherClient;
//创建观众端
+ (QNLivePullClient *)createPlayerClient;
//获得直播场景
+ (QRooms *)getRooms;
//获取自己的信息
+ (void)getSelfUser:(nullable void (^)(QNLiveUser *_Nullable user,NSError *_Nullable QError))callBack;

@end

NS_ASSUME_NONNULL_END
