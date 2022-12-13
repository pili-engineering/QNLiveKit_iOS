//
//  NSDate+QDate.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/9/20.
//

#import "NSDate+QDate.h"

@implementation NSDate (QDate)

//时间戳转换为时间格式 yyyy-MM-dd
+ (NSString *)yyyyMMddStringWithSecond:(NSTimeInterval)time {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy.MM.dd"];
    
    return [dateFormat stringFromDate:date];
}
//获取当前时间
+(NSString*)getCurrentTimes{
    
    return nil;
}

//获取当前时间戳有方法(以秒为单位)
+(NSString *)getNowTimeTimestamp {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
    
}

//获取当前时间戳 （以毫秒为单位）
+(NSString *)getNowTimeTimestamp3{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    
    return timeSp;
}

//获取指定时间后时间戳方法(以秒为单位)
+(NSString *)getAppointTimeWithSecond:(NSTimeInterval)second startTime:(NSDate *)startTime {
    
    NSDate * appointDate = [startTime initWithTimeIntervalSinceNow: second];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[appointDate timeIntervalSince1970]];
    
    return timeSp;
    
}

+(NSString *)twoTimestampSub:(NSString *)startTime endTime:(NSString *)endTime {
    NSDate *date11 = [NSDate dateWithTimeIntervalSince1970:[startTime doubleValue]];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time1 = [formatter1 stringFromDate: date11];
    
    
    NSDate *date22 = [NSDate dateWithTimeIntervalSince1970:[endTime doubleValue]];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time2 = [formatter2 stringFromDate: date22];
    
    
    
    // 2.将时间转换为date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    // 3.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 4.利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:date1 toDate:date2 options:0];
    // 5.输出结果
//    NSLog(@"两个时间相差%ld年%ld月%ld日%ld小时%ld分钟%ld秒", cmps.year, cmps.month, cmps.day, cmps.hour, cmps.minute, cmps.second);
//    NSString *hourStr ;
//    if (cmps.day > 0) {
//        hourStr = [NSString stringWithFormat:@"%ld",cmps.hour + cmps.day * 24];
//    } else {
//        hourStr = cmps.hour == 0 ? @"00" : [NSString stringWithFormat:@"0%ld",cmps.hour];
//        if (cmps.hour > 9) {
//            hourStr = @(cmps.hour).stringValue;
//        }
//    }

    NSString *minStr = cmps.minute == 0 ? @"00" : [NSString stringWithFormat:@"0%ld",cmps.minute + (cmps.hour + cmps.day * 24) *60];
    if (cmps.minute > 9) {
        minStr = @(cmps.minute).stringValue;
    }

    NSString *secStr = cmps.second == 0 ? @"00" : [NSString stringWithFormat:@"0%ld",cmps.second];
    if (cmps.second > 9) {
        secStr = @(cmps.second).stringValue;
    }
    
    NSString *timeString = [NSString stringWithFormat:@"%@:%@",minStr,secStr];
    return timeString;

}

//一个时间戳距离当前时间日分秒
+(NSString *)twoTimestampSub:(NSString *)oneTime nowTime:(NSString *)nowTime{
    // 1.确定时间
//    NSString *time1 = @"2015-06-23 12:18:15";
//    NSString *time2 = @"2015-06-28 10:10:10";
    
    
    NSDate *date11 = [NSDate dateWithTimeIntervalSince1970:[oneTime doubleValue]];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time1 = [formatter1 stringFromDate: date11];
    
    
    NSDate *date22 = [NSDate dateWithTimeIntervalSince1970:[nowTime doubleValue]];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time2 = [formatter2 stringFromDate: date22];
    
    
    
    // 2.将时间转换为date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    // 3.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 4.利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:date1 toDate:date2 options:0];
    // 5.输出结果
//    NSLog(@"两个时间相差%ld年%ld月%ld日%ld小时%ld分钟%ld秒", cmps.year, cmps.month, cmps.day, cmps.hour, cmps.minute, cmps.second);
    NSString * result = nil;
//    if (cmps.year && cmps.month && cmps.day && cmps.hour && cmps.minute && cmps.second) {
//        result = [NSString stringWithFormat:@"%ld年%ld月%ld日%ld小时%ld分钟%ld秒",cmps.year, cmps.month, cmps.day, cmps.hour, cmps.minute, cmps.second];
//    }else if (cmps.month && cmps.day && cmps.hour && cmps.minute && cmps.second){
//         result = [NSString stringWithFormat:@"%ld月%ld日%ld小时%ld分钟%ld秒", cmps.month, cmps.day, cmps.hour, cmps.minute, cmps.second];
//    }else if (cmps.day && cmps.hour && cmps.minute && cmps.second){
//        result = [NSString stringWithFormat:@"%ld日%ld小时%ld分钟%ld秒", cmps.day, cmps.hour, cmps.minute, cmps.second];
//    }else if (cmps.hour && cmps.minute && cmps.second){
//        result = [NSString stringWithFormat:@"%ld小时%ld分钟%ld秒", cmps.hour, cmps.minute, cmps.second];
//    }else if (cmps.minute && cmps.second){
//        result = [NSString stringWithFormat:@"%ld分钟%ld秒", cmps.minute, cmps.second];
//    }else if (cmps.second){
//        result = [NSString stringWithFormat:@"%ld秒", cmps.second];
//    }else{
//        result = @"0秒";
//    }
    if (cmps.year ) {
        result = [NSString stringWithFormat:@"%ld年前",(long)cmps.year];
    }else if (cmps.month){
        result = [NSString stringWithFormat:@"%ld月前", (long)cmps.month];
    }else if (cmps.day){
        result = [NSString stringWithFormat:@"%ld天前", (long)cmps.day];
    }else if (cmps.hour){
        result = [NSString stringWithFormat:@"%ld小时前", (long)cmps.hour];
    }else if (cmps.minute){
        result = [NSString stringWithFormat:@"%ld分钟前", (long)cmps.minute];
    }else if (cmps.second){
        result = [NSString stringWithFormat:@"%ld秒前", (long)cmps.second];
    }else{
        result = @"0秒";
    }
    return result;
}


//时间戳转化为实践
+(NSString *)timeStampChangeTime:(NSString *)timeStamp andFormatter:(NSString *)Formatter{
    
    // iOS 生成的时间戳是10位
    NSTimeInterval interval    =[timeStamp doubleValue];
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:Formatter];
    NSString *dateString       = [formatter stringFromDate: date];
    return dateString;
}

//秒数转化时分
+(NSString *)timeChangeMS:(NSInteger)time{

    return [NSString stringWithFormat:@"%02li:%02li",time/100%60,time%100];
}

@end
