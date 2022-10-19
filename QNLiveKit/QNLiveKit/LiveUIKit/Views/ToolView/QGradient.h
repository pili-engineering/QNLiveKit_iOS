//
//  QGradient.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QGradient : UIView

//从上到下单色渐变
+ (void)setTopToBottomGradientColor:(UIColor *)gradientColor view:(UIView *)view;
//从下到上单色渐变
+ (void)setBottomToTopGradientColor:(UIColor *)gradientColor view:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
