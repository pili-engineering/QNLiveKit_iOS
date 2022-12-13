//
//  STCoreStateManagement.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/5/24.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCoreStateManagementValueChangeDelegate.h"
#import "EFSenseArMaterialDataModels.h"

// from previous
#import "STCollectionView.h" // TODO: model应从view层分离出来
#import "EffectsCollectionViewCell.h" // TODO: model应从view层分离出来
#import "STCustomMemoryCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface STCoreStateManagement : NSObject

/// 观察各种models值发生改变的delegate
@property (nonatomic, weak) id<STCoreStateManagementValueChangeDelegate> valueChangeDelegate;

#pragma mark - 数据源
/// 存储所有的贴纸素材 本地+服务器（NSMutableDictionary）
@property (nonatomic, strong) STCustomMemoryCache * effectsDataSource;
/// 当前选中的贴纸类型
@property (nonatomic, assign) STEffectsType curEffectStickerType;
/// 当前选中的贴纸类型下所有贴纸列表
@property (nonatomic, strong) NSArray * arrCurrentModels;

#pragma mark - models
/// 当前滤镜model
@property (nonatomic, strong) STCollectionViewDisplayModel * filterModel;
/// 保存当前贴纸model
@property (nonatomic, strong) EffectsCollectionViewCellModel *prepareModel;
/// 保存沙盒中添加的已经被选中的贴纸（此种类型可叠加）（有可能为多个）
@property (nonatomic, strong) NSMutableArray * addedStickerArray;

#pragma mark - current
/// 当前选中的整体效果model
@property (nonatomic, strong) STNewBeautyCollectionViewModel * currentWholeMakeUpModel;

#pragma mark - flags
/// 标识当前贴纸是否有猫脸
@property (nonatomic, assign) BOOL needDetectAnimal;
/// 当前效果类型？ 各种贴纸 各种整妆 各种滤镜 各种微整形之类的
@property (nonatomic, assign) STEffectsType curEffectBeautyType;

#pragma mark - others
/// 保存通过sdk st_mobile_effect_get_detect_config获取到的贴纸的信息——sdk中的注释：返回检测配置选项, 每一位分别代表该位对应检测选项, 对应状态详见st_mobile_human_action.h中, 如ST_MOBILE_FACE_DETECT等
@property (nonatomic, assign) unsigned long long stickerConf;

@end

NS_ASSUME_NONNULL_END
