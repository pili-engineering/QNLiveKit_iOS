//
//  STDefaultSettingDataSourseGenerator.m
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/5/29.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import "STDefaultSettingDataSourseGenerator.h"
#import "STParamUtil.h"
#import <UIKit/UIImage.h>
#import "STCollectionView.h"
#import "STMakeupDataModel.h"
#import "SenseArMaterialService.h"
#import "STCustomMemoryCache.h"
#import "EffectsCollectionViewCell.h"
#import <YYModel/YYModel.h>
@implementation STDefaultSettingDataSourseGenerator

/// 生成调整效果数据源
/// @param callback callback
- (instancetype)stm_generatAdjustDataSource:(void (^)(NSArray<STNewBeautyCollectionViewModel *> *))callback {
    NSArray<STNewBeautyCollectionViewModel *> * adjustModels = @[
        getModel([UIImage imageNamed:@"contrast"], [UIImage imageNamed:@"contrast_selected"], NSLocalizedString(@"对比度", nil), 0, NO, 0, STEffectsTypeBeautyAdjust, STBeautyTypeContrast),
        getModel([UIImage imageNamed:@"saturation"], [UIImage imageNamed:@"saturation_selected"], NSLocalizedString(@"饱和度", nil), 0, NO, 1, STEffectsTypeBeautyAdjust, STBeautyTypeSaturation),
        getModel([UIImage imageNamed:@"锐化-白"], [UIImage imageNamed:@"锐化-紫"], NSLocalizedString(@"锐化", nil), 50, NO, 2, STEffectsTypeBeautyAdjust, STBeautyTypeSharpen),
        getModel([UIImage imageNamed:@"Clarity.png"], [UIImage imageNamed:@"Clarity_selected.png"], NSLocalizedString(@"清晰度", nil), 20, NO, 3, STEffectsTypeBeautyAdjust, STBeautyTypeClarity),
    ];
    if (callback) callback(adjustModels);
    return self;
}

/// 生成美形效果数据源
/// @param callback callback
-(instancetype)stm_generatBeautyShapeDataSource:(void (^)(NSArray<STNewBeautyCollectionViewModel *> *))callback {
    NSArray<STNewBeautyCollectionViewModel *> * beautyShapeModels = @[
        getModel([UIImage imageNamed:@"shoulian"], [UIImage imageNamed:@"shoulian_selected"], NSLocalizedString(@"瘦脸", nil), 34, NO, 0, STEffectsTypeBeautyShape, STBeautyTypeShrinkFace),
        getModel([UIImage imageNamed:@"dayan"], [UIImage imageNamed:@"dayan_selected"], NSLocalizedString(@"大眼", nil), 29, NO, 1, STEffectsTypeBeautyShape, STBeautyTypeEnlargeEyes),
        getModel([UIImage imageNamed:@"xiaolian"], [UIImage imageNamed:@"xiaolian_selected"], NSLocalizedString(@"小脸", nil), 10, NO, 2, STEffectsTypeBeautyShape, STBeautyTypeShrinkJaw),
        getModel([UIImage imageNamed:@"zhailian2"], [UIImage imageNamed:@"zhailian2_selected"], NSLocalizedString(@"窄脸", nil), 25, NO, 3, STEffectsTypeBeautyShape, STBeautyTypeNarrowFace),
        getModel([UIImage imageNamed:@"round"], [UIImage imageNamed:@"round_selected"], NSLocalizedString(@"圆眼", nil), 7, NO, 4, STEffectsTypeBeautyShape, STBeautyTypeRoundEye)
    ];
    if (callback) callback(beautyShapeModels);
    return self;
}

/// 生成基础美颜效果数据源
/// @param callback callback
- (instancetype)stm_generatBaseBeautyDataSource:(void (^)(NSArray<STNewBeautyCollectionViewModel *> *))callback {
    NSArray <STNewBeautyCollectionViewModel *> * baseBeautyModels = @[
        getModel([UIImage imageNamed:@"meibai"], [UIImage imageNamed:@"meibai_selected"], NSLocalizedString(@"美白1", nil), 0, NO, 0, STEffectsTypeBeautyBase, STBeautyTypeWhiten1),
        getModel([UIImage imageNamed:@"meibai"], [UIImage imageNamed:@"meibai_selected"], NSLocalizedString(@"美白2", nil), 0, NO, 1, STEffectsTypeBeautyBase, STBeautyTypeWhiten2),
        getModel([UIImage imageNamed:@"meibai"], [UIImage imageNamed:@"meibai_selected"], NSLocalizedString(@"美白3", nil), 50, NO, 2, STEffectsTypeBeautyBase, STBeautyTypeWhiten3),
        getModel([UIImage imageNamed:@"hongrun"], [UIImage imageNamed:@"hongrun_selected"], NSLocalizedString(@"红润", nil), 0, NO, 3, STEffectsTypeBeautyBase, STBeautyTypeRuddy),
        getModel([UIImage imageNamed:@"mopi"], [UIImage imageNamed:@"mopi_selected"], NSLocalizedString(@"磨皮1", nil), 0, NO, 4, STEffectsTypeBeautyBase, STBeautyTypeDermabrasion1),
        getModel([UIImage imageNamed:@"mopi"], [UIImage imageNamed:@"mopi_selected"], NSLocalizedString(@"磨皮2", nil), 50, NO, 5, STEffectsTypeBeautyBase, STBeautyTypeDermabrasion2),
    ];
    if (callback) callback(baseBeautyModels);
    return self;
}

/// 生成整体效果数据源
/// @param callback callback
-(instancetype)stm_generatWholeMakeUpDataSource:(void(^)(NSArray <STNewBeautyCollectionViewModel *> * datasource))callback {
    NSArray <STNewBeautyCollectionViewModel *> * wholeMakeUpModels = @[
        getModel([UIImage imageNamed:@"default"], [UIImage imageNamed:@"default"], NSLocalizedString(@"Default", nil), 0, NO, 0, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupNvshen),
//        getModel([UIImage imageNamed:@"tianran"], [UIImage imageNamed:@"tianran"], NSLocalizedString(@"tianran", nil), 0, NO, 1, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupTianran),
        getModel([UIImage imageNamed:@"sweetgirl"], [UIImage imageNamed:@"sweetgirl"], NSLocalizedString(@"sweetgirl", nil), 0, NO, 2, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupSweetgirl),
//        getModel([UIImage imageNamed:@"oxygen"], [UIImage imageNamed:@"oxygen"], NSLocalizedString(@"oxygen", nil), 0, NO, 3, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupOxygen),
//        getModel([UIImage imageNamed:@"redwine"], [UIImage imageNamed:@"redwine"], NSLocalizedString(@"redwine", nil), 0, NO, 4, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupRedwine),
        getModel([UIImage imageNamed:@"sweet"], [UIImage imageNamed:@"sweet"], NSLocalizedString(@"sweet", nil), 0, NO, 5, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupSweet),
        getModel([UIImage imageNamed:@"western"], [UIImage imageNamed:@"western"], NSLocalizedString(@"western", nil), 0, NO, 6, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupWestern),
//        getModel([UIImage imageNamed:@"whitetea"], [UIImage imageNamed:@"whitetea"], NSLocalizedString(@"whiteTea", nil), 0, NO, 7, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupWhitetea),
//        getModel([UIImage imageNamed:@"zhigan"], [UIImage imageNamed:@"zhigan"], NSLocalizedString(@"zhigan", nil), 0, NO, 8, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupZhigan),
//        getModel([UIImage imageNamed:@"deep"], [UIImage imageNamed:@"deep"], NSLocalizedString(@"deep", nil), 0, NO, 9, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupDeep),
//        getModel([UIImage imageNamed:@"ziranzipai"], [UIImage imageNamed:@"ziranzipai_selected"], NSLocalizedString(@"自拍自然", nil), 0, NO, 10, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupZPZiRan),
//        getModel([UIImage imageNamed:@"zipaiyuanqi"], [UIImage imageNamed:@"zipaiyuanqi_selected"], NSLocalizedString(@"自拍元气", nil), 0, NO, 11, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupZPYuanQi),
//        getModel([UIImage imageNamed:@"zhiboziran"], [UIImage imageNamed:@"zhiboziran_selected"], NSLocalizedString(@"直播自然", nil), 0, NO, 12, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupZBZiRan),
//        getModel([UIImage imageNamed:@"zhiboyuanqi"], [UIImage imageNamed:@"zhiboyuanqi_selected"], NSLocalizedString(@"直播元气", nil), 0, NO, 13, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupZBYuanQi),
//        getModel([UIImage imageNamed:@"zipaiziran"], [UIImage imageNamed:@"zipaiziran_selected"], NSLocalizedString(@"直播原画", nil), 0, NO, 14, STEffectsTypeBeautyWholeMakeup, STBeautyTypeMakeupZBYuanHua),
    ];
    if (callback) callback(wholeMakeUpModels);
    return self;
}

/// 生成微整形效果数据源
/// @param callback callback
-(instancetype)stm_generatMicroSurgeryDataSource:(void (^)(NSArray<STNewBeautyCollectionViewModel *> *))callback {
    NSArray<STNewBeautyCollectionViewModel *> * microSurgeryModels = @[
        getModel([UIImage imageNamed:@"smallhead"], [UIImage imageNamed:@"smallheadselect"], NSLocalizedString(@"小头", nil), 0, NO, 0, STEffectsTypeBeautyMicroSurgery, STBeautyTypeHead),
        getModel([UIImage imageNamed:@"zhailian"], [UIImage imageNamed:@"zhailian_selected"], NSLocalizedString(@"瘦脸型", nil), 45, NO, 1, STEffectsTypeBeautyMicroSurgery, STBeautyTypeThinFaceShape),
        getModel([UIImage imageNamed:@"xiaba"], [UIImage imageNamed:@"xiaba_selected"], NSLocalizedString(@"下巴", nil), 20, NO, 2, STEffectsTypeBeautyMicroSurgery, STBeautyTypeChin),
        getModel([UIImage imageNamed:@"etou"], [UIImage imageNamed:@"etou_selected"], NSLocalizedString(@"额头", nil), 0, NO, 3, STEffectsTypeBeautyMicroSurgery, STBeautyTypeHairLine),
        getModel([UIImage imageNamed:@"苹果机-白"], [UIImage imageNamed:@"苹果机-紫"], NSLocalizedString(@"苹果肌", nil), 30, NO, 4, STEffectsTypeBeautyMicroSurgery, STBeautyTypeAppleMusle),
        getModel([UIImage imageNamed:@"shoubiyi"], [UIImage imageNamed:@"shoubiyi_selected"], NSLocalizedString(@"瘦鼻翼", nil), 21, NO, 5, STEffectsTypeBeautyMicroSurgery, STBeautyTypeNarrowNose),
        getModel([UIImage imageNamed:@"changbi"], [UIImage imageNamed:@"changbi_selected"], NSLocalizedString(@"长鼻", nil), 0, NO, 6, STEffectsTypeBeautyMicroSurgery, STBeautyTypeLengthNose),
        getModel([UIImage imageNamed:@"侧脸隆鼻-白"], [UIImage imageNamed:@"侧脸隆鼻-紫"], NSLocalizedString(@"侧脸隆鼻", nil), 10, NO, 7, STEffectsTypeBeautyMicroSurgery, STBeautyTypeProfileRhinoplasty),
        getModel([UIImage imageNamed:@"zuixing"], [UIImage imageNamed:@"zuixing_selected"], NSLocalizedString(@"嘴形", nil), 51, NO, 8, STEffectsTypeBeautyMicroSurgery, STBeautyTypeMouthSize),
        getModel([UIImage imageNamed:@"suorenzhong"], [UIImage imageNamed:@"suorenzhong_selected"], NSLocalizedString(@"缩人中", nil), 0, NO, 9, STEffectsTypeBeautyMicroSurgery, STBeautyTypeLengthPhiltrum),
        getModel([UIImage imageNamed:@"眼睛距离调整-白"], [UIImage imageNamed:@"眼睛距离调整-紫"], NSLocalizedString(@"眼距", nil), -23, NO, 10, STEffectsTypeBeautyMicroSurgery, STBeautyTypeEyeDistance),
        getModel([UIImage imageNamed:@"眼睛角度微调-白"], [UIImage imageNamed:@"眼睛角度微调-紫"], NSLocalizedString(@"眼睛角度", nil), 0, NO, 11, STEffectsTypeBeautyMicroSurgery, STBeautyTypeEyeAngle),
        getModel([UIImage imageNamed:@"开眼角-白"], [UIImage imageNamed:@"开眼角-紫"], NSLocalizedString(@"开眼角", nil), 0, NO, 12, STEffectsTypeBeautyMicroSurgery, STBeautyTypeOpenCanthus),
        getModel([UIImage imageNamed:@"亮眼-白"], [UIImage imageNamed:@"亮眼-紫"], NSLocalizedString(@"亮眼", nil), 25, NO, 13, STEffectsTypeBeautyMicroSurgery, STBeautyTypeBrightEye),
        getModel([UIImage imageNamed:@"去黑眼圈-白"], [UIImage imageNamed:@"去黑眼圈-紫"], NSLocalizedString(@"祛黑眼圈", nil), 69, NO, 14, STEffectsTypeBeautyMicroSurgery, STBeautyTypeRemoveDarkCircles),
        getModel([UIImage imageNamed:@"去法令纹-白"], [UIImage imageNamed:@"去法令纹-紫"], NSLocalizedString(@"祛法令纹", nil), 60, NO, 15, STEffectsTypeBeautyMicroSurgery, STBeautyTypeRemoveNasolabialFolds),
        getModel([UIImage imageNamed:@"牙齿美白-白"], [UIImage imageNamed:@"牙齿美白-紫"], NSLocalizedString(@"白牙", nil), 20, NO, 16, STEffectsTypeBeautyMicroSurgery, STBeautyTypeWhiteTeeth),
        getModel([UIImage imageNamed:@"瘦颧骨-白"], [UIImage imageNamed:@"瘦颧骨-紫"], NSLocalizedString(@"瘦颧骨", nil), 36, NO, 17, STEffectsTypeBeautyMicroSurgery, STBeautyTypeShrinkCheekbone),
        getModel([UIImage imageNamed:@"开外眼角-白"], [UIImage imageNamed:@"开外眼角-紫"], NSLocalizedString(@"开外眼角", nil), 0, NO, 18, STEffectsTypeBeautyMicroSurgery, STBeautyTypeOpenExternalCanthusRatio),
    ];
    if (callback) callback(microSurgeryModels);
    return self;
}

/// 生成滤镜数据源
/// @param callback callback
-(instancetype)stm_generatFilterDataSource:(void(^)(NSDictionary <id, NSArray <STCollectionViewDisplayModel *> *> * datasource))callback {
    NSMutableDictionary * filterDataSources = [NSMutableDictionary dictionary];
    [filterDataSources setObject:[STParamUtil getFilterModelsByType:STEffectsTypeFilterScenery] forKey:@(STEffectsTypeFilterScenery)];
    [filterDataSources setObject:[STParamUtil getFilterModelsByType:STEffectsTypeFilterPortrait] forKey:@(STEffectsTypeFilterPortrait)];
    [filterDataSources setObject:[STParamUtil getFilterModelsByType:STEffectsTypeFilterStillLife] forKey:@(STEffectsTypeFilterStillLife)];
    [filterDataSources setObject:[STParamUtil getFilterModelsByType:STEffectsTypeFilterDeliciousFood] forKey:@(STEffectsTypeFilterDeliciousFood)];
    if (callback) callback([filterDataSources copy]);
    return self;
}

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
-(instancetype)stm_generatMakeupDataSourceWholeMake:(void (^)(NSArray<STMakeupDataModel *> *))wholeMakeCallback andLips:(void (^)(NSArray<STMakeupDataModel *> *))lipsCallback andCheek:(void (^)(NSArray<STMakeupDataModel *> *))cheekCallback andBrows:(void (^)(NSArray<STMakeupDataModel *> *))browsCallback andEyeshadow:(void (^)(NSArray<STMakeupDataModel *> *))eyeshadowCallback andEyeliner:(void (^)(NSArray<STMakeupDataModel *> *))eyelinerCallback andEyelash:(void (^)(NSArray<STMakeupDataModel *> *))eyelashCallback andNose:(void (^)(NSArray<STMakeupDataModel *> *))noseCallback andEyeball:(void (^)(NSArray<STMakeupDataModel *> *))eyeballCallback andMaskhair:(void (^)(NSArray<STMakeupDataModel *> *))maskhairCallback {
    
    [self downDatasource:^(BOOL success) {
        
        //口红：1.先加载本地素材 2.加载服务器素材
        NSMutableArray * m_lipsArr = [[self getLocalMaterial:@"lips" bmpType:STBMPTYPE_LIP needAddNoneItem:YES] mutableCopy];
        
        [self fetchMaterialsAndReloadDataWithGroupID:@"4a1cb40c732146ecbf7857c3052809e6" type:STBMPTYPE_LIP needAddNoneItem:NO localDatasource:m_lipsArr callback:lipsCallback];

        //腮红：1.先加载本地素材 2.加载服务器素材
        NSMutableArray * m_cheekArr = [[self getLocalMaterial:@"blush"
                                                      bmpType:STBMPTYPE_CHEEK
                                              needAddNoneItem:YES] mutableCopy];
        [self fetchMaterialsAndReloadDataWithGroupID:@"8563a7afe8234db683752e40efe460bd" type:STBMPTYPE_CHEEK needAddNoneItem:NO localDatasource:m_cheekArr callback:cheekCallback];
        
        //修容：1.先加载本地素材 2.加载服务器素材
        NSMutableArray * m_noseArr = [[self getLocalMaterial:@"face"
                                                     bmpType:STBMPTYPE_NOSE
                                             needAddNoneItem:YES] mutableCopy];
        [self fetchMaterialsAndReloadDataWithGroupID:@"ee3e45997b584b2b8f3ad976f500c62c"
                                                type:STBMPTYPE_NOSE
                                     needAddNoneItem:NO localDatasource:m_noseArr callback:noseCallback];
        
        //眉毛：1.先加载本地素材 2.加载服务器素材
        NSMutableArray * m_browsArr = [[self getLocalMaterial:@"brow"
                                                      bmpType:STBMPTYPE_EYE_BROW
                                              needAddNoneItem:YES] mutableCopy];
        [self fetchMaterialsAndReloadDataWithGroupID:@"913a02bde7834109934030231c7517a7"
                                                type:STBMPTYPE_EYE_BROW
                                     needAddNoneItem:NO localDatasource:m_browsArr callback:browsCallback];
        //眼影
        NSMutableArray * m_eyeshadowArr = [[self getLocalMaterial:@"eyeshadow"
                                                          bmpType:STBMPTYPE_EYE_SHADOW
                                                  needAddNoneItem:YES] mutableCopy];
        [self fetchMaterialsAndReloadDataWithGroupID:@"855afaa09ced4560bc029ec09eeef950"
                                                type:STBMPTYPE_EYE_SHADOW
                                     needAddNoneItem:NO localDatasource:m_eyeshadowArr callback:eyeshadowCallback];
        //眼线
        [self fetchMaterialsAndReloadDataWithGroupID:@"231a9fc91e0c4218977f2e4002a5bc84"
                                                type:STBMPTYPE_EYE_LINER
                                     needAddNoneItem:YES localDatasource:[NSMutableArray array] callback:eyelinerCallback];
        
        //眼睫毛：1.先加载本地素材 2.加载服务器素材
        NSMutableArray * m_eyelashArr = [[self getLocalMaterial:@"eyelash"
                                                        bmpType:STBMPTYPE_EYE_LASH
                                                needAddNoneItem:YES] mutableCopy];
        [self fetchMaterialsAndReloadDataWithGroupID:@"ff92608b29ef4644bcf02d2160eeb948"
                                                type:STBMPTYPE_EYE_LASH
                                     needAddNoneItem:NO localDatasource:m_eyelashArr callback:eyelashCallback];
        //眼球
        [self fetchMaterialsAndReloadDataWithGroupID:@"89c4e32f0ece4c9f9eb3219ff2dd1923"
                                                type:STBMPTYPE_EYE_BALL
                                     needAddNoneItem:YES localDatasource:[NSMutableArray array] callback:eyeballCallback];
        
        //整装: 1.获取本地素材 2.获取服务器素材
        NSMutableArray * m_wholeMakeArr = [self getLocalMaterial:@"wholemakeup"
                                                         bmpType:STBMPTYPE_WHOLEMAKEUP
                                                 needAddNoneItem:YES];
        [self fetchMaterialsAndReloadDataWithGroupID:@"4db72d684a08473d8018837b16ffa9cc"
                                                type:STBMPTYPE_WHOLEMAKEUP
                                     needAddNoneItem:NO localDatasource:m_wholeMakeArr callback:wholeMakeCallback];
        //染发
        NSMutableArray * m_maskHairArr = [self getLocalMaterial:@"hairColor"
                                                         bmpType:STBMPTYPE_MASKHAIR
                                                 needAddNoneItem:YES];
        [self fetchMaterialsAndReloadDataWithGroupID:@"a539b106d7e14038887fece6a601d9ec"
                                                type:STBMPTYPE_MASKHAIR
                                     needAddNoneItem:YES localDatasource:m_maskHairArr callback:maskhairCallback];
    }];
    return self;
}

- (instancetype)stm_generatMaterialsDataSource:(void (^)(STCustomMemoryCache *))callback {
    STCustomMemoryCache * result = [[STCustomMemoryCache alloc] init];
    NSString *strLocalBundlePath = [[NSBundle mainBundle] pathForResource:@"my_sticker" ofType:@"bundle"];
    
    if (strLocalBundlePath) {
        NSMutableArray *arrLocalModels = [NSMutableArray array];
        
        NSFileManager *fManager = [[NSFileManager alloc] init];
        
        NSArray *arrFiles = [fManager contentsOfDirectoryAtPath:strLocalBundlePath error:nil];
        
        int indexOfItem = 0;
        for (NSString *strFileName in arrFiles) {
            
            if ([strFileName hasSuffix:@".zip"]) {
                
                NSString *strMaterialPath = [strLocalBundlePath stringByAppendingPathComponent:strFileName];
                NSString *strThumbPath = [[strMaterialPath stringByDeletingPathExtension] stringByAppendingString:@".png"];
                UIImage *imageThumb = [UIImage imageNamed:strThumbPath];
                
                if (!imageThumb) {
                    imageThumb = [UIImage imageNamed:@"none"];
                }
                EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
                
                model.iEffetsType = STEffectsTypeStickerMy;
                model.state = Downloaded;
                model.indexOfItem = indexOfItem;
                model.imageThumb = imageThumb;
                model.strMaterialPath = strMaterialPath;
                
                [arrLocalModels addObject:model];
                
                indexOfItem ++;
            }
        }
        
        NSString *strDocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *localStickerPath = [strDocumentsPath stringByAppendingPathComponent:@"local_sticker"];
        if (![fManager fileExistsAtPath:localStickerPath]) {
            [fManager createDirectoryAtPath:localStickerPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSArray *arrFileNames = [fManager contentsOfDirectoryAtPath:localStickerPath error:nil];
        
        for (NSString *strFileName in arrFileNames) {
            if ([strFileName hasSuffix:@"zip"]) {
                NSString *strMaterialPath = [localStickerPath stringByAppendingPathComponent:strFileName];
                NSString *strThumbPath = [[strMaterialPath stringByDeletingPathExtension] stringByAppendingString:@".png"];
                UIImage *imageThumb = [UIImage imageWithContentsOfFile:strThumbPath];
                if (!imageThumb) imageThumb = [UIImage imageNamed:@"none"];
                EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
                model.iEffetsType = STEffectsTypeStickerMy;
                model.state = Downloaded;
                model.indexOfItem = indexOfItem;
                model.imageThumb = imageThumb;
                model.strMaterialPath = strMaterialPath;
                [arrLocalModels addObject:model];
                indexOfItem ++;
            }
        }
        [result setObject:arrLocalModels forKey:@(STEffectsTypeStickerMy)];
    }
    
    if (callback) callback(result);
    
    return self;
}

#pragma mark - helper methods
- (NSMutableArray *)getLocalMaterial:(NSString *)beautyType
                             bmpType:(STBMPTYPE)bmpType
                     needAddNoneItem:(BOOL)needAddNoneItem{
    NSString *strLocalBundlePath = [[NSBundle mainBundle] pathForResource:beautyType ofType:@"bundle"];
    NSArray *arrFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strLocalBundlePath error:nil];
    arrFiles = [arrFiles sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableArray *array = [NSMutableArray array];
    if (needAddNoneItem) {
        STMakeupDataModel *model = [self getTheNullModelType:bmpType];
        [array addObject:model];
    }
    for (NSString *strFileName in arrFiles) {
        if ([strFileName hasSuffix:@".zip"]) {
            NSString *strBmpPath = [strLocalBundlePath stringByAppendingPathComponent:strFileName];
            NSString *strName = [[strBmpPath stringByDeletingPathExtension] lastPathComponent];
            NSString *strThumbPath = [[strBmpPath stringByDeletingPathExtension] stringByAppendingString:@".png"];
            if(![[NSFileManager defaultManager] fileExistsAtPath:strThumbPath]){
                strThumbPath = nil;
                strThumbPath = strThumbPath?:[[strBmpPath stringByDeletingPathExtension] stringByAppendingString:@".jpg"];
            }
            STMakeupDataModel *model = [[STMakeupDataModel alloc] init];
            UIImage *imageThumb = [UIImage imageWithContentsOfFile:strThumbPath];
            if (!imageThumb) {
                imageThumb = [UIImage imageNamed:@"none"];
            }
//            model.m_thumbImage = imageThumb;
            model.m_iconDefault = strThumbPath;
            model.m_zipPath = strBmpPath;
            model.m_name = strName;
            model.m_index = (int)[arrFiles indexOfObject:strFileName] + 1;
            model.m_bmpStrength = 0.85f;
            model.m_bmpType = bmpType;
            model.m_fromOnLine = NO;
            model.m_state = STStateNotNeedDownload;
            [array addObject:model];
        }
    }
    return array;
}

- (STMakeupDataModel *)getTheNullModelType:(STBMPTYPE)type{
    //get makeup materials
    STMakeupDataModel *model = [[STMakeupDataModel alloc] init];
    model.m_iconDefault = @"close_white";
    model.m_thumbImage = [UIImage imageNamed:@"close_white"];
    model.m_name = @"None";
    model.m_index = 0;
    model.m_bmpType = type;
    model.m_fromOnLine = NO;
    model.m_state = STStateNotNeedDownload;
    return model;
}
-(void)downDatasource:(void (^)(BOOL success))call{
    [[EFDataSourceGenerator sharedInstance]efGeneratAllDataSourceWithCallback:^(id<EFDataSourcing> datasource) {
            myDatasource = datasource;
        if (call) {
            call(true);
        }
    }];
}
//在原版基础上改的，存在无用的输入参数
static id<EFDataSourcing> myDatasource;
- (void)fetchMaterialsAndReloadDataWithGroupID:(NSString *)strGroupID type:(STBMPTYPE)iType needAddNoneItem:(BOOL)needAddNoneItem localDatasource:(NSMutableArray *)localDatasource callback:(void(^)(NSArray <STMakeupDataModel *> * datasource))fetchCallback{
 
            NSMutableArray *arrModels = [NSMutableArray array];
            if (needAddNoneItem) {
                STMakeupDataModel *model = [self getTheNullModelType:iType];
                [arrModels addObject:model];
            }
            for (EFDataSourceModel *modelOne in myDatasource.efSubDataSources) {
                if ([modelOne.efName isEqual:@"美妆"]) {
                    for (EFDataSourceModel *modelTwo in modelOne.efSubDataSources) {
                        int i=0;
                        if([self efNameToSTBMPTYPE:modelTwo.efName] == iType){
                            for (EFDataSourceModel *modelThree in modelTwo.efSubDataSources) {
                                STMakeupDataModel *model = [[STMakeupDataModel alloc] init];
                                model.NewMaterial = modelThree;
                                model.m_iconDefault = modelThree.efThumbnailDefault;
                                model.m_name = modelThree.efName;
                                model.m_index = i + 1;
                                model.m_bmpType = iType;
                                model.m_bmpStrength = 0.85f;
                                EFMaterialDownloadStatus MaterialExistStatus = [[EFMaterialDownloadStatusManager sharedInstance] efDownloadStatus:model.NewMaterial];
                                switch (MaterialExistStatus) {
                                    case EFMaterialDownloadStatusNotDownload:
                                        model.m_state = STStateNeedDownlad;
                                        model.m_zipPath = nil;
                                        break;
                                    case EFMaterialDownloadStatusDownloaded:
                                        model.m_state = STStateDownloaded;
                                        model.m_zipPath = modelThree.efMaterialPath;
                                        break;
                                    default:
                                        break;
                                }
//                                model.m_state = !isMaterialExist?STStateNeedDownlad:STStateDownloaded;
//                                model.m_zipPath = isMaterialExist?modelThree.efMaterialPath:nil;
                                model.m_fromOnLine = YES;
                          
                                [arrModels addObject:model];
                                i++;
                            }
                            
                            
                            break;
                        }
                        
                    }
                    
                    break;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
               
                if (fetchCallback) fetchCallback([self updateDataSourceWithType:iType localDatasource:localDatasource array:arrModels]);
                
            });
        

}
-(STBMPTYPE)efNameToSTBMPTYPE:(NSString *)str {
    if ([str isEqual:@"口红"]) {
        return STBMPTYPE_LIP;
    }
    else if ([str isEqual:@"腮红"]){
        return STBMPTYPE_CHEEK;
    }
    else if ([str isEqual:@"修容"]){
        return STBMPTYPE_NOSE;
    }
    else if ([str isEqual:@"染发"]){
        return STBMPTYPE_MASKHAIR;
    }
    else if ([str isEqual:@"眉毛"]){
        return STBMPTYPE_EYE_BROW;
    }
    else if ([str isEqual:@"眼影"]){
        return STBMPTYPE_EYE_SHADOW;
    }
    else if ([str isEqual:@"眼线"]){
        return STBMPTYPE_EYE_LINER;
    }
    else if ([str isEqual:@"眼睫毛"]){
        return STBMPTYPE_EYE_LASH;
    }
    else if ([str isEqual:@"美瞳"]){
        return STBMPTYPE_EYE_BALL;
    }else{
        return Nil;
    }
}
- (NSArray <STMakeupDataModel *> *)updateDataSourceWithType:(STBMPTYPE)type localDatasource:(NSMutableArray <STMakeupDataModel *> *)localDatasource array:(NSMutableArray <STMakeupDataModel *>*)array{
    switch (type) {
        case STBMPTYPE_MASKHAIR:
//            localDatasource = [array mutableCopy];
                [localDatasource addObjectsFromArray:array];
                localDatasource = [localDatasource sortedArrayUsingComparator:^NSComparisonResult(STMakeupDataModel * obj1, STMakeupDataModel * obj2) {
                    return [obj1.m_name compare:obj2.m_name];
                }].mutableCopy;
            break;
        case STBMPTYPE_LIP: {
            [localDatasource addObjectsFromArray:array];
            localDatasource = [localDatasource sortedArrayUsingComparator:^NSComparisonResult(STMakeupDataModel * obj1, STMakeupDataModel * obj2) {
                if ([obj1.m_name isEqualToString:@"None"]) { return NSOrderedSame; }
                return [obj1.m_name compare:obj2.m_name];
            }].mutableCopy;
        }
            break;
        case STBMPTYPE_CHEEK:
            [localDatasource addObjectsFromArray:array];
            localDatasource = [localDatasource sortedArrayUsingComparator:^NSComparisonResult(STMakeupDataModel * obj1, STMakeupDataModel * obj2) {
                return [obj1.m_name compare:obj2.m_name];
            }].mutableCopy;
            
            break;
        case STBMPTYPE_NOSE:
            [localDatasource addObjectsFromArray:array];
            localDatasource = [localDatasource sortedArrayUsingComparator:^NSComparisonResult(STMakeupDataModel * obj1, STMakeupDataModel * obj2) {
                return [obj1.m_name compare:obj2.m_name];
            }].mutableCopy;
            break;
        case STBMPTYPE_EYE_BROW:
            [localDatasource addObjectsFromArray:array];
            localDatasource = [localDatasource sortedArrayUsingComparator:^NSComparisonResult(STMakeupDataModel * obj1, STMakeupDataModel * obj2) {
                return [obj1.m_name compare:obj2.m_name];
            }].mutableCopy;
            break;
        case STBMPTYPE_EYE_SHADOW:
            [localDatasource addObjectsFromArray:array];
            localDatasource = [localDatasource sortedArrayUsingComparator:^NSComparisonResult(STMakeupDataModel * obj1, STMakeupDataModel * obj2) {
                return [obj1.m_name compare:obj2.m_name];
            }].mutableCopy;
            break;
        case STBMPTYPE_EYE_LINER:
            localDatasource = [array mutableCopy];
            break;
        case STBMPTYPE_EYE_LASH:
            [localDatasource addObjectsFromArray:array];
            localDatasource = [localDatasource sortedArrayUsingComparator:^NSComparisonResult(STMakeupDataModel * obj1, STMakeupDataModel * obj2) {
                return [obj1.m_name compare:obj2.m_name];
            }].mutableCopy;
            break;
        case STBMPTYPE_EYE_BALL:
            localDatasource = [array mutableCopy];
            break;
        case STBMPTYPE_WHOLEMAKEUP:{
            [localDatasource addObjectsFromArray:array];
            localDatasource = [localDatasource sortedArrayUsingComparator:^NSComparisonResult(STMakeupDataModel * obj1, STMakeupDataModel * obj2) {
                return [obj1.m_name compare:obj2.m_name];
            }].mutableCopy;
            break;
        }
        case STBMPTYPE_COUNT:
            break;
        default:
            break;
    }
    return [[self deleteTheSame:localDatasource] copy];
}
-(NSMutableArray <STMakeupDataModel *>*)deleteTheSame:(NSMutableArray <STMakeupDataModel *>*)arrModel{
    NSMutableArray<STMakeupDataModel *>* arr = arrModel, *resultArrModel;
    resultArrModel = [NSMutableArray array];
    if (arr.count == 1) {
        [resultArrModel addObject:arr[0]];
    }
    for (int i =0,j=0; i < arr.count-1;) {
        STMakeupDataModel * firstMakeUpModel = arr[i];
        STMakeupDataModel *secondMakeUpModel = arr[i+j+1];;
        
        if ([secondMakeUpModel.m_name isEqual:firstMakeUpModel.m_name]) {
            if (i+j+1 == arr.count-1) {
                
                if (firstMakeUpModel.m_state == Downloaded) {
                        
                    [resultArrModel addObject:firstMakeUpModel];
                }else{
                        
                    [resultArrModel addObject:secondMakeUpModel];
                }
                break;
            }
            
            j++;
            if (secondMakeUpModel.m_state == Downloaded) {
                i = i+j;
                j=0;
            }
        }else{
//            if (firstMakeUpModel.m_state == Downloaded) {
//
//                [resultArrModel addObject:firstMakeUpModel];
//            }else{
//
//                [resultArrModel addObject:secondMakeUpModel];
//            }
            [resultArrModel addObject:firstMakeUpModel];
            i = i + j + 1;
            j = 0;
            if (i >= arr.count-1) {
//                if (firstMakeUpModel.m_state == Downloaded) {
//
//                    [resultArrModel addObject:firstMakeUpModel];
//                }else{
//
//                    [resultArrModel addObject:secondMakeUpModel];
//                }
                [resultArrModel addObject:secondMakeUpModel];
            }
            
        }
    }
    return  resultArrModel;
    
}
- (void)fetchMaterialsAndReloadDataWithGroupID:(NSString *)strGroupID type:(STEffectsType)iType {
//    [[SenseArMaterialService sharedInstance] fetchMaterialsWithUserID:@"testUserID" GroupID:strGroupID onSuccess:^(NSArray<SenseArMaterial *> *arrMaterials) {
//        NSMutableArray *arrModels = [NSMutableArray array];
//        for (int i = 0; i < arrMaterials.count; i ++) {
//            SenseArMaterial *material = [arrMaterials objectAtIndex:i];
//            EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
//            model.material = material;
//            model.indexOfItem = i;
//            model.state = [[SenseArMaterialService sharedInstance] isMaterialDownloaded:material] ? Downloaded : NotDownloaded;
//            model.iEffetsType = iType;
//            if (material.strMaterialPath) {
//                model.strMaterialPath = material.strMaterialPath;
//            }
//            [arrModels addObject:model];
//        }
//
//        [weakSelf.coreStateMangement.effectsDataSource setObject:arrModels forKey:@(iType)];
//
//        if (iType == weakSelf.coreStateMangement.curEffectStickerType) {
//            weakSelf.coreStateMangement.arrCurrentModels = [weakSelf.coreStateMangement.effectsDataSource objectForKey:@(iType)];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                [weakSelf.effectsList reloadData];
//            });
//        }
//
//        for (EffectsCollectionViewCellModel *model in arrModels) {
//
//            dispatch_async(weakSelf.thumbDownlaodQueue, ^{
//
//                [weakSelf cacheThumbnailOfModel:model];
//            });
//        }
//    } onFailure:^(int iErrorCode, NSString *strMessage){
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            NSArray *actions = @[@"知道了"];
//            UIAlertController *alertVC = [STParamUtil showAlertWithTitle:@"提示" Message:@"获取贴纸列表失败" actions:actions onVC:self];
//            [self presentViewController:alertVC animated:YES completion:nil];
//        });
//    }];
}

@end
