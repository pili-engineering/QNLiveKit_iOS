//
//  QNNetworkUtil.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface QNNetworkUtil : NSObject
+ (AFHTTPSessionManager *)manager;
//get请求
+ (void)getRequestWithAction:(NSString *)action params:(NSDictionary *)params success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSError *error))failure;
//post请求
+ (void)postRequestWithAction:(NSString *)action params:(NSDictionary *)params success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSError *error))failure;

@end
