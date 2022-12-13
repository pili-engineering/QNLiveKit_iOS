//
//  EFRemoteDataSourceHelper.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/6/16.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EFSenseArMaterialDataModels.h"
NS_ASSUME_NONNULL_BEGIN

@interface EFRemoteDataSourceHelper : NSObject

+(void)efFetchAllRemoteGroupsWithMaterialsOnSuccess:(void (^)(NSArray <EFMaterialGroup *>* arrMaterialGroups))completeSuccess onFailure:(void (^)(int iErrorCode , NSString *strMessage))completeFailure;

@end

NS_ASSUME_NONNULL_END
