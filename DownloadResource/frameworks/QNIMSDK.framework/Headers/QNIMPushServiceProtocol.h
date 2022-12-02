//
//  QNIMPushServiceProtocol.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

@class QNIMMessageObject;
@class QNIMError;

@protocol QNIMPushServiceProtocol <NSObject>

@optional

/// Push初始化完成通知。
/// @param QNIMToken QNIMToken
- (void)pushStartDidFinished:(NSString *)imToken;

/// Push功能停止通知。
- (void)pushStartDidStopped;

/// Push初始化完成后获取推送证书。
/// @param certification 推送证书
- (void)certRetrieved:(NSString *)certification;

/// 设置用户推送标签成功回调。
/// @param operationId 操作id
- (void)setTagsDidFinished:(NSString *)operationId;

/// 获取用户推送标签成功回调。
/// @param operationId 操作id
- (void)getTagsDidFinished:(NSString *)operationId;

/// 删除用户推送标签成功回调
/// @param operationId 操作id
- (void)deleteTagsDidFinished:(NSString *)operationId;

/// 清空用户推送成功回调。
/// @param operationId 操作id
- (void)clearedTags:(NSString *)operationId;

/// 接收到新的Push通知
/// @param messages Push通知列表
- (void)receivedPush:(NSArray<QNIMMessageObject *> *)messages;

/// 发送Push上行消息状态变化通知。
/// @param message 发生状态变化的上行消息
/// @param error 状态错误码
- (void)pushMessageStatusChanged:(QNIMMessageObject *)message error:(QNIMError *)error;

@end

