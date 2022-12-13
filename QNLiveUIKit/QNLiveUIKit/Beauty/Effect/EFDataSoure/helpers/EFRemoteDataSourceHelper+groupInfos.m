//
//  EFRemoteDataSourceHelper+groupInfos.m
//  SenseMeEffects
//
//  Created by 马浩萌 on 2022/5/11.
//  Copyright © 2022 SenseTime. All rights reserved.
//

#import "EFRemoteDataSourceHelper+groupInfos.h"

@implementation EFRemoteDataSourceHelper (groupInfos)

+(NSArray<EFMaterialGroup *> *)generateGroupsInfo {
    NSArray *dictArray = @[
        @{
            @"strGroupName": @"最新",
            @"strGroupID": @41
        },
        @{
            @"strGroupName": @"2D",
            @"strGroupID": @4
        },
        @{
            @"strGroupName": @"3D",
            @"strGroupID": @5
        },
        @{
            @"strGroupName": @"手势",
            @"strGroupID": @6
        },
        @{
            @"strGroupName": @"分割",
            @"strGroupID": @7
        },
        @{
            @"strGroupName": @"变形",
            @"strGroupID": @8
        },
        @{
            @"strGroupName": @"粒子",
            @"strGroupID": @9
        },
        @{
            @"strGroupName": @"动物",
            @"strGroupID": @10
        },
        @{
            @"strGroupName": @"影分身",
            @"strGroupID": @11
        },
        @{
            @"strGroupName": @"大头",
            @"strGroupID": @12
        },
        @{
            @"strGroupName": @"抠脸",
            @"strGroupID": @13
        },
        @{
            @"strGroupName": @"特效玩法",
            @"strGroupID": @14
        },
        @{
            @"strGroupName": @"Avatar",
            @"strGroupID": @15
        },
        @{
            @"strGroupName": @"TryOn",
            @"strGroupID": @16
        },
        @{
            @"strGroupName": @"眼影",
            @"strGroupID": @17
        },
        @{
            @"strGroupName": @"睫毛",
            @"strGroupID": @18
        },
        @{
            @"strGroupName": @"眉毛",
            @"strGroupID": @19
        },
        @{
            @"strGroupName": @"美瞳",
            @"strGroupID": @20
        },
        @{
            @"strGroupName": @"腮红",
            @"strGroupID": @21
        },
        @{
            @"strGroupName": @"修容",
            @"strGroupID": @22
        },
        @{
            @"strGroupName": @"眼线",
            @"strGroupID": @23
        },
        @{
            @"strGroupName": @"口红",
            @"strGroupID": @24
        },
        @{
            @"strGroupName": @"染发",
            @"strGroupID": @25
        },
        @{
            @"strGroupName": @"自然",
            @"strGroupID": @26
        },
        @{
            @"strGroupName": @"轻妆",
            @"strGroupID": @27
        },
        @{
            @"strGroupName": @"流行",
            @"strGroupID": @28
        },
        @{
            @"strGroupName": @"TryOn口红",
            @"strGroupID": @29
        },
        @{
            @"strGroupName": @"TryOn染发",
            @"strGroupID": @30
        },
        @{
            @"strGroupName": @"TryOn唇线",
            @"strGroupID": @31
        },
        @{
            @"strGroupName": @"TryOn眼影",
            @"strGroupID": @32
        },
        @{
            @"strGroupName": @"TryOn眼线",
            @"strGroupID": @33
        },
        @{
            @"strGroupName": @"TryOn眼印",
            @"strGroupID": @34
        },
        @{
            @"strGroupName": @"TryOn眼睫毛",
            @"strGroupID": @35
        },
        @{
            @"strGroupName": @"TryOn眉毛",
            @"strGroupID": @36
        },
        @{
            @"strGroupName": @"TryOn腮红",
            @"strGroupID": @37
        },
        @{
            @"strGroupName": @"TryOn修容",
            @"strGroupID": @38
        },
        @{
            @"strGroupName": @"TryOn粉底",
            @"strGroupID": @39
        },
        @{
            @"strGroupName": @"漫画脸",
            @"strGroupID": @40
        }
    ];
    
    NSArray<EFMaterialGroup *> *result = [NSArray yy_modelArrayWithClass:EFMaterialGroup.class json:dictArray];
    return result;
}

@end
