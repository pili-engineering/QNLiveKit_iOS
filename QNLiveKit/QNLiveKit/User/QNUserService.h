//
//  QNUserService.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import <Foundation/Foundation.h>
#import "QNLiveUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNUserService : NSObject

/// 当前登录用户信息
@property (atomic, strong, readonly) QNLiveUser *loginUser;

+ (instancetype)sharedInstance;


- (void)fetchLoginUserComplete:(void (^)(QNLiveUser *user))complete failure:(QNFailureCallback)failure;

- (void)getUserByID:()userId complete:(void (^)(QNLiveUser *user))complete;

/// 设置登录用户的用户信息
/// @param userInfo 用户信息
/// @param complete 成功回调
/// @param failure 失败回调
- (void)setUser:(QNLiveUser *)userInfo complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure;

@end

NS_ASSUME_NONNULL_END
