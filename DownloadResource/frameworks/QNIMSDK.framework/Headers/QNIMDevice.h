//
//  QNIMDevice.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMDevice : NSObject

/**
 设备序列号
 */
@property (nonatomic,assign, readonly) int deviceSN;

/**
 用户id
 */
@property (nonatomic,assign, readonly) long long userId;

/**
 平台
 */
@property (nonatomic,assign, readonly) int platform;

/**
 UA
 */
@property (nonatomic,copy) NSString *userAgent;

/**
 是否是当前设备
 */
@property (nonatomic,assign, readonly) BOOL isCurrentDevice;

@end

NS_ASSUME_NONNULL_END
