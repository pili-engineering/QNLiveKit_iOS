//
//  QLiveNetworkUtil.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SuccessBlock)(NSDictionary *responseData);
typedef void (^FailureBlock)(NSError *error);

@interface QLiveNetworkUtil : NSObject

+ (void)getRequestWithAction:(NSString *)action params:(nullable NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)postRequestWithAction:(NSString *)action params:(nullable NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)deleteRequestWithAction:(NSString *)action params:(nullable NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;
+ (void)putRequestWithAction:(NSString *)action params:(nullable NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
