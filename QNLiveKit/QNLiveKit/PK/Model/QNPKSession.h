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
//pk 状态 0邀请过程  1pk中 2结束 其他自定义状态比如惩罚时间
@property (nonatomic, assign)NSInteger status;
//pk开始时间戳
@property (nonatomic, assign)long long startTimeStamp;
@end

NS_ASSUME_NONNULL_END
