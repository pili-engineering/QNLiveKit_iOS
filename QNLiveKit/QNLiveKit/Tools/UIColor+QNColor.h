//
//  UIColor+QNColor.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (QNColor)

+ (nullable UIColor *)colorWithHexString:(NSString *)hexStr;

@end

NS_ASSUME_NONNULL_END
