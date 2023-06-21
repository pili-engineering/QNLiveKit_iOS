//
//  QNPKViewUpdateUtil.m
//  QNLiveUIKit
//
//  Created by xiaodao on 2023/6/19.
//

#import "QNPKViewUpdateUtil.h"
#import <QNLiveKit/QNLiveKit.h>
#import "QNPKStrategyConfig.h"

@implementation QNPKViewUpdateUtil

/**
 刷新PK视图-左右分数变化
 */
+ (void)updatePKScoreView:(NSDictionary *)extensions forPKView:(QNPKView *)pkView {
    //根据扩展字段 extensions 中的pkIntegral，获取分数
    NSString *integralJsonString = [extensions objectForKey:@"pkIntegral"];
    if (integralJsonString) {
        QNPKIntegralModel *integralModel = [QNPKIntegralModel mj_objectWithKeyValues:integralJsonString];
        if ([integralModel.initiatorUserId isEqualToString: LIVE_User_id]) { //主播是PK邀请方
            [pkView updateViewWithMyScore:integralModel.initiatorScore otherScore:integralModel.receiverScore];
        } else { //主播是PK接受方
            [pkView updateViewWithMyScore:integralModel.receiverScore otherScore:integralModel.initiatorScore];
        }
    }
}

/**
 计算PK倒计时（剩余）时长
 */
+ (double)getPKCountDownDuration:(long long)startTimeStamp extensions:(NSDictionary *)extensions {
    //扩展字段 extensions 中的内容：
    //PK总时长
    //@"TotalDuration": @"180",
    //PK打榜持续时间
    //@"pkDuration": @"120",
    //PK惩罚持续时间
    //@"penaltyDuration": @"60"
    QNPKStrategyConfig *config = [QNPKStrategyConfig mj_objectWithKeyValues:extensions];
    
    //如果存在（自定义）PK总时长
    NSString *totalDuration = config.totalDuration;
    if (totalDuration) {
        if (startTimeStamp) { //存在 开始时间戳
            //计算流逝的时间
            double elapsedTime = [NSDate.now timeIntervalSince1970] - startTimeStamp;
            //返回剩余的时间
            return MAX([totalDuration doubleValue] - elapsedTime, 0);
        } else { //不存在 开始时间戳
            //直接使用PK总时长
            return [totalDuration doubleValue];
        }
    }
    //兜底
    return 180;
}

/**
 获取 PK惩罚持续时间
 */
+ (double)getPKPenaltyDuration:(NSDictionary *)extensions {
    QNPKStrategyConfig *config = [QNPKStrategyConfig mj_objectWithKeyValues:extensions];
    //如果存在 PK惩罚持续时间
    NSString *penaltyDuration = config.penaltyDuration;
    if (penaltyDuration) {
        return [penaltyDuration doubleValue];
    }
    return 0;
}

@end
