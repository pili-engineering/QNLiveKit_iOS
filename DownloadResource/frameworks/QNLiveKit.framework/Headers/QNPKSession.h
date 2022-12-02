//
//  QNPKSession.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveUser.h"
NS_ASSUME_NONNULL_BEGIN

@interface QNPKSession : NSObject
//PK场次ID
@property (nonatomic, copy)NSString *sessionId;
//跨房会话ID
@property (nonatomic, copy)NSString *relay_id;
//跨房token
@property (nonatomic, copy)NSString *relay_token;
//发起方
@property (nonatomic, strong)QNLiveUser *initiator;
//接受方
@property (nonatomic, strong)QNLiveUser *receiver;
//发起方所在房间
@property (nonatomic, copy)NSString *initiatorRoomId;
//接受方所在房间
@property (nonatomic, copy)NSString *receiverRoomId;
//扩展字段
@property (nonatomic, copy)NSString *extensions;
//跨房状态，此时的状态有：0，等待接收方同意；1，接收方已同意（目的房间不需要确认）
@property (nonatomic, assign)NSInteger relay_status;
//pk开始时间戳
@property (nonatomic, assign)long long startTimeStamp;
@end

NS_ASSUME_NONNULL_END
