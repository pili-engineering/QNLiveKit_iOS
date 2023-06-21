//
//  QNPKExtendsModel.h
//  QNLiveKit
//
//  Created by xiaodao on 2023/6/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#pragma mark - QNPKExtendsModel

//PK扩展字段（变更）通知
@interface QNPKExtendsModel : NSObject

@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *initiatorRoomId; //发起方房间ID
@property (nonatomic, copy) NSString *initiatorUserId; //发起方主播ID
@property (nonatomic, strong) NSDictionary *extends; //扩展字段字典（包含：key为"pkIntegral"的默认字段 ，是（json）字符串类型，可以反序列化为 QNPKIntegralModel 对象。可用于扩展业务"自定义"字段）

@end


#pragma mark - QNPKIntegralModel

//PK积分
@interface QNPKIntegralModel : NSObject

@property (nonatomic, copy) NSString *receiverRoomId; //接受方房间ID
@property (nonatomic, copy) NSString *receiverUserId; //接受方主播ID
@property (nonatomic, copy) NSString *receiverScore;  //接受方分数

@property (nonatomic, copy) NSString *initiatorRoomId; //发起方房间ID
@property (nonatomic, copy) NSString *initiatorUserId; //发起方主播ID
@property (nonatomic, copy) NSString *initiatorScore;  //发起方分数

@end



NS_ASSUME_NONNULL_END
