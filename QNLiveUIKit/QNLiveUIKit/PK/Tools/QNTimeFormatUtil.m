//
//  QNTimeFormatUtil.m
//  QNLiveUIKit
//
//  Created by xiaodao on 2023/6/13.
//

#import "QNTimeFormatUtil.h"

static NSDateFormatter *formatter = nil;

@implementation QNTimeFormatUtil

+ (void)initialize {
    if (self == [QNTimeFormatUtil class]) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"mm:ss"];
    }
}

// 秒 -> 格式化为时间 00:00
+ (NSString *)secondsToTime:(double)seconds {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSString *formattedString = [formatter stringFromDate:date];
    return formattedString;
}

@end
