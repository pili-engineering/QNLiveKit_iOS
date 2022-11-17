//
//  EFAuthorizeAdapter.m
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/7/8.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import "EFAuthorizeAdapter.h"


NSString *efSenseArMaterialServiceAppID = @"6dc0af51b69247d0af4b0a676e11b5ee";
NSString *efSenseArMaterialServiceAppkey = @"e4156e4d61b040d2bcbf896c798d06e3";
// !!!: 鉴权AppID
//static NSString * const efSenseArMaterialServiceAppID = @"6dc0af51b69247d0af4b0a676e11b5ee";
//static NSString * const efSenseArMaterialServiceAppID = @"08472433715451c8544f5168181d559";
// !!!: 鉴权Appkey
//static NSString * const efSenseArMaterialServiceAppkey = @"e4156e4d61b040d2bcbf896c798d06e3";
//static NSString * const efSenseArMaterialServiceAppkey = @"e0b08686c234d598b47fe037796b8d6";
@implementation EFAuthorizeAdapter

+(void)efAuthorizeWithCallback:(void(^)(BOOL isAuthorized, SenseArAuthorizeError code ,SenseArMaterialService * service))callback {
    SenseArMaterialService * service = [SenseArMaterialService sharedInstance];
    [[SenseArMaterialService sharedInstance] setMaxCacheSize:800000000];
    if ([SenseArMaterialService isAuthorized]) {
        if (callback) callback(YES, 0 ,service);
        return;
    }
    [service authorizeWithAppID:efSenseArMaterialServiceAppID appKey:efSenseArMaterialServiceAppkey onSuccess:^{
        if (callback) callback(YES, 0 ,service);
    } onFailure:^(SenseArAuthorizeError iErrorCode, NSString *errMessage) {
        if (callback) callback(NO, iErrorCode ,service);
    }];
}

@end
