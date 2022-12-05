//
//  QNIMPushUserProfile.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessagePushSetting;

@interface QNIMPushUserProfile : NSObject

/// 用户ID（唯一）
@property (nonatomic,assign, readonly) NSInteger userId;

/// 推送用户别名
@property (nonatomic,copy, readonly) NSString *pushAlias;

/// 推送用户token
@property (nonatomic,copy, readonly) NSString *pushToken;

/// 推送用户消息设定
@property (nonatomic, strong) QNIMMessagePushSetting *setting;

@end

NS_ASSUME_NONNULL_END
