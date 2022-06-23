//
//  QNCountdownButton.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^QNCountDownButtonBlock)(BOOL finished);

@interface QNCountdownButton : UIButton
//按钮倒计时
- (void)countDownWithDuration:(NSTimeInterval)duration completion:(QNCountDownButtonBlock)completion;

@end

NS_ASSUME_NONNULL_END
