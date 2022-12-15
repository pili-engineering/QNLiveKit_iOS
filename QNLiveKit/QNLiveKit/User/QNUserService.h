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

@end

NS_ASSUME_NONNULL_END
