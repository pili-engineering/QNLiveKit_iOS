//
//  QNCountdownButton.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/12.
//

#import "QNCountdownButton.h"
#import <YYCategories/YYCategories.h>

@interface QNCountdownButton()
@property (nonatomic, copy) QNCountDownButtonBlock completion;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval duration;
@end

NSString *const kQNCountDownButtonUnitTime = @"s";

@implementation QNCountdownButton

#pragma mark - Public
- (void)countDownWithDuration:(NSTimeInterval)duration completion:(QNCountDownButtonBlock)completion {
    self.enabled = NO;
    _duration = duration;
    _completion = completion;
    [self setTitle:[NSString stringWithFormat:@"%ld%@后重新发送"
                    , (long)duration
                    , kQNCountDownButtonUnitTime] forState:UIControlStateDisabled];
    [self setBackgroundImage:[self createImageWithColor:[UIColor colorWithHexString:@"EAEAEA"]] forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setupTimer];
}

#pragma mark - Private
- (void)setupTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)countDown {
    _duration --;
    if (_duration == 0) {
        [self invalidTimer];
        self.enabled = YES;
        if (_completion) {
            _completion(YES);
        }
    }else {
        [self setTitle:[NSString stringWithFormat:@"%ld%@后重新发送"
                        , (long)_duration
                        , kQNCountDownButtonUnitTime] forState:UIControlStateDisabled];
    }
}

// 无效定时器
- (void)invalidTimer {
    [_timer invalidate];
    _timer = nil;
}

// 颜色转图片
- (UIImage*)createImageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 当父视图释放时，释放定时器
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
         [self invalidTimer];
    }
}


@end
