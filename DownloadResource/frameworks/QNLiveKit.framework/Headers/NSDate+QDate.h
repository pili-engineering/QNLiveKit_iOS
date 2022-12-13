//
//  NSDate+QDate.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (QDate)

//时间戳转换为时间格式 yyyy-MM-dd
+ (NSString *)yyyyMMddStringWithSecond:(NSTimeInterval)time;

//获取当前时间
+(NSString*)getCurrentTimes;

//获取当前时间戳方法(以秒为单位)
+(NSString *)getNowTimeTimestamp;

//获取当前时间戳 （以毫秒为单位）
+(NSString *)getNowTimeTimestamp3;

//一个时间戳距离当前时间日分秒，常用于 10秒前，10分钟前，10小时前。。。。
+(NSString *)twoTimestampSub:(NSString *)oneTime nowTime:(NSString *)nowTime;
//两个时间距离的分秒，00:20
+(NSString *)twoTimestampSub:(NSString *)startTime endTime:(NSString *)endTime;

//时间戳转化为时间
+(NSString *)timeStampChangeTime:(NSString *)timeStamp andFormatter:(NSString *)Formatter;

//秒数转化时分，例如：50:18
+(NSString *)timeChangeMS:(NSInteger)time;
@end

NS_ASSUME_NONNULL_END
