//
//  QNIMMessageObject.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/7.
//

#import <Foundation/Foundation.h>
#import "QNIMMessageAttachment.h"
#import "QNIMMessageConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    QNIMDeliveryStatusNew = 0,    // 新创建消息
    QNIMDeliveryStatusDelivering, // 消息投递中
    QNIMDeliveryStatusDeliveried, // 消息已投递
    QNIMDeliveryStatusFailed,      // 消息投递失败
    QNIMDeliveryStatusRecalled     //消息已撤回
} QNIMDeliveryStatus;

typedef enum {
    QNIMContentTypeText = 0,
    QNIMContentTypeImage,
    QNIMContentTypeVoice,
    QNIMContentTypeVideo,
    QNIMContentTypeFile,
    QNIMContentTypeLocation,
    QNIMContentTypeCommand,
    QNIMContentTypeForward,
}QNIMContentType;

typedef enum {
    QNIMDeliveryQosModeAtLastOnce = 0, // 最少投递一次
    QNIMDeliveryQosModeAtMostOnce, // 最多投递一次
    QNIMDeliveryQosModeExactlyOnce, // 仅投递一次
} QNIMDeliveryQosMode;

typedef enum {
    QNIMMessageTypeSingle = 0, // 单聊消息
    QNIMMessageTypeGroup, // 群聊消息
    QNIMMessageTypeSystem, //系统消息
}QNIMMessageType;

@interface QNIMMessageObject : NSObject

@property (nonatomic, assign) long long msgId;

@property (nonatomic, assign) long long fromId;

@property (nonatomic, assign) long long toId;

@property (nonatomic, assign) long long conversationId;

@property (nonatomic, assign) QNIMDeliveryStatus deliverystatus;

@property (nonatomic, assign) QNIMDeliveryQosMode qos;

@property (nonatomic, assign) QNIMMessageType messageType;

@property (nonatomic, assign) long long serverTimestamp;

@property (nonatomic, assign) long long clientTimestamp;

@property (nonatomic, assign) BOOL isPlayed;

@property (nonatomic, assign) BOOL isReceiveMsg;
//全部消息是否已读
@property (nonatomic,assign) BOOL isRead;
//接受消息是否发送已读回执
@property (nonatomic,assign) BOOL isReadAcked;
//接受消息是否发送已送达
@property (nonatomic, assign) BOOL isDeliveryAcked;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) QNIMMessageConfig *messageconfig;

@property (nonatomic, copy) NSString *extensionJson;

@property (nonatomic, assign) QNIMContentType contentType;

@property (nonatomic,copy) NSString *senderName;

//消息是否存在groupAck,在发送群组消息且需要群组成员发送已读回执的时候需要设置为true。
//@property (nonatomic,assign) BOOL enableGroupAck;

//群消息AckCount数目
@property (nonatomic,assign) int groupAckCount;

@property (nonatomic, strong) QNIMMessageAttachment *attachment;


/**
 创建文本消息

 @param content 内容
 @param fromId 发送id
 @param toId 接收id
 @param mtype 消息类型
 @param conversationId 会话id
 @return QNIMMessageObject
 */
- (instancetype)initWithQNIMMessageText:(NSString *)content
                                fromId:(long long )fromId
                                  toId:(long long)toId
                                  type:(QNIMMessageType)mtype
                        conversationId:(long long )conversationId;

/// 创建发送命令消息(命令消息通过content字段或者extension字段存放命令信息)
/// @param content 消息内容
/// @param fromId 消息发送者
/// @param toId 消息接收者
/// @param mtype 消息类型
/// @param conversationId 会话id
- (instancetype)initWithQNIMCommandMessageText:(NSString *)content
                                       fromId:(long long )fromId
                                         toId:(long long)toId
                                         type:(QNIMMessageType)mtype
                               conversationId:(long long )conversationId;

/**
 创建附件消息

 @param attachment QNIMMessageAttachment
 @param fromId 发送id
 @param toId 接收id
 @param mtype 消息类型
 @param conversationId 会话id
 @return QNIMMessageObject
 */
- (instancetype)initWithQNIMMessageAttachment:(QNIMMessageAttachment *)attachment
                                      fromId:(long long )fromId
                                        toId:(long long)toId
                                        type:(QNIMMessageType)mtype
                              conversationId:(long long )conversationId;


/**
 创建接收文本消息

 @param content 内容
 @param msgId 消息id
 @param fromId 发送id
 @param toId 接收id
 @param mtype 消息类型
 @param conversationId 会话id
 @param timeStamp 时间戳
 @return QNIMMessageObject
 */
- (instancetype)initWithRecieveQNIMMessageText:(NSString *)content
                                        msgId:(long long)msgId
                                       fromId:(long long )fromId
                                         toId:(long long)toId
                                         type:(QNIMMessageType)mtype
                               conversationId:(long long )conversationId
                                    timeStamp:(long long)timeStamp;



/// 创建收到的命令消息(命令消息通过content字段或者extension字段存放命令信息)
/// @param content 消息内容
/// @param msgId 消息id
/// @param fromId 消息发送者
/// @param toId 消息接收者
/// @param mtype 消息类型
/// @param conversationId 会话id
/// @param timeStamp 服务器时间戳
- (instancetype)initWithRecieveQNIMMessageCommandMessageText:(NSString *)content
                                                       msgId:(long long)msgId
                                                                fromId:(long long )fromId
                                                                  toId:(long long)toId
                                                                  type:(QNIMMessageType)mtype
                                                        conversationId:(long long )conversationId
                                                             timeStamp:(long long)timeStamp;

                                                         




/**
 创建接收附件消息

 @param attachment QNIMMessageAttachment
 @param msgId 消息id
 @param fromId 发送id
 @param toId 接收id
 @param mtype 消息类型
 @param conversationId 会话id
 @param timeStamp 时间戳
 @return QNIMMessageObject
 */
- (instancetype)initWithRecieveQNIMMessageAttachment:(QNIMMessageAttachment *)attachment
                                              msgId:(long long)msgId
                                             fromId:(long long )fromId
                                               toId:(long long)toId
                                               type:(QNIMMessageType)mtype
                                     conversationId:(long long )conversationId
                                          timeStamp:(long long)timeStamp;


/**
 创建转发消息

 @param message QNIMMessageObject
 @param fromId 发送id
 @param toId 接收id
 @param mtype 消息类型
 @param conversationId 会话id
 @return QNIMMessageObject
 */
- (instancetype)initWithForwardMessage:(QNIMMessageObject *)message
                                fromId:(long long )fromId
                                  toId:(long long)toId
                                  type:(QNIMMessageType)mtype
                        conversationId:(long long )conversationId;



@end

NS_ASSUME_NONNULL_END
