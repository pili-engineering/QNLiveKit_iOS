//
//  QNIMUserServiceProtocol.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import "QNIMDefines.h"

@class QNIMUserProfile;
@class QNIMError;

@protocol QNIMUserServiceProtocol <NSObject>

@optional

/**
 链接状态发生变化

 @param status 网络状态
 */
- (void)connectStatusDidChanged:(QNIMConnectStatus)status;

/**
 用户登陆

 @param userProflie 用户信息
 */
- (void)userSignIn:(QNIMUserProfile *)userProflie;


/**
 用户登出

 @param error 错误码
 */
- (void)userSignOut:(QNIMError *)error userId:(long long)userId;

/**
 * 同步用户信息更新（其他设备操作发生用户信息变更）
 **/
- (void)userInfoDidUpdated:(QNIMUserProfile *)userProflie;

/**
 * 用户在其他设备上登陆
 **/
- (void)userOtherDeviceDidSignIn:(NSInteger)deviceSN;

/**
 * 用户在其他设备上登出
 **/
- (void)userOtherDeviceDidSignOut:(NSInteger)deviceSN;

@end

