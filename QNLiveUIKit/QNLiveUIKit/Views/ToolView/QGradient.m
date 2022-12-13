//
//  QGradient.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/8/11.
//

#import "QGradient.h"
    
@implementation QGradient


+ (void)setTopToBottomGradientColor:(UIColor *)gradientColor view:(UIView *)view {
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer]; 
    gradientLayer.borderWidth = 0;
    gradientLayer.bounds = view.bounds;
    gradientLayer.frame = view.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],(id)[gradientColor CGColor],nil];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);
    [view.layer addSublayer:gradientLayer];
    
}

+ (void)setBottomToTopGradientColor:(UIColor *)gradientColor view:(UIView *)view {
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.borderWidth = 0;
    gradientLayer.bounds = view.bounds;
    gradientLayer.frame = view.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],(id)[gradientColor CGColor],nil];
    gradientLayer.startPoint = CGPointMake(0.5, 1);
    gradientLayer.endPoint = CGPointMake(0.5, 0);
    [view.layer addSublayer:gradientLayer];
    
}

@end
