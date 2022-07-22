//
//  STDefaultSettingDataSourseGenerator.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/5/29.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STNewBeautyCollectionViewModel, STCollectionViewDisplayModel, STMakeupDataModel, STCustomMemoryCache;

/// 所有的贴纸列表、美颜效果等列表数据源的生成器
@interface STDefaultSettingDataSourseGenerator : NSObject

/// 生成整体效果数据源
/// @param callback callback
-(instancetype)stm_generatWholeMakeUpDataSource:(void(^)(NSArray <STNewBeautyCollectionViewModel *> * datasource))callback;

/// 生成基础美颜效果数据源
/// @param callback callback
-(instancetype)stm_generatBaseBeautyDataSource:(void(^)(NSArray <STNewBeautyCollectionViewModel *> * datasource))callback;

/// 生成美形效果数据源
/// @param callback callback
-(instancetype)stm_generatBeautyShapeDataSource:(void(^)(NSArray <STNewBeautyCollectionViewModel *> * datasource))callback;

/// 生成微整形效果数据源
/// @param callback callback
-(instancetype)stm_generatMicroSurgeryDataSource:(void(^)(NSArray <STNewBeautyCollectionViewModel *> * datasource))callback;

/// 生成美妆效果数据源
/// @param wholeMakeCallback 整妆
/// @param lipsCallback 口红
/// @param cheekCallback 腮红
/// @param browsCallback 眉毛
/// @param eyeshadowCallback 眼影
/// @param eyelinerCallback 眼线
/// @param eyelashCallback 眼睫毛
/// @param noseCallback 修容
/// @param eyeballCallback 美瞳
/// @param maskhairCallback 染发
-(instancetype)stm_generatMakeupDataSourceWholeMake:(void(^)(NSArray <STMakeupDataModel *> * wholeMakeDatasource))wholeMakeCallback andLips:(void(^)(NSArray <STMakeupDataModel *> * lipsDatasource))lipsCallback andCheek:(void(^)(NSArray <STMakeupDataModel *> * cheekDatasource))cheekCallback andBrows:(void(^)(NSArray <STMakeupDataModel *> * browsDatasource))browsCallback andEyeshadow:(void(^)(NSArray <STMakeupDataModel *> * eyeshadowDatasource))eyeshadowCallback andEyeliner:(void(^)(NSArray <STMakeupDataModel *> * eyelinerDatasource))eyelinerCallback andEyelash:(void(^)(NSArray <STMakeupDataModel *> * eyelashDatasource))eyelashCallback andNose:(void(^)(NSArray <STMakeupDataModel *> * noseDatasource))noseCallback andEyeball:(void(^)(NSArray <STMakeupDataModel *> * eyeballDatasource))eyeballCallback andMaskhair:(void(^)(NSArray <STMakeupDataModel *> * maskhairDatasource))maskhairCallback;

/// 生成滤镜数据源
/// @param callback callback
-(instancetype)stm_generatFilterDataSource:(void(^)(NSDictionary <id, NSArray <STCollectionViewDisplayModel *> *> * datasource))callback;

/// 生成调整效果数据源
/// @param callback callback
-(instancetype)stm_generatAdjustDataSource:(void(^)(NSArray <STNewBeautyCollectionViewModel *> * datasource))callback;

/// 生成贴纸素材数据源
/// @param callback callback
//-(instancetype)stm_generatMaterialsDataSource:(void(^)(STCustomMemoryCache * datasource))callback;

@end
