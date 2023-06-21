//
//  QNPKView.h
//  QNLiveUIKit
//
//  Created by xiaodao on 2023/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 PK视图
 */
@interface QNPKView : UIView

/**
 开始PK倒计时
 */
- (void)startPKCountDown:(double)duration penaltyDuration:(double)penaltyDuration onFinish:(dispatch_block_t)onFinishBlock;

/**
 停止PK倒计时
 */
- (void)stopPKCountDown;

/**
 更新分数
 */
- (void)updateViewWithMyScore:(NSString *)myScore otherScore:(NSString *)otherScore;

@end

NS_ASSUME_NONNULL_END
