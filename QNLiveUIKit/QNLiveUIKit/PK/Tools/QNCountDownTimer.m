//
//  QNCountDownTimer.m
//  QNLiveUIKit
//
//  Created by xiaodao on 2023/6/12.
//

#import "QNCountDownTimer.h"

@interface QNCountDownTimer()

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation QNCountDownTimer

+ (instancetype)startTimer:(double)duration
                  interval:(double)interval
                    onTime:(QNOnTimeBlock)onTimeBlock
                  onFinish:(dispatch_block_t)onFinishBlock {
    
    //在主线程中回调
    dispatch_queue_t timerQueue = dispatch_get_main_queue();
    
    QNCountDownTimer *timerService = [[QNCountDownTimer alloc] init];
    timerService.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
    dispatch_source_set_timer(timerService.timer,
                              dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC),
                              interval * NSEC_PER_SEC,
                              0.1 * NSEC_PER_SEC);
    
    __block double timeout = duration; // 倒计时总时长（单位秒）
    dispatch_source_set_event_handler(timerService.timer, ^{
        if (timeout <= 0) { // 倒计时结束，取消定时器
            [timerService cancel];
            if (onFinishBlock) {
                onFinishBlock();
            }
        } else { //每x秒回调一次
            timeout -= interval;
            if (onTimeBlock) {
                onTimeBlock(timeout);
            }
        }
    });
    //启动倒计时
    dispatch_resume(timerService.timer);
    return timerService;
}

- (void)cancel {
    if (!self.timer) {
        return;
    }
    dispatch_source_cancel(self.timer);
    self.timer = nil;
}

@end
