//
//  QNPKViewUpdateUtil.h
//  QNLiveUIKit
//
//  Created by xiaodao on 2023/6/19.
//

#import <Foundation/Foundation.h>
#import "QNPKView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 视图更新工具类
 */
@interface QNPKViewUpdateUtil : NSObject

/**
 刷新PK视图-左右分数变化
 */
+ (void)updatePKScoreView:(NSDictionary *)extensions forPKView:(QNPKView *)pkView;

/**
 计算PK倒计时（剩余）时长
 */
+ (double)getPKCountDownDuration:(long long)startTimeStamp extensions:(NSDictionary *)extensions;

/**
 获取 PK惩罚持续时间
 */
+ (double)getPKPenaltyDuration:(NSDictionary *)extensions;

@end

NS_ASSUME_NONNULL_END
