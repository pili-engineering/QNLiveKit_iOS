//
//  QNPersonalViewModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/22.
//

#import "QNPersonalViewModel.h"
#import "QNPersonInfoModel.h"
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>

@implementation QNPersonalViewModel

+ (void)requestPersonInfo:(void (^)(QNPersonInfoModel * _Nonnull))success {
    
    [QNNetworkUtil getRequestWithAction:@"accountInfo" params:nil success:^(NSDictionary *responseData) {
        
        QNPersonInfoModel *infoModel = [QNPersonInfoModel mj_objectWithKeyValues:responseData];
        success(infoModel ?: nil);
        
    } failure:^(NSError *error) {
            
    }];
}

+ (void)changePersonInfoWithNickName:(NSString *)nickName success:(nonnull void (^)(QNPersonInfoModel * _Nonnull))success {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"nickname"] = nickName;
    
    [QNNetworkUtil postRequestWithAction:@"accountInfo" params:params success:^(NSDictionary *responseData) {
        
        QNPersonInfoModel *infoModel = [QNPersonInfoModel mj_objectWithKeyValues:responseData];
        success(infoModel ?: nil);
        
    } failure:^(NSError *error) {
        
    }];
}

@end
