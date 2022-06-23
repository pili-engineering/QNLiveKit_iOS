//
//  QNSolutionListModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/14.
//

#import "QNSolutionListModel.h"
#import <MJExtension/MJExtension.h>

@implementation QNSolutionListModel

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [QNSolutionItemModel class]};
}

@end

@implementation QNSolutionItemModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID" : @"id"};
}
@end

