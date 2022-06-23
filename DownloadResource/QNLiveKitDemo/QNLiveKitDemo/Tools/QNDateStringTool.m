//
//  QNDateStringTool.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/23.
//

#import "QNDateStringTool.h"

@implementation QNDateStringTool

+ (NSString *)timeStringWithTimeStamp:(NSString *)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
     [dateFormat setDateFormat:@"yyyy年MM月dd日HH:mm"];
    NSString* timeString=[dateFormat stringFromDate:date];
    return timeString;
}

@end
