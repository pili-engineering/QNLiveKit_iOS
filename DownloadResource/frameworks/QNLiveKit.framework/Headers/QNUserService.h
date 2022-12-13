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

+ (instancetype)sharedInstance;

- (void)getUserByID:()userId complete:(void (^)(QNLiveUser *user))complete;

@end

NS_ASSUME_NONNULL_END
