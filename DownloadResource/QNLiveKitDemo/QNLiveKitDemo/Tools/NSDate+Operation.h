//
//  NSDate+Operation.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Operation)
//时间戳转换为时间格式 yyyy-MM-dd
+ (NSString *)yyyyMMddStringWithSecond:(NSTimeInterval)time;

//获取当前时间
+(NSString*)getCurrentTimes;

//获取当前时间戳方法(以秒为单位)
+(NSString *)getNowTimeTimestamp;

//获取当前时间戳 （以毫秒为单位）
+(NSString *)getNowTimeTimestamp3;

//获取30s后时间戳方法(以秒为单位),如果想要其它时间，自己做下封装
+(NSString *)get30sTimeTimestamp;

//一个时间戳距离当前时间日分秒，常用于 10秒前，10分钟前，10小时前。。。。
+(NSString *)twoTimestampSub:(NSString *)oneTime nowTime:(NSString *)nowTime;

//时间戳转化为时间
+(NSString *)timeStampChangeTime:(NSString *)timeStamp andFormatter:(NSString *)Formatter;

//秒数转化时分，例如：50:18
+(NSString *)timeChangeMS:(NSInteger)time;
@end

NS_ASSUME_NONNULL_END
