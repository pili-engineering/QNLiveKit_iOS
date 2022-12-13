//
//  EFSenseArMaterialDataModels.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/6/4.
//

#import <Foundation/Foundation.h>
#import "SenseArMaterialService.h"
#import "EFDataSourcing.h"
#import <YYModel/YYModel.h>

#pragma mark - EFDataSourceModel
@interface EFDataSourceModel : NSObject <EFDataSourcing, YYModel, NSCopying>

@property (nonatomic, readwrite, assign) BOOL efFromBundle;

@property (nonatomic, readwrite, assign) BOOL efIsLocal;

@property (nonatomic, copy) NSString *strID;

/// 名称
@property (nonatomic, readwrite, copy) NSString * efName;
/// 别名
@property (nonatomic, readwrite, copy) NSString * efAlias;
/// 图标名称
@property (nonatomic, readwrite, copy) NSString * efThumbnailDefault;
/// 选中图标名称
@property (nonatomic, readonly, copy) NSString * efThumbnailHighlight;
/// 效果服务器地址
@property (nonatomic , copy) NSString *strMaterialURL;
/// 效果本地地址
@property (nonatomic, readwrite, copy) NSString * efMaterialPath;
/// 效果类型 （sdk枚举 + path_f + mode_f + mode_v）
@property (nonatomic, readwrite, assign) NSUInteger efType;
/// 下级效果列表
@property (nonatomic, readwrite, strong) NSArray <EFDataSourcing> * efSubDataSources;

@property (nonatomic, readwrite, assign) NSUInteger efRoute;

/// 表示是否可以叠加（本地多贴纸）
@property (nonatomic, readwrite, assign) BOOL efIsMulti;

-(void)setEfMaterials:(NSArray<EFDataSourceModel *> *)efMaterials;

@end

@interface EFMaterialGroup : NSObject <YYModel>

@property (nonatomic, copy) NSString *strGroupName;
@property (nonatomic, strong) NSNumber *strGroupID;
@property (nonatomic, copy) NSArray<EFDataSourcing> *materialsArray;

@end
