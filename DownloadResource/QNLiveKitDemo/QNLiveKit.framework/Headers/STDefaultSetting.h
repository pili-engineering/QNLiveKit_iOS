//
//  STDefaultSetting.h
//  SenseMeEffects
//
//  Created by sunjian on 2021/2/24.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCollectionView.h"
#import "STFilterView.h"
#import "STMakeupDataModel.h"
#import <PLSTArEffects/PLSTArEffects.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, STVCType){
    STVCTypePreview,
    STVCTypePhoto,
    STVCTypeVideo,
};

@interface STDefaultSetting : NSObject

@property (nonatomic, assign) PLSTEffectManager *effectManager;

//@property (nonatomic, strong) EAGLContext *glContext;

@property (nonatomic, readonly, assign) BOOL isFirstLaunch;

@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *wholeMakeUpModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *microSurgeryModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *baseBeautyModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *beautyShapeModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *adjustModels;

@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_wholeMakeArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_lipsArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_cheekArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_browsArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_eyeshadowArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_eyelinerArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_eyelashArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_noseArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_eyeballArr;
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *m_maskhairArr;

@property (nonatomic, strong) NSMutableDictionary *filterDataSources; // 滤镜DataSource

//@property (nonatomic, strong) STStickerWithFilter *stierkWithFilter;

@property (nonatomic, assign) STEffectsType scrollType; // current *美颜 type
@property (nonatomic, strong) STNewBeautyCollectionViewModel *beautyModelFromCache; // current *美颜detail 状态
@property (nonatomic, strong) STCollectionViewDisplayModel *filterModelFromCache; // current *滤镜detail 状态
//单例状态，填充完之后，要记得清楚
@property (nonatomic, strong) NSMutableArray<STMakeupDataModel *> *makeUpModelsFormCache; // current 美妆 状态

@property (nonatomic, assign) float iWholeFilterValue;
@property (nonatomic, assign) float iWholeMakeUpValue;
@property (nonatomic, assign) float oWholeFilterValue;
@property (nonatomic, assign) float oWholeMakeUpValue;
@property (nonatomic, assign) int   wholeEffectsIndex;

+ (instancetype)sharedInstace;

//- (void)setupDefaultValus;
//- (void)setupMakeUpDataSources;

- (void)setDefaultBeautyValues;

- (void)clearStickerValue;

- (void)zeroValue;

- (void)updateCurrentDataSouece:(STVCType)vcType;

- (void)updateLastParamsCurType:(STEffectsType)effectType
               wholeEffectModel:(STNewBeautyCollectionViewModel *)wholeEffectModel
                      baseModel:(STNewBeautyCollectionViewModel *)beautyModel
                         filter:(STCollectionViewDisplayModel *)filterModel
                         makeup:(NSMutableSet<STMakeupDataModel *> *)makeUps
                  needWriteFile:(BOOL)writeFile;

- (void)saveCurrentValuesToDiskWillQuit:(BOOL)quit;

- (void)getDefaultValueFromDisk;

- (STEffectsType)getFirstLoadType;

- (void)getDefaultValue;

- (void)updateCurrentBeautyValue:(STNewBeautyCollectionViewModel *)model;

- (void)updateValueWithWholeType:(STBeautyType)wholeType;

- (void)setBeautyParamsWithHandle:(st_handle_t *)handle;

- (void)setBeuatyParamsWithHandle:(st_handle_t *)handle model:(STNewBeautyCollectionViewModel *)model;

- (void)setBeautyParamsWithBeautyInfo:(st_effect_beauty_info_t)beautyInfo;

- (void)resetBeautyParams;

- (void)resetBeautyParamsWithType:(STEffectsType)type;

- (BOOL)checkActiveCodeWithData:(NSData *)dataLicense;

- (void)zeroMakeupWithHandle:(st_handle_t *)handle withType:(STEffectsType)type;

- (void)restoreBeforeStickerParametersMenu:(BOOL)Menu;

- (void)removeSticker;
@end

NS_ASSUME_NONNULL_END
