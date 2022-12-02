//
//  QNIMChatOption.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/15.
//

#import <Foundation/Foundation.h>
#import "QNIMChatServiceProtocol.h"
#import "QNIMConversation.h"
#import "QNIMMessageObject.h"
#import "QNIMError.h"

/**
 * 缩略图生成策略,
 **/
typedef enum {
    QNIMThirdpartyServerCreate = 1,     // 第三方服务器生成
    QNIMLocalServerCreate,              // 本地服务器生成
} QNIMThumbnailStrategy;

NS_ASSUME_NONNULL_BEGIN

@interface QNIMChatService : NSObject

+ (instancetype)sharedOption;

- (void)addDelegate:(id<QNIMChatServiceProtocol>)aDelegate;

- (void)addDelegate:(id<QNIMChatServiceProtocol>)aDelegate delegateQueue:(dispatch_queue_t)aQueue;

- (void)removeDelegate:(id<QNIMChatServiceProtocol>)aDelegate;

/**
 发送消息，消息状态变化会通过listener通知
 **/
- (void)sendMessage:(QNIMMessageObject *)message;

/**
 * 读取一条消息
 **/
- (void)getMessage:(NSInteger)messageId
        completion:(void(^)(QNIMMessageObject *message, QNIMError *error))aCompletionBlock;

/**
 重新发送消息，消息状态变化会通过listener通知
 **/
- (void)resendMessage:(QNIMMessageObject *)message
           completion:(void(^)(QNIMMessageObject *message, QNIMError *error))aCompletionBlock;

/**
 撤回消息，消息状态变化会通过listener通知
 **/
- (void)recallMessage:(QNIMMessageObject *)message
           completion:(void(^)(QNIMMessageObject *message, QNIMError *error))aCompletionBlock;

///**
// 合并转发消息
// **/
//- (void)forwardMessage:(NSArray *)messageList
//  conversationReceiver:(QNIMConversation *)conversationReceiver
//            completion:(void(^)(QNIMMessageObject *message, QNIMError *error))aCompletionBlock;

/**
 简单转发消息，用户应当通过QNIMMessagse::createForwardMessage()先创建转发消息
 **/
- (void)forwardMessage:(QNIMMessageObject *)message;

/**
 * 发送已读回执
 **/
- (void)ackMessage:(QNIMMessageObject *)message;

/**
 * 标记此消息为未读，该消息同步到当前用户的所有设备
 **/
- (void)readCancel:(QNIMMessageObject *)message;

/**
 * 标记此消息及之前全部消息为已读，该消息同步到当前用户的所有设备
 **/
- (void)readAllMessage:(QNIMMessageObject *)message;

/**
 * 下载缩略图，下载状态变化和进度通过listener通知
 * 缩略图生成策略，1 - 第三方服务器生成， 2 - 本地服务器生成，默认值是 1。
 **/
- (void)downloadThumbnail:(QNIMMessageObject *)message
                 strategy:(QNIMThumbnailStrategy)strategy;

/**
 * 下载附件，下载状态变化和进度通过listener通知
 **/
- (void)downloadAttachment:(QNIMMessageObject *)message;

/**
 * 插入消息
 **/

- (void)insetMessages:(NSArray<QNIMMessageObject *> *)list
            completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 删除此消息，该消息同步到当前用户的其它设备
 **/
- (void)removeMessage:(QNIMMessageObject *)message
synchronizeDeviceForce:(BOOL)synchronizeDeviceForce;

/**
 * 删除会话
 **/
- (void)deleteConversationByConversationId:(NSInteger)conversationId
                               synchronize:(BOOL)synchronize;

/**
 * 打开一个会话
 **/
- (QNIMConversation *)openConversation:(NSInteger)conversationId type:(QNIMConversationType)type createIfNotExist:(bool)create;

/**
 * 获取附件保存路径
 **/
- (NSString *)getAttachmentDir;

/**
 * 获取会话的附件保存路径
 **/
- (NSString *)getAttachmentDirForConversationWith:(NSString *)conversationId;

/**
 * 获取所有会话
 **/
- (void)getAllConversationsWithCompletion:(void(^)(NSArray <QNIMConversation *> *conversations))aCompletionBlock;


/**
 获取所有会话的全部未读数（标记为屏蔽的个人和群组的未读数不统计在内）

 @param aCompletionBlock count
 */
- (void)getAllConversationsUnreadCountWithCompletion:(void(^)(int count))aCompletionBlock;

/**
 * 拉取历史消息
 **/
- (void)retrieveHistoryQNIMconversation:(QNIMConversation *)conversation
                                 msgId:(long long)msgId
                                  size:(NSUInteger)size
                            completion:(void(^)(NSArray *messageListms, QNIMError *error))aCompletionBlock;

/**
 * 搜索消息
 **/
- (void)searchMessagesByKeyWords:(NSString *)keywords
               refTime:(NSTimeInterval)refTime
                  size:(NSUInteger)size
         directionType:(QNIMMessageDirection)directionType
            completion:(void (^)(NSArray *array, QNIMError *error))aCompletionBlock;

/**
 获取发送的群组消息已读用户id列表

 @param message 需要获取已读用户id列表的消息
 @param aCompletionBlock 对该条消息已读的用户id列表，初始传入为空列表
 */
- (void)getGroupAckMessageUserIdListWithMessage:(QNIMMessageObject *)message
                                     completion:(void(^)(NSArray *groupMemberIdList, QNIMError *error))aCompletionBlock;

/**
 获取发送的群组消息未读用户id列表

 @param message 需要获取未读用户id列表的消息
 @param aCompletionBlock 对该条消息未读的用户id列表，初始传入为空列表
 */
- (void)getGroupAckMessageUnreadUserIdListWithMessage:(QNIMMessageObject *)message
                                     completion:(void(^)(NSArray *groupMemberIdList, QNIMError *error))aCompletionBlock;

@end

NS_ASSUME_NONNULL_END
