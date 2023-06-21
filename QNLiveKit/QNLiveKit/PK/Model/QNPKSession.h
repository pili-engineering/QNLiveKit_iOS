//
//  QNPKSession.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveUser.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - QNPKStatus

typedef enum {
    QNPKStatusWaitAgree = 0,    //等待接收方同意
    QNPKStatusInitSuccess = 2,  //发起方已经完成跨房，等待对方完成
    QNPKStatusRecvSuccess = 3,  //接收方已经完成跨房，等待对方完成
    QNPKStatusSuccess = 4,      //两方都完成跨房
    QNPKStatusStopped = 6,      //结束
} QNPKStatus;


#pragma mark - QNPKSession

@interface QNPKSession : NSObject
//跨房PK会话ID
@property (nonatomic, copy) NSString *sessionId;
//发起方
@property (nonatomic, strong) QNLiveUser *initiator;
//接受方
@property (nonatomic, strong) QNLiveUser *receiver;
//发起方所在房间
@property (nonatomic, copy) NSString *initiatorRoomId;
//接受方所在房间
@property (nonatomic, copy) NSString *receiverRoomId;
//PK状态
@property (nonatomic, assign) QNPKStatus status;
//pk开始时间戳
@property (nonatomic, assign) long long startTimeStamp;

/*
 //PK总时长
 @"TotalDuration": @"180",
 //PK打榜持续时间
 @"pkDuration": @"120",
 //PK惩罚持续时间
 @"penaltyDuration": @"60"
 //PK积分
 @"pkIntegral": JSON字符串（可反序列化成 QNPKIntegralModel 对象）
 */
//PK扩展字段
@property (nonatomic, strong) NSDictionary *extensions;

@end


#pragma mark - QNPKSession (fromInvitation)

@class QInvitationModel;

@interface QNPKSession (fromInvitation)

// QInvitationModel -> QNPKSession
+ (instancetype)fromInvitationModel:(QInvitationModel *)invitationModel;

@end


NS_ASSUME_NONNULL_END
