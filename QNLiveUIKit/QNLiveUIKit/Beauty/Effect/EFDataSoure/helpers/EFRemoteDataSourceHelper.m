//
//  EFRemoteDataSourceHelper.m
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/6/16.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import "EFRemoteDataSourceHelper.h"
#import "NSDictionary+jsonFile.h"
#import "EFAuthorizeAdapter.h"
#import "EFResource.h"
#import "EFRemoteDataSourceHelper+groupInfos.h"
// !!!: 获取素材使用的user id
static NSString * const efSenseArMaterialServiceUserID = @"testUserID";

@implementation EFRemoteDataSourceHelper

/// 获取所有的material 分组以及对应的素材列表
/// @param completeSuccess 成功回调
/// @param completeFailure 失败回调
+(void) efFetchAllRemoteGroupsWithMaterialsOnSuccess:(void (^)(NSArray <EFMaterialGroup *>* arrMaterialGroups))completeSuccess onFailure:(void (^)(int iErrorCode , NSString *strMessage))completeFailure {
    
    NSArray<EFMaterialGroup *> *arrMaterialGroups = [self generateGroupsInfo];
    
    dispatch_group_t efDatasourceGroup = dispatch_group_create();
    __block bool flag =true;
    for (EFMaterialGroup * group in arrMaterialGroups) {
        dispatch_group_enter(efDatasourceGroup);
        [EFResource requestMaterialByGroupID:group.strGroupID success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            @synchronized (group) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *responseDict = responseObject;
                    NSArray *effects = responseDict[@"data"][@"effects"];
                    NSMutableArray *materialsArray = [NSMutableArray array];
                    for (NSInteger i = 0; i < effects.count; i ++) {
                        EFDataSourceModel *model = [EFDataSourceModel yy_modelWithJSON:effects[i]];
                        [materialsArray addObject:model];
                    }
                    group.materialsArray = materialsArray.copy;
                    dispatch_group_leave(efDatasourceGroup);
                } else {
                    DLog(@"请求数据失败 : %@的数据结构错误", group.strGroupName);
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
            flag = false;
            dispatch_group_leave(efDatasourceGroup);
        }];
    }
    dispatch_group_notify(efDatasourceGroup, dispatch_get_main_queue(), ^{
        DLog(@"网络请求结束");
        if (flag) {
            if (completeSuccess) completeSuccess(arrMaterialGroups);
        }else{
            if (completeFailure) completeFailure(-1,@"数据请求失败");
            
        }
        
    });
}

@end
