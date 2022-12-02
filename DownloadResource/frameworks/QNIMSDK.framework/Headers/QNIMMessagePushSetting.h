//
//  QNIMMessagePushSetting.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMMessagePushSetting : NSObject
/// 推送设定
@property (nonatomic, assign) BOOL pushEnabled;

/// 当APP未打开时是否允许推送
@property (nonatomic, assign) NSInteger silenceStartTime;

/// 推送静默结束时间
@property (nonatomic, assign) NSInteger silenceEndTime;

/// 允许推送起始时间
@property (nonatomic, assign) NSInteger pushStartTime;

/// 允许推送结束时间
@property (nonatomic, assign) NSInteger mPushEndTime;
@end

NS_ASSUME_NONNULL_END
