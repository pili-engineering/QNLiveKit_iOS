//
//  QNTimeFormatUtil.h
//  QNLiveUIKit
//
//  Created by xiaodao on 2023/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNTimeFormatUtil : NSObject

// 秒 -> 格式化为时间 00:00
+ (NSString *)secondsToTime:(double)seconds;

@end

NS_ASSUME_NONNULL_END
