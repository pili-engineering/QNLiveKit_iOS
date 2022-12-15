//
//  QNLiveError.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/12/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const _Nonnull QNLiveErrorDomain;


/// SDWebImage error domain and codes
typedef NS_ERROR_ENUM(QNLiveErrorDomain, QNLiveError) {
    QNLiveErrorInvalidConfig = 10001, // 配置文件错误
    QNLiveErrorFetchAppInfo  = 10002, // 获取应用配置信息错误
    
    QNLiveErrorInvalidToken   = 20001,  // 无效的token
    QNLiveErrorGetUserInfo    = 20002, // 获取用户信息失败
    QNLiveErrorLoginImFail    = 20003,   // 登录IM失败
    QNLiveErrorUpdateUserInfo = 20004, //更新用户信息失败
};



@interface QNErrorUtil : NSObject

+ (NSError *)errorWithCode:(NSInteger)code;

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString * )message;

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString * )message underlying:(id)error;

+ (NSError *)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;

@end


NS_ASSUME_NONNULL_END
