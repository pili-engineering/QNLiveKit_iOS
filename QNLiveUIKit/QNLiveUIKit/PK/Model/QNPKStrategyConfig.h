//
//  QNPKStrategyConfig.h
//  QNLiveUIKit
//
//  Created by xiaodao on 2023/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//PK玩法策略配置（业务可自定义）
@interface QNPKStrategyConfig : NSObject

@property (nonatomic, copy) NSString *totalDuration; //PK总时长（比如：180秒）
@property (nonatomic, copy) NSString *pkDuration; //PK打榜持续时间（比如：120秒）
@property (nonatomic, copy) NSString *penaltyDuration;  //PK惩罚持续时间（比如：60秒）

@end

NS_ASSUME_NONNULL_END
