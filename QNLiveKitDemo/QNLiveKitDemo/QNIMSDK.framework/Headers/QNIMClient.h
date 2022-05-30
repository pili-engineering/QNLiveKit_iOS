//
//  QNIMClient.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/1.
//

#import <Foundation/Foundation.h>
#import "QNSDKConfig.h"
#import "QNIMError.h"
#import "QNIMDefines.h"
#import "QNIMUserProfile.h"

NS_ASSUME_NONNULL_BEGIN

@class QNSDKConfig;

@interface QNIMClient : NSObject

+ (instancetype)sharedClient;

@property (nonatomic, strong) QNSDKConfig *sdkConfig;

- (void)registerWithSDKConfig:(QNSDKConfig *)config;

+ (NSString *)getCacheDir;

/**
 注册新用户，username和password是必填参数

 @param userName 用户名
 @param password 密码
 @param aCompletionBlock 注册成功后从该函数处获取新注册用户的Profile信息，初始传入指向为空的shared_ptr对象即可。
 */
- (void)signUpNewUser:(NSString *)userName
             password:(NSString *)password
          completion:(void (^)(QNIMUserProfile *profile, QNIMError *error))aCompletionBlock;

/**
 * 通过用户名登录
 **/
- (void)signInByName:(NSString *)userName
            password:(NSString *)password
          completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 通过用户ID登录
 **/
- (void)signInById:(long long)userId password:(NSString *)password
        completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 通过用户ID和token登录
 **/
//- (void)signInById:(long long)userId withToken:(NSString *)token
//        completion:(void(^)(QNIMError *error))aCompletionBlock;


/**
 * 通过用户名自动登录（要求之前成功登录过，登录速度较快）
 **/
- (void)fastSignInByName:(NSString *)name
                password:(NSString *)password
              completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 通过用户ID自动登录（要求之前成功登录过，登录速度较快）
 **/
- (void)fastSignInById:(long long)uid
              password:(NSString *)password
            completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 退出登录
 **/
- (void)signOutID:(NSInteger)userID
ignoreUnbindDevice:(BOOL)ignoreUnbindDevice
   completion:(void(^)(QNIMError *error))aCompletionBlock;


- (void)signOutignoreUnbindDevice:(BOOL)ignoreUnbindDevice
   completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 获取当前的登录状态
 **/
- (QNIMSignInStatus)signInStatus;

/**
 * 获取当前和服务器的连接状态
 **/
- (QNIMConnectStatus)connectStatus;

/**
 处理网络状态发送变化
 
 @param type 变化后的网络类型
 @param reconnect 网络是否需要重连
 */
- (void)networkDidChangedType:(QNIMNetworkType)type reconnect:(BOOL)reconnect;

/**
 强制重新连接
 */
- (void)reconnect;

/**
 断开网络连接
 */
- (void)disConnect;

/**
 更改SDK的appId，本操作会同时更新QNIMConfig中的appId。
 
 @param appID  新变更的appId
 */
- (void)changeAppID:(NSString *)appID
         completion:(void (^)(QNIMError *error))aCompletionBlock;

/**
 获取app的服务器网络配置，在初始化SDK之后登陆之前调用，可以提前获取服务器配置加快登陆速度。

 @param isLocal 为true则使用本地缓存的dns配置，为false则从服务器获取最新的配置。
 */
- (void)initializeServerConfig:(BOOL)isLocal;

@end

NS_ASSUME_NONNULL_END
