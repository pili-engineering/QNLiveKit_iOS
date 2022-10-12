//
//  EFRemoteDataSourceHelper+groupInfos.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2022/5/11.
//  Copyright © 2022 SenseTime. All rights reserved.
//

#import "EFRemoteDataSourceHelper.h"
#import "EFSenseArMaterialDataModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface EFRemoteDataSourceHelper (groupInfos)

+(NSArray<EFMaterialGroup *> *)generateGroupsInfo;

@end

NS_ASSUME_NONNULL_END
