//
//  QLive.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveTypeDefines.h"
#import "QLiveConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveUser,QNLivePushClient,QNLivePullClient,QRooms;

@protocol QLiveTokenGetter <NSObject>

- (void)getTokenInfoWithComplete:(void (^)(NSString * token))complete failure:(QNFailureCallback)failure;

@end

/// 房间业务管理
@interface QLive : NSObject

/// 单例
+ (instancetype)sharedInstance;

/// 通过SDK 的配置，初始化SDK
/// @param config  配置信息
/// @param complete 初始化成功回调
/// @param failure 初始化失败回调
+ (void)initWithConfig:(QLiveConfig *)config tokenGetter:(id<QLiveTokenGetter> _Nullable)tokenGetter complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure;

/// 初始化
/// @param token token
/// @param serverURL 域名
/// @param errorBack 错误回调
+ (void)initWithToken:(NSString *)token serverURL:(NSString *)serverURL errorBack:(nullable void (^)(NSError *_Nullable error))errorBack;


/// 使用低代码Token 进行登录鉴权
/// @param token 低代码服务token，需要通过业务服务获取到。
/// @param complete 成功回调
/// @param failure 失败回调
+ (void)authWithToken:(NSString *)token complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure;


/// 设置是否开启美颜功能
/// @param needBeauty YES 开启；NO 不开启
+ (void)setBeauty:(BOOL)needBeauty;


/// 获取当前登录用户信息
+ (QNLiveUser *)getLoginUser;

/// 设置登录用户的用户信息
/// @param avatar 头像图片URL
/// @param nick 昵称
/// @param extension 扩展信息
+ (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(NSDictionary * _Nullable)extension;


/// 设置登录用户的用户信息
/// @param userInfo 用户信息
/// @param complete 成功回调
/// @param failure 失败回调
+ (void)setUser:(QNLiveUser *)userInfo complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure;

/// 创建主播端
+ (QNLivePushClient *)createPusherClient;

/// 创建观众端
+ (QNLivePullClient *)createPlayerClient;

//获得直播场景
+ (QRooms *)getRooms;


@property (nonatomic, strong) id<QLiveTokenGetter> tokenGetter;

- (void)refreshToken;
@end

NS_ASSUME_NONNULL_END
