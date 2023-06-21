//
//  QNPKInfo.h
//  QNLiveKit
//
//  Created by xiaodao on 2023/6/14.
//

#import <Foundation/Foundation.h>
#import "QNPKSession.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - QNPKInfo

@interface QNPKInfo : NSObject

@property (nonatomic, copy) NSString *relayId; //PK会话ID
@property (nonatomic, copy) NSString *initiatorRoomId; //发起方房间ID
@property (nonatomic, copy) NSString *initiatorUserId; //发起方主播ID

@property (nonatomic, copy) NSString *receiverRoomId; //接受方房间ID
@property (nonatomic, copy) NSString *receiverUserId; //接受方主播ID

@property (nonatomic, assign) long long createdAt; //创建时间
@property (nonatomic, assign) long long startAt; //PK开始时间
@property (nonatomic, assign) NSInteger status; //PK状态
/*
 //PK总时长
 @"TotalDuration": @"180",
 //PK打榜持续时间
 @"pkDuration": @"120",
 //PK惩罚持续时间
 @"penaltyDuration": @"60"
 */
@property (nonatomic, strong) NSDictionary *extensions; //PK（自定义）扩展字段

//获取PK开始时间戳
- (long long)getStartTimeStamp;

@end


#pragma mark - QNPKInfo (ToSession)

@interface QNPKInfo (ToSession)

- (QNPKSession *_Nullable)toSession;

@end


NS_ASSUME_NONNULL_END

