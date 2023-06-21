//
//  QNCountDownTimer.h
//  QNLiveUIKit
//
//  Created by xiaodao on 2023/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//剩余时间回调
typedef void (^QNOnTimeBlock)(double remainTime);

@interface QNCountDownTimer : NSObject

//开始PK倒计时
+ (instancetype)startTimer:(double)duration
                  interval:(double)interval
                    onTime:(QNOnTimeBlock)onTimeBlock
                  onFinish:(dispatch_block_t)onFinishBlock;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
