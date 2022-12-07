//
//  QNSDKConfig.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/1.
//

#import <Foundation/Foundation.h>
#import "QNIMDefines.h"
@class QNIMOSSConfig;
@class QNIMHostConfig;

NS_ASSUME_NONNULL_BEGIN

@interface QNSDKConfig : NSObject

@property (nonatomic, copy) NSString *dataDir;

@property (nonatomic, copy) NSString *cacheDir;

@property (nonatomic, copy) NSString *vsn;

@property (nonatomic, copy) NSString *sdkVersion;

@property (nonatomic, copy) NSString *pushCertName;

@property (nonatomic,copy) NSString *userAgent;

@property (nonatomic,assign) BOOL enableDeliveryAck;

@property (nonatomic, assign) QNIMLogLevel logLevelType;

@property (nonatomic, assign) BOOL consoleOutput;

@property (nonatomic, strong) QNIMHostConfig *hostConfig;

@property (nonatomic,assign) BOOL loadAllServerConversations;
/**
 * 获取设备的唯一识别码,如果使用数据库
 **/
@property (nonatomic,copy) NSString *deviceUUID;

@property (nonatomic,assign) BOOL verifyCertificate;

/**
 * 获取是否启用dns功能,设置是否启用dns功能，默认是开启的。
 **/
@property (nonatomic,assign) BOOL enableDNS;

/**
 * 获取用户自定义dns服务器地址,设置用户自定义dns服务器地址，在用户设置了dns服务器的情况下优先使用用户dns。
 **/
@property (nonatomic,copy) NSString *userDNSAddress;

/**
 * 获取用户的appId, 设置用户的appId。
 **/
@property (nonatomic,copy) NSString *appID;


@property (nonatomic, strong) NSString *appSecret;


/**
 设置调试log接收账号(仅用于SDK调试，接收客户端log日志使用)
 */
@property (nonatomic,copy) NSString *debugLogRecevierID;


- (instancetype)initConfigWithDataDir:(NSString *)dataDir
                             cacheDir:(NSString *)cacheDir
                         pushCertName:(NSString *)pushCertName
                            userAgent:(NSString *)userAgent;
@end

NS_ASSUME_NONNULL_END
