//
//  QNIMChatServiceProtocol.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/7.
//

#import <Foundation/Foundation.h>

@class QNIMMessageObject;
@class QNIMError;
@class QNIMConversation;

@protocol QNIMChatServiceProtocol <NSObject>


@optional

/**
 * 消息发送状态发生变化
 **/
- (void)messageStatusChanged:(QNIMMessageObject *)message
            error:(QNIMError *)error;

/**
 * 收到消息
 **/
- (void)receivedMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 附件上传进度发送变化
 **/
- (void)messageAttachmentUploadProgressChanged:(QNIMMessageObject *)message
                                percent:(int)percent;

/**
 * 消息撤回状态发送变化
 **/
- (void)messageRecallStatusDidChanged:(QNIMMessageObject *)message
                      error:(QNIMError *)error;

/**
 * 收到命令消息
 **/
- (void)receivedCommandMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 收到系统通知消息
 **/
- (void)receivedSystemMessages:(NSArray<QNIMMessageObject*> *)messages;


/**
 * 收到消息已读回执
 **/
- (void)receivedReadAcks:(NSArray<QNIMMessageObject*> *)messages;


/**
 * 收到消息已送达回执
 **/
- (void)receivedDeliverAcks:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 收到撤回消息
 **/
- (void)receivedRecallMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 收到消息已读取消（多设备其他设备同步消息已读状态变为未读）
 **/
- (void)receiveReadCancelsMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 收到消息全部已读（多设备同步某消息之前消息全部设置为已读）
 **/
- (void)receiveReadAllMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 收到删除消息 （多设备同步删除消息）
 **/
- (void)receiveDeleteMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 附件下载状态发生变化
 **/
- (void)messageAttachmentStatusDidChanged:(QNIMMessageObject *)message
                          error:(QNIMError*)error
                        percent:(int)percent;

/**
 * 拉取历史消息
 **/
- (void)retrieveHistoryMessagesConversation:(QNIMConversation *)conversation;


/**
 已经加载完未读会话列表
 */
- (void)loadAllConversationDidFinished;

/**
 本地创建新会话成功

 @param conversation 新创建的本地会话
 @param message 会话的最新消息，存在返回不存在返回为空
 */
- (void)conversationDidCreatedConversation:(QNIMConversation *)conversation message:(QNIMMessageObject *)message;


/**
 删除会话

 @param conversationId 删除的本地会话id
 @param error 状态错误码
 */
- (void)conversationDidDeletedConversationId:(NSInteger)conversationId error:(QNIMError*)error;


/**
 更新总未读数

 @param unreadCount 未读数
 */
- (void)conversationTotalCountChanged:(NSInteger)unreadCount;

@end



