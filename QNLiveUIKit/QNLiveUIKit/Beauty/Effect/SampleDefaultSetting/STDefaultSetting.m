//
//  STDefaultSetting.m
//  SenseMeEffects
//
//  Created by sunjian on 2021/2/24.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import "STDefaultSetting.h"
#import "st_mobile_license.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSBundle+language.h"
#import "STParamUtil.h"
#import "SenseArSourceService.h"
#import "STCustomMemoryCache.h"

#import "STDefaultSettingDataSourseGenerator.h"

NSString *STCacheKeyBase      = @"STCacheKeyBase";
NSString *STCacheKeyFilter    = @"STCacheKeyFilter";
NSString *STCacheKeyMakeup    = @"STCacheKeyMakeup";

NSString *STPreviewPath = @"STPreview";
NSString *STPhotoPath   = @"STPhoto";
NSString *STVideoPath   = @"STVideo";

NSString *STFilterName = @"STFilterName";
NSString *STFilterValu = @"STFilterValu";
NSString *STFilterType = @"STFilterType";

/*
 {
 
 Type : {
            type:
            name:
            value:
 }
 
 Filter : {
            type:
            name:
            value:
 }
 Makeup :[
            {
                type :
                name :
                value:
             },
            {
                type :
                name :
                value:
            },
            ...
        ]
 }
 */

NSString *STValueTypeScrollType         = @"STValueTypeScrollType";
NSString *STValueTypeWholeFilterValue   = @"STValueTypeWholeFilterValue";
NSString *STValueTypeWholeMakeupValue   = @"STValueTypeWholeMakeupValue";
NSString *STValueTypeWholeEffectsIndex  = @"STValueTypeWholeEffectsIndex";
NSString *STValueTypeSelected           = @"STValueTypeSelected";
NSString *STValueTypeBeauty             = @"STValueTypeBeauty";
NSString *STValueTypeBeautyType         = @"STValueTypeBeautyType";
NSString *STValueTypeBeautyName         = @"STValueTypeBeautyName";
NSString *STValueTypeBeautyValueKey     = @"STValueTypeBeautyValueKey";
NSString *STValueTypeFilter             = @"STValueTypeFilter";
NSString *STValueTypeFilterModelType    = @"STValueTypeFilterModelType";
NSString *STValueTypeFilterModelName    = @"STValueTypeFilterModelName";
NSString *STValueTypeFilterModelValue   = @"STValueTypeFilterModelValue";
NSString *STValueTypeMakeUp             = @"STValueTypeMakeUp";
NSString *STValueTypeMakeUpModelType    = @"STValueTypeMakeUpModelType";
NSString *STValueTypeMakeUpModelName    = @"STValueTypeMakeUpModelName";
NSString *STValueTypeMakeUpModelValue   = @"STValueTypeMakeUpModelValue";

@interface STValueStack : NSObject
@property (nonatomic, strong) NSMutableArray *valueStack; // 多贴纸的栈
@property (nonatomic, strong) NSMutableArray *stickerValueStack;
@property (nonatomic, strong) NSMutableArray *valueChange;
@property (nonatomic, strong) NSMutableArray *changeFlags;
@end
@implementation STValueStack
- (instancetype)init{
    self = [super init];
    return self;
}
@end

@interface STBeautyValueManager : NSObject
@property (nonatomic, strong) NSMutableDictionary *defaultBeautyValues;//hand default values
@property (nonatomic, strong) NSMutableDictionary *stickerBeautyValues;//hand overlap values
@property (nonatomic, strong) NSMutableDictionary *manualBeautyValues;//hand manal change values

@end

@implementation STBeautyValueManager
- (instancetype)init{
    self = [super init];
    self.defaultBeautyValues = [NSMutableDictionary dictionary];
    self.stickerBeautyValues = [NSMutableDictionary dictionary];
    self.manualBeautyValues  = [NSMutableDictionary dictionary];
    return self;
}

- (NSMutableDictionary *)getBeautyValue{
    //基础美颜、美形、微整形、调整
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionaryWithDictionary: self.defaultBeautyValues];
    //set overlap values
    BOOL bUseSticker = NO;
    for(NSNumber *number in self.stickerBeautyValues.allValues){
        if(number.intValue != 0) bUseSticker = YES;
    }
    if(bUseSticker){
        [defaultValues addEntriesFromDictionary:self.stickerBeautyValues];
    }
    //set manul values
    [defaultValues addEntriesFromDictionary:self.manualBeautyValues];
    return defaultValues;
}

- (NSMutableDictionary *)getSaveValue{
    //基础美颜、美形、微整形、调整
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionaryWithDictionary: self.defaultBeautyValues];
    //set manul values
    [defaultValues addEntriesFromDictionary:self.manualBeautyValues];
    return defaultValues;
}

- (NSMutableDictionary *)getIdentityDic{
    NSMutableDictionary *cur = [NSMutableDictionary dictionaryWithDictionary:self.defaultBeautyValues];
    [cur enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        cur[key] = @(0);
    }];
    return cur;
}

@end


@interface STDefaultSetting ()
{
    int      _defaultValues[34];
}
@property (nonatomic, readwrite, assign) BOOL isFirstLaunch;
@property (nonatomic, strong) NSString *previewPath;
@property (nonatomic, strong) NSString *photoPath;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) dispatch_queue_t saveQueue;
@property (nonatomic, strong) NSMutableDictionary *saveDic; // 存取入口
@property (nonatomic, strong) STCollectionViewDisplayModel *lastFilterModel; // 存滤镜
@property (nonatomic, strong) NSMutableSet<STMakeupDataModel *> *bmpModels; //

@property (nonatomic, strong) STValueStack *valueStack;
@property (nonatomic, strong) STBeautyValueManager *beautyValueManager;

@end

@implementation STDefaultSetting

+ (instancetype)sharedInstace{
    static id instacne = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instacne = [[STDefaultSetting alloc] init];
    });
    return instacne;
}


- (instancetype)init{
    if ((self = [super init])) {
        self.previewPath = [self getFilePath:STPreviewPath];
        self.photoPath   = [self getFilePath:STPhotoPath];
        self.videoPath   = [self getFilePath:STVideoPath];
        self.bmpModels   = [NSMutableSet new];
        self.isFirstLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:@"FIRST_GET_DEFAULT_VALUE"] == nil;
        if (self.isFirstLaunch)
            [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"FIRST_GET_DEFAULT_VALUE"];
        [self createSaveFileQueue];
        self.valueStack = [[STValueStack alloc] init];
        self.beautyValueManager = [[STBeautyValueManager alloc] init];
    }
    return self;
}

#pragma mark - lazy load
- (NSMutableDictionary *)saveDic{
    if (!_saveDic) {
        _saveDic = [NSMutableDictionary new];
    }
    return _saveDic;
}

#pragma mark - create file

- (NSString *)getFilePath:(NSString *)path{
    return [self createFiles:path];
}

NSString *getFilePath(NSString *path){
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    filePath = [filePath stringByAppendingPathComponent:path];
    return filePath;
}
- (NSString *)createFiles:(NSString *)path{
    NSString *retPath = getFilePath(path);
    if(![[NSFileManager defaultManager] fileExistsAtPath:retPath]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:retPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!error) {
            return retPath;
        }
    }else{
        return retPath;
    }
    return nil;
}

- (NSString *)getFilePath:(NSString *)basePath fileName:(NSString *)fileName{
    if (!basePath) {
        return nil;
    }
    return [basePath stringByAppendingPathComponent:fileName];
}

#pragma mark - create Timer
- (void)createSaveFileQueue{
    self.saveQueue = dispatch_queue_create("com.sensetime.saveFileQueue", DISPATCH_QUEUE_SERIAL);
}


- (void)setDefaultBeautyValues{
    //从内存中加载数据
    NSArray *array = @[self.baseBeautyModels,
                       self.beautyShapeModels,
                       self.microSurgeryModels,
                       self.adjustModels];
    for(NSArray <STNewBeautyCollectionViewModel *> * models in array){
        for(STNewBeautyCollectionViewModel *model in models){
            [self.beautyValueManager.defaultBeautyValues setObject:@(model.beautyValue)
                                                            forKey:@(model.beautyType)];
        }
    }
    self.beautyValueManager.stickerBeautyValues = [self.beautyValueManager getIdentityDic];
    [self.beautyValueManager.manualBeautyValues removeAllObjects];
}

- (void)clearStickerValue{
    self.beautyValueManager.stickerBeautyValues = [self.beautyValueManager getIdentityDic];
}

- (void)zeroValue{
    for(STNewBeautyCollectionViewModel *model in self.baseBeautyModels){
        model.beautyValue = 0;
    }
    for(STNewBeautyCollectionViewModel *model in self.beautyShapeModels){
        model.beautyValue = 0;
    }
    for(STNewBeautyCollectionViewModel *model in self.microSurgeryModels){
        model.beautyValue = 0;
    }
    for(STNewBeautyCollectionViewModel *model in self.adjustModels){
        model.beautyValue = 0;
    }
}

- (void)zeroMakeupWithHandle:(st_handle_t *)handle withType:(STEffectsType)type{
    //zero美颜UI
    switch (type) {
        case STEffectsTypeBeautyWholeMakeup:
            for (int i = 0; i < self.wholeMakeUpModels.count; i++) {
                self.wholeMakeUpModels[i].beautyValue = 0;
            }
            break;
        case STEffectsTypeBeautyBase:
            for(int i = 0; i < self.baseBeautyModels.count; i++){
                self.baseBeautyModels[i].beautyValue = 0;
                [self updateCurrentBeautyValue:self.baseBeautyModels[i]];
            }
            break;
        case STEffectsTypeBeautyShape:
            for(int i = 0; i < self.beautyShapeModels.count; i++){
                self.beautyShapeModels[i].beautyValue = 0;
                [self updateCurrentBeautyValue:self.beautyShapeModels[i]];
            }
            break;
        case STEffectsTypeBeautyMicroSurgery:
            for(int i = 0; i < self.microSurgeryModels.count; i++){
                self.microSurgeryModels[i].beautyValue = 0;
                [self updateCurrentBeautyValue:self.microSurgeryModels[i]];
            }
            break;
        case STEffectsTypeBeautyAdjust:
            for(int i = 0; i < self.adjustModels.count; i++){
                self.adjustModels[i].beautyValue = 0;
                [self updateCurrentBeautyValue:self.adjustModels[i]];
            }
            break;
        case STEffectsTypeBeautyMakeUp:
            [self.saveDic setObject:@[] forKey:STValueTypeMakeUp];
            break;
        case STEffectsTypeBeautyFilter:
            [self.saveDic setObject:@{} forKey:STValueTypeFilter];
            break;
        default:
            break;
    }
    //zero美颜效果
    [self zeroWithHandle:handle withType:type];
}


- (void)zeroWithHandle:(st_handle_t *)handle withType:(STEffectsType)type{
    switch (type) {
        case STEffectsTypeBeautyWholeMakeup:
            for(int i = EFFECT_BEAUTY_MAKEUP_HAIR_DYE; i <= EFFECT_BEAUTY_MAKEUP_PACKED; i++){
    
                [self.effectManager setBeautify:nil type:i];
            }
            break;
        case STEffectsTypeBeautyBase:
            //美白
            [self.effectManager setBeautifyMode:0 type:EFFECT_BEAUTY_BASE_WHITTEN];
            [self.effectManager updateBeautify:0 type:EFFECT_BEAUTY_BASE_WHITTEN];

            [self.effectManager setBeautifyMode:1 type:EFFECT_BEAUTY_BASE_WHITTEN];
            [self.effectManager updateBeautify:0 type:EFFECT_BEAUTY_BASE_WHITTEN];

            [self.effectManager setBeautifyMode:2 type:EFFECT_BEAUTY_BASE_WHITTEN];
            [self.effectManager updateBeautify:0 type:EFFECT_BEAUTY_BASE_WHITTEN];
            //红润
            [self.effectManager updateBeautify:0.0 type:EFFECT_BEAUTY_BASE_REDDEN];
            //磨皮1
            [self.effectManager setBeautifyMode:1 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
            [self.effectManager updateBeautify:0.0 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
            //磨皮2
            [self.effectManager setBeautifyMode:2 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
            [self.effectManager updateBeautify:0.0 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
            break;
        case STEffectsTypeBeautyShape:
            for(int i = EFFECT_BEAUTY_RESHAPE_SHRINK_FACE; i <= EFFECT_BEAUTY_RESHAPE_ROUND_EYE; i++){
                [self.effectManager updateBeautify:0.0 type:i];
            }
            break;
        case STEffectsTypeBeautyMicroSurgery:
            for(int i = EFFECT_BEAUTY_PLASTIC_THINNER_HEAD; i <= EFFECT_BEAUTY_PLASTIC_OPEN_EXTERNAL_CANTHUS; i++){
                [self.effectManager updateBeautify:0.0 type:i];
            }
            break;
        case STEffectsTypeBeautyAdjust:
            for(int i = EFFECT_BEAUTY_TONE_CONTRAST; i <= EFFECT_BEAUTY_TONE_CLEAR; i++){
                [self.effectManager updateBeautify:0.0 type:i];
            }
            break;
        default:
            break;
    }
}

- (void)getDefaultValue{
    //基础美颜
    //美白1
    self.baseBeautyModels[0].beautyValue = 0;
    //美白2
    self.baseBeautyModels[1].beautyValue = 0;
    //美白3
    self.baseBeautyModels[2].beautyValue = 50;
    //红润
    self.baseBeautyModels[3].beautyValue = 0;
    //磨皮1
    self.baseBeautyModels[4].beautyValue = 0;
    //磨皮2
    self.baseBeautyModels[5].beautyValue = 50;
    //美形
    //瘦脸
    self.beautyShapeModels[0].beautyValue = 34;
    //大眼
    self.beautyShapeModels[1].beautyValue = 29;
    //小脸
    self.beautyShapeModels[2].beautyValue = 10;
    //窄脸
    self.beautyShapeModels[3].beautyValue = 25;
    //圆眼
    self.beautyShapeModels[4].beautyValue = 7;
    //微整形
    //小头
    self.microSurgeryModels[0].beautyValue = 0;
    //瘦脸型
    self.microSurgeryModels[1].beautyValue = 45;
    //下巴
    self.microSurgeryModels[2].beautyValue = 20;
    //额头
    self.microSurgeryModels[3].beautyValue = 0;
    //苹果肌
    self.microSurgeryModels[4].beautyValue = 30;
    //瘦鼻翼
    self.microSurgeryModels[5].beautyValue = 21;
    //长鼻
    self.microSurgeryModels[6].beautyValue = 0;
    //侧脸隆鼻
    self.microSurgeryModels[7].beautyValue = 10;
    //嘴形
    self.microSurgeryModels[8].beautyValue = 51;
    //缩人中
    self.microSurgeryModels[9].beautyValue = 0;
    //眼距
    self.microSurgeryModels[10].beautyValue = -23;
    //眼睛角度
    self.microSurgeryModels[11].beautyValue = 0;
    //开眼角
    self.microSurgeryModels[12].beautyValue = 0;
    //亮眼
    self.microSurgeryModels[13].beautyValue = 25;
    //祛黑眼圈
    self.microSurgeryModels[14].beautyValue = 69;
    //祛法令纹
    self.microSurgeryModels[15].beautyValue = 60;
    //白牙
    self.microSurgeryModels[16].beautyValue = 20;
    //瘦颧骨
    self.microSurgeryModels[17].beautyValue = 36;
    //开外眼角
    self.microSurgeryModels[18].beautyValue = 0;
    //对比度
    self.adjustModels[0].beautyValue = 0;
    //饱和度
    self.adjustModels[1].beautyValue = 0;
    //锐化
    self.adjustModels[2].beautyValue = 50;
    //清晰度
    self.adjustModels[3].beautyValue = 20;
}

- (void)updateValueWithWholeType:(STBeautyType)wholeType{
    [self getDefaultValue];
}

- (void)shouldZeroBaseBeauty:(st_handle_t)handle{
    BOOL shouldZeroBaseBeauty = NO;
    for(STNewBeautyCollectionViewModel *model in self.baseBeautyModels){
        shouldZeroBaseBeauty = (model.beautyValue == 0);
    }
    if (shouldZeroBaseBeauty) {
        [self zeroWithHandle:handle withType:STEffectsTypeBeautyBase];
    }
}

- (void)setBeautyParamsValueHandle:(st_handle_t *)handle{
    //如果所有的基础美颜参数都是0，那意味着是清零的操作，因此要做一部zero的操作
    [self shouldZeroBaseBeauty:handle];
    for(int i = 0; i < self.baseBeautyModels.count; i++){
        switch (i) {
            case 0:
                if (self.baseBeautyModels[0].beautyValue > 0) {
                    [self.effectManager setBeautifyMode:0 type:EFFECT_BEAUTY_BASE_WHITTEN];
                    [self.effectManager updateBeautify:self.baseBeautyModels[0].beautyValue/100.0 type:EFFECT_BEAUTY_BASE_WHITTEN];
                    break;
                }
            case 1:
                if (self.baseBeautyModels[1].beautyValue > 0) {
                    [self.effectManager setBeautifyMode:2 type:EFFECT_BEAUTY_BASE_WHITTEN];
                    [self.effectManager updateBeautify:self.baseBeautyModels[1].beautyValue/100.0 type:EFFECT_BEAUTY_BASE_WHITTEN];
                    break;
                }
            case 2:
                if (self.baseBeautyModels[2].beautyValue > 0) {
                    [self.effectManager setBeautifyMode:2 type:EFFECT_BEAUTY_BASE_WHITTEN];
//                    if ([EAGLContext currentContext] != self.glContext) {
//                        [EAGLContext setCurrentContext:self.glContext];
//                    }
//                    NSString *path = [[NSBundle mainBundle] pathForResource:@"whiten_gif" ofType:@"zip"];
//                    [self.effectManager setBeautify:path type:EFFECT_BEAUTY_BASE_WHITTEN];
                    [self.effectManager updateBeautify:self.baseBeautyModels[2].beautyValue/100.0 type:EFFECT_BEAUTY_BASE_WHITTEN];
                    break;
                }
            case 3:
                if (self.baseBeautyModels[3].beautyValue > 0) {
                    [self.effectManager updateBeautify:self.baseBeautyModels[3].beautyValue/100.0 type:EFFECT_BEAUTY_BASE_REDDEN];
                }
                break;
            case 4:
                if (self.baseBeautyModels[4].beautyValue > 0) {
                    [self.effectManager setBeautifyMode:1 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
                    [self.effectManager updateBeautify:self.baseBeautyModels[4].beautyValue/100.0 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
                    break;
                }
            case 5:
                if (self.baseBeautyModels[5].beautyValue > 0) {
                    [self.effectManager setBeautifyMode:2 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
                    [self.effectManager updateBeautify:self.baseBeautyModels[5].beautyValue/100.0 type:EFFECT_BEAUTY_BASE_FACE_SMOOTH];
                    break;
                }
            default:
                break;
        }
    }
    for(int i = 0; i < self.beautyShapeModels.count; i++){
        [self.effectManager updateBeautify:self.beautyShapeModels[i].beautyValue/100.0 type:EFFECT_BEAUTY_RESHAPE_SHRINK_FACE+i];
    }
    for(int i = 0; i < self.microSurgeryModels.count; i++){
        [self.effectManager updateBeautify:self.microSurgeryModels[i].beautyValue/100.0 type:EFFECT_BEAUTY_PLASTIC_THINNER_HEAD+i];
    }
    for(int i = 0; i < self.adjustModels.count; i++){
        [self.effectManager updateBeautify:self.adjustModels[i].beautyValue/100.0 type:EFFECT_BEAUTY_TONE_CONTRAST+i];
    }
}

- (void)setBeautyParamsWithHandle:(st_handle_t *)handle{
//    if (handle == NULL) return;
    [self setBeautyParamsValueHandle:handle];
}


- (void)setBeuatyParamsWithHandle:(st_handle_t *)handle model:(STNewBeautyCollectionViewModel *)model{
    st_effect_beauty_type_t type = 0;
    int beauty_model = -1;
    switch (model.beautyType) {
        case STBeautyTypeWhiten1:
            type = EFFECT_BEAUTY_BASE_WHITTEN;
            beauty_model = 0;
            [self.effectManager setBeautifyMode:beauty_model type:type];
            break;
        case STBeautyTypeWhiten2:
            type = EFFECT_BEAUTY_BASE_WHITTEN;
            beauty_model = 2;

            [self.effectManager setBeautifyMode:beauty_model type:type];
            break;
        case STBeautyTypeWhiten3:
            type = EFFECT_BEAUTY_BASE_WHITTEN;
            beauty_model = 3;
            [self.effectManager setBeautifyMode:beauty_model type:type];
            break;
        case STBeautyTypeRuddy:
            type = EFFECT_BEAUTY_BASE_REDDEN;
            break;
        case STBeautyTypeDermabrasion1:
            type = EFFECT_BEAUTY_BASE_FACE_SMOOTH;
            beauty_model = 1;
            [self.effectManager setBeautifyMode:beauty_model type:type];
            break;
        case STBeautyTypeDermabrasion2:
            type = EFFECT_BEAUTY_BASE_FACE_SMOOTH;
            beauty_model = 2;
            [self.effectManager setBeautifyMode:beauty_model type:type];
            break;
        case STBeautyTypeShrinkFace:
            type = EFFECT_BEAUTY_RESHAPE_SHRINK_FACE;
            break;
        case STBeautyTypeEnlargeEyes:
            type = EFFECT_BEAUTY_RESHAPE_ENLARGE_EYE;
            break;
        case STBeautyTypeShrinkJaw:
            type = EFFECT_BEAUTY_RESHAPE_SHRINK_JAW;
            break;
        case STBeautyTypeThinFaceShape:
            type = EFFECT_BEAUTY_PLASTIC_THIN_FACE;
            break;
        case STBeautyTypeNarrowNose:
            type = EFFECT_BEAUTY_PLASTIC_NARROW_NOSE;
            break;
        case STBeautyTypeContrast:
            type = EFFECT_BEAUTY_TONE_CONTRAST;
            break;
        case STBeautyTypeClarity:
            type = EFFECT_BEAUTY_TONE_CLEAR;
            break;
        case STBeautyTypeSharpen:
            type = EFFECT_BEAUTY_TONE_SHARPEN;
            break;
        case STBeautyTypeSaturation:
            type = EFFECT_BEAUTY_TONE_SATURATION;
            break;
        case STBeautyTypeNarrowFace:
            type = EFFECT_BEAUTY_RESHAPE_NARROW_FACE;
            break;
        case STBeautyTypeHead:
            type = EFFECT_BEAUTY_PLASTIC_THINNER_HEAD;
            break;
        case STBeautyTypeRoundEye:
            type = EFFECT_BEAUTY_RESHAPE_ROUND_EYE;
            break;
        case STBeautyTypeAppleMusle:
            type = EFFECT_BEAUTY_PLASTIC_APPLE_MUSLE;
            break;
        case STBeautyTypeProfileRhinoplasty:
            type = EFFECT_BEAUTY_PLASTIC_PROFILE_RHINOPLASTY;
            break;
        case STBeautyTypeBrightEye:
            type = EFFECT_BEAUTY_PLASTIC_BRIGHT_EYE;
            break;
        case STBeautyTypeRemoveDarkCircles:
            type = EFFECT_BEAUTY_PLASTIC_REMOVE_DARK_CIRCLES;
            break;
        case STBeautyTypeWhiteTeeth:
            type = EFFECT_BEAUTY_PLASTIC_WHITE_TEETH;
            break;
        case STBeautyTypeShrinkCheekbone:
            type = EFFECT_BEAUTY_PLASTIC_SHRINK_CHEEKBONE;
            break;
        case STBeautyTypeOpenCanthus:
            type = EFFECT_BEAUTY_PLASTIC_OPEN_CANTHUS;
            break;
        case STBeautyTypeRemoveNasolabialFolds://祛法令纹
            type = EFFECT_BEAUTY_PLASTIC_REMOVE_NASOLABIAL_FOLDS;
            break;
        case STBeautyTypeOpenExternalCanthusRatio://开外眼角
            type = EFFECT_BEAUTY_PLASTIC_OPEN_EXTERNAL_CANTHUS;
            break;
        case STBeautyTypeChin://下巴
            type = EFFECT_BEAUTY_PLASTIC_CHIN_LENGTH;
            break;
        case STBeautyTypeHairLine://额头
            type = EFFECT_BEAUTY_PLASTIC_HAIRLINE_HEIGHT;
            break;
        case STBeautyTypeLengthNose://长鼻
            type = EFFECT_BEAUTY_PLASTIC_NOSE_LENGTH;
            break;
        case STBeautyTypeMouthSize://嘴形
            type = EFFECT_BEAUTY_PLASTIC_MOUTH_SIZE;
            break;
        case STBeautyTypeLengthPhiltrum://缩人中
            type = EFFECT_BEAUTY_PLASTIC_PHILTRUM_LENGTH;
            break;
        case STBeautyTypeEyeAngle://眼睛角度
            type = EFFECT_BEAUTY_PLASTIC_EYE_ANGLE;
            break;
        case STBeautyTypeEyeDistance://眼距
            type = EFFECT_BEAUTY_PLASTIC_EYE_DISTANCE;
            break;
        default:
            break;
    }

    [self.effectManager updateBeautify:model.beautyValue/100.0 type:type];
}

- (NSArray *)updateLastBeautyParams:(STBeautyType)wholeType{
    NSArray<STNewBeautyCollectionViewModel *> *baseBeautyModels = [NSArray arrayWithArray:self.baseBeautyModels];
    NSArray<STNewBeautyCollectionViewModel *> *beautyShapeModels = [NSArray arrayWithArray:self.beautyShapeModels];
    NSArray<STNewBeautyCollectionViewModel *> *microSurgeryModels = [NSArray arrayWithArray:self.microSurgeryModels];
    NSArray<STNewBeautyCollectionViewModel *> *adjustModels = [NSArray arrayWithArray:self.adjustModels];
    NSArray *modelArray = @[baseBeautyModels,
                            beautyShapeModels,
                            microSurgeryModels,
                            adjustModels];
    NSDictionary<NSNumber *, NSNumber *> *dic = [STDefaultSetting sharedInstace].beautyValueManager.defaultBeautyValues;
    for(NSArray<STNewBeautyCollectionViewModel *> *models in modelArray){
        for(STNewBeautyCollectionViewModel *curModel in models){
            curModel.beautyValue = dic[@(curModel.beautyType)].intValue;
        }
    }
    
    //base beauty 6
    int stride = 0;
    for(int i = 0; i < baseBeautyModels.count; i++){
        _defaultValues[i] = baseBeautyModels[i].beautyValue;
    }
    
    //shape 5
    stride = 6;
    for(int i = 0; i < beautyShapeModels.count; i++){
        _defaultValues[stride+i] = beautyShapeModels[i].beautyValue;
    }
    
    //micro 19
    stride = 11;
    for(int i = 0; i < microSurgeryModels.count; i++){
        _defaultValues[stride+i] = microSurgeryModels[i].beautyValue;
    }
    
    //adjust 4
    stride = 30;
    for(int i = 0; i < adjustModels.count; i++){
        _defaultValues[stride+i] = adjustModels[i].beautyValue;
    }
    
    return [self saveBeautyParams:_defaultValues];
}

//save beauty to plist
- (NSArray *)saveBeautyParams:(int *)values{
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < 34; i++){
        [array addObject:@(values[i])];
    }
    return array;
}


/*
 Multi Operation self.saveDic make sure thread safe
 */


- (void)updateLastParamsCurType:(STEffectsType)effectType
               wholeEffectModel:(STNewBeautyCollectionViewModel *)wholeEffectModel
                      baseModel:(STNewBeautyCollectionViewModel *)beautyModel
                         filter:(STCollectionViewDisplayModel *)filterModel
                         makeup:(NSMutableSet<STMakeupDataModel *> *)makeUps
                  needWriteFile:(BOOL)writeFile{
    if (beautyModel) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:@(beautyModel.modelType) forKey:STValueTypeBeautyType];
        [dict setObject:beautyModel.title forKey:STValueTypeBeautyName];
        [self.saveDic setObject:dict forKey:STValueTypeBeauty];
        [self.saveDic setObject:@(beautyModel.selected) forKey:STValueTypeSelected];
    }
    [self.saveDic setObject:@(effectType) forKey:STValueTypeScrollType];
//    [self.saveDic setObject:[self updateLastBeautyParams:0] forKey:STValueTypeBeautyValueKey];
    if (filterModel) {
        self.lastFilterModel = filterModel;
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:filterModel.strName forKey:STValueTypeFilterModelName];
        [dict setObject:@(filterModel.value) forKey:STValueTypeFilterModelValue];
        [dict setObject:@(filterModel.modelType) forKey:STValueTypeFilterModelType];
        [self.saveDic setObject:dict forKey:STValueTypeFilter];
    } else {
        // TODO: fix1
        //        [self.saveDic setObject:dict forKey:STValueTypeFilter];
        //        self.saveDic[@"STValueTypeFilter"] = nil;
        
    }
    if (makeUps) {
        self.bmpModels = [NSMutableSet setWithSet:makeUps];
        NSMutableArray *array = [NSMutableArray new];
        for(STMakeupDataModel *model in makeUps){
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:model.m_name forKey:STValueTypeMakeUpModelName];
            [dict setObject:@(model.m_bmpStrength) forKey:STValueTypeMakeUpModelValue];
            [dict setObject:@(model.m_bmpType) forKey:STValueTypeMakeUpModelType];
            [array addObject:dict];
        }
        [self.saveDic setObject:array forKey:STValueTypeMakeUp];
    }
//    NSLog(@"@@@ cur dic %@", self.saveDic);
    if (writeFile) {
        [self saveCurrentValuesToDiskWillQuit:writeFile];
    }
}


- (NSString*)dictionaryToJson:(NSDictionary *)dic{
    if (!dic) {
        return nil;
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)saveCurrentValuesToDiskWillQuit:(BOOL)quit{
    if (quit) {
        //only save beauty value at quit
        [self.saveDic setObject:[self updateLastBeautyParams:0] forKey:STValueTypeBeautyValueKey];
        [self.saveDic setObject:@(self.wholeEffectsIndex) forKey:STValueTypeWholeEffectsIndex];
        [self.saveDic setObject:@(self.iWholeFilterValue) forKey:STValueTypeWholeFilterValue];
        [self.saveDic setObject:@(self.iWholeMakeUpValue) forKey:STValueTypeWholeMakeupValue];
    }
//    NSLog(@"@@@ save dic quit %@", self.saveDic);
    NSString *str = [self dictionaryToJson:self.saveDic];
    BOOL bSaved = [str writeToFile:[self getFilePath:self.previewPath fileName:STCacheKeyBase]
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:nil];
    if(!bSaved) NSLog(@"@@@@ write error");
}


- (void)getDefaultValueFromDisk{ // 读取本地已存参数
    NSString *jsonStr = [NSString stringWithContentsOfFile:[self getFilePath:self.previewPath fileName:STCacheKeyBase] encoding:NSUTF8StringEncoding error:nil];
    NSDictionary * dic = [self dictionaryWithJsonString:jsonStr];
//    NSLog(@"@@@ getDic %@", dic);
    if (dic) {
        self.scrollType = ((NSNumber *)dic[STValueTypeScrollType]).intValue;
        self.oWholeFilterValue = self.iWholeFilterValue = ((NSNumber *)dic[STValueTypeWholeFilterValue]).floatValue;
        self.oWholeMakeUpValue = self.iWholeMakeUpValue = ((NSNumber *)dic[STValueTypeWholeMakeupValue]).floatValue;
        self.wholeEffectsIndex = ((NSNumber *)dic[STValueTypeWholeEffectsIndex]).intValue;
        if (dic[STValueTypeBeauty]) {
            [self getSelectedBeauty:dic[STValueTypeBeauty]];
        }
        if (dic[STValueTypeBeautyValueKey]) {
            [self getCacheParams:dic[STValueTypeBeautyValueKey]];
        }
        if (dic[STValueTypeFilter]) {
            [self getSelectedFilterModel:dic[STValueTypeFilter]];
        }
        if (dic[STValueTypeMakeUp]) {
            [self getSelectedMakeUps:dic[STValueTypeMakeUp]];
        }
        self.saveDic = dic.mutableCopy;
    }
}

- (void)getSelectedBeauty:(NSDictionary *)BeautyDic{
    int       type = ((NSNumber *)BeautyDic[STValueTypeBeautyType]).intValue;
    NSString *name = BeautyDic[STValueTypeBeautyName];
    BOOL selected  = [BeautyDic[STValueTypeSelected] boolValue];
    NSArray *array = nil;
    switch (type) {
        case STEffectsTypeBeautyWholeMakeup:
            for (STNewBeautyCollectionViewModel * model in _wholeMakeUpModels) model.selected = NO;
            array = _wholeMakeUpModels;
            break;
        case STEffectsTypeBeautyBase:
            for (STNewBeautyCollectionViewModel * model in _baseBeautyModels) model.selected = NO;
            array = _baseBeautyModels;
            break;
        case STEffectsTypeBeautyShape:
            for (STNewBeautyCollectionViewModel * model in _beautyShapeModels) model.selected = NO;
            array = _beautyShapeModels;
            break;
        case STEffectsTypeBeautyMicroSurgery:
            for (STNewBeautyCollectionViewModel * model in _microSurgeryModels) model.selected = NO;
            array = _microSurgeryModels;
            break;
        case STEffectsTypeBeautyAdjust:
            for (STNewBeautyCollectionViewModel * model in _adjustModels) model.selected = NO;
            array = _adjustModels;
            break;
        default:
            break;
    }
    for(STNewBeautyCollectionViewModel *model in array){
        if ([model.title isEqual:NSLocalizedString(name, nil)]) {
            self.beautyModelFromCache = model;
            self.beautyModelFromCache.selected = selected;
            break;
        }
    }
}

- (void)getCacheParams:(NSArray<NSNumber *> *)array{
    //base beauty
    for (int i = 0; i < array.count; i++) {
        _defaultValues[i] = array[i].intValue;
    }
    [self setBeautyParams];
}

- (void)getSelectedFilterModel:(NSDictionary *)filterDic{
    int       type = ((NSNumber *)filterDic[STValueTypeFilterModelType]).intValue;
    NSString *name = filterDic[STValueTypeFilterModelName];
    float    value = ((NSNumber *)filterDic[STValueTypeFilterModelValue]).floatValue;
    NSArray *array = nil;
    for (STCollectionViewDisplayModel * model in _filterDataSources[@(type)]) model.isSelected = NO;
    switch (type) {
        case STEffectsTypeFilterScenery:
            array = _filterDataSources[@(type)];
            break;
        case STEffectsTypeFilterPortrait:
            array = _filterDataSources[@(type)];
            break;
        case STEffectsTypeFilterStillLife:
            array = _filterDataSources[@(type)];
            break;
        case STEffectsTypeFilterDeliciousFood:
            array = _filterDataSources[@(type)];
            break;
        default:
            break;
    }
    for(STCollectionViewDisplayModel *model in array){
        if ([model.strName isEqual:name]) {
            model.isSelected = YES;
            model.value = value;
            self.filterModelFromCache = model;
            break;
        }
    }
}

- (void)getSelectedMakeUps:(NSArray<NSDictionary *>*)makeUpArray{
    for(NSDictionary *dic in makeUpArray){
        STMakeupDataModel *model = [self getSelectedMakeUp:dic];
        if (model) {
            if (!self.makeUpModelsFormCache) self.makeUpModelsFormCache = [NSMutableArray array];
            [self.makeUpModelsFormCache addObject:model];
        }
    }
}

- (STMakeupDataModel *)getSelectedMakeUp:(NSDictionary*)makeUpDic{
    int      type  = ((NSNumber *)makeUpDic[STValueTypeMakeUpModelType]).intValue;
    NSString *name = makeUpDic[STValueTypeMakeUpModelName];
    float    value = ((NSNumber *)makeUpDic[STValueTypeMakeUpModelValue]).floatValue;
    NSArray *array = nil;
    switch (type) {
        case STBMPTYPE_LIP:
            array = _m_lipsArr;
            break;
        case STBMPTYPE_EYE_BROW:
            array = _m_browsArr;
            break;
        case STBMPTYPE_EYE_BALL:
            array = _m_eyeballArr;
            break;
        case STBMPTYPE_EYE_LASH:
            array = _m_eyelashArr;
            break;
        case STBMPTYPE_EYE_LINER:
            array = _m_eyelinerArr;
            break;
        case STBMPTYPE_EYE_SHADOW:
            array = _m_eyeshadowArr;
            break;
        case STBMPTYPE_CHEEK:
            array = _m_cheekArr;
            break;
        case STBMPTYPE_NOSE:
            array = _m_noseArr;
            break;
        case STBMPTYPE_MASKHAIR:
            array = _m_maskhairArr;
            break;
        case STBMPTYPE_WHOLEMAKEUP:
            array = _m_wholeMakeArr;
            break;
        default:
            break;
    }
    for(STMakeupDataModel *model in array){
        if ([model.m_name isEqual:name]) {
            model.m_selected = YES;
            model.m_bmpStrength = value;
            return model;
        }
    }
    return nil;
}


- (void)setBeautyParams{
    //base beauty 6
    int stride = 0;
    for(int i = 0; i < self.baseBeautyModels.count; i++){
        self.baseBeautyModels[i].beautyValue = _defaultValues[i];
    }
    
    //shape 5
    stride = 6;
    for(int i = 0; i < self.beautyShapeModels.count; i++){
        self.beautyShapeModels[i].beautyValue = _defaultValues[stride+i];
    }
    
    //micro 19
    stride = 11;
    for(int i = 0; i < self.microSurgeryModels.count; i++){
        self.microSurgeryModels[i].beautyValue = _defaultValues[stride+i];
    }
    
    //adjust 4
    stride = 30;
    for(int i = 0; i < self.adjustModels.count; i++){
        self.adjustModels[i].beautyValue = _defaultValues[stride+i];
    }
}

- (void)resetBeautyParamsWithType:(STEffectsType)type{
    switch (type) {
        case STEffectsTypeBeautyBase:
            self.baseBeautyModels[0].beautyValue = 0;
            //美白2
            self.baseBeautyModels[1].beautyValue = 0;
            //美白3
            self.baseBeautyModels[2].beautyValue = 0;
            //红润
            self.baseBeautyModels[3].beautyValue = 0;
            //磨皮1
            self.baseBeautyModels[4].beautyValue = 0;
            //磨皮2
            self.baseBeautyModels[5].beautyValue = 50;
            for(int i = 0; i < self.baseBeautyModels.count; i++){
                [self updateCurrentBeautyValue:self.baseBeautyModels[i]];
            }
            break;
        case STEffectsTypeBeautyShape:
            //瘦脸
            self.beautyShapeModels[0].beautyValue = 34;
            //大眼
            self.beautyShapeModels[1].beautyValue = 29;
            //小脸
            self.beautyShapeModels[2].beautyValue = 10;
            //窄脸
            self.beautyShapeModels[3].beautyValue = 25;
            //圆眼
            self.beautyShapeModels[4].beautyValue = 7;
            for(int i = 0; i < self.beautyShapeModels.count; i++){
                [self updateCurrentBeautyValue:self.beautyShapeModels[i]];
            }
            break;
        case STEffectsTypeBeautyMicroSurgery:
            //小头
            self.microSurgeryModels[0].beautyValue = 0;
            //瘦脸型
            self.microSurgeryModels[1].beautyValue = 45;
            //下巴
            self.microSurgeryModels[2].beautyValue = 20;
            //额头
            self.microSurgeryModels[3].beautyValue = 0;
            //苹果肌
            self.microSurgeryModels[4].beautyValue = 30;
            //瘦鼻翼
            self.microSurgeryModels[5].beautyValue = 21;
            //长鼻
            self.microSurgeryModels[6].beautyValue = 0;
            //侧脸隆鼻
            self.microSurgeryModels[7].beautyValue = 10;
            //嘴形
            self.microSurgeryModels[8].beautyValue = 51;
            //缩人中
            self.microSurgeryModels[9].beautyValue = 0;
            //眼距
            self.microSurgeryModels[10].beautyValue = -23;
            //眼睛角度
            self.microSurgeryModels[11].beautyValue = 0;
            //开眼角
            self.microSurgeryModels[12].beautyValue = 0;
            //亮眼
            self.microSurgeryModels[13].beautyValue = 25;
            //祛黑眼圈
            self.microSurgeryModels[14].beautyValue = 69;
            //祛法令纹
            self.microSurgeryModels[15].beautyValue = 60;
            //白牙
            self.microSurgeryModels[16].beautyValue = 20;
            //瘦颧骨
            self.microSurgeryModels[17].beautyValue = 36;
            //开外眼角
            self.microSurgeryModels[18].beautyValue = 0;
            for(int i = 0; i < self.microSurgeryModels.count; i++){
                [self updateCurrentBeautyValue:self.microSurgeryModels[i]];
            }
            break;
        case STEffectsTypeBeautyAdjust:
            //对比度
            self.adjustModels[0].beautyValue = 0;
            //饱和度
            self.adjustModels[1].beautyValue = 0;
            //锐化
            self.adjustModels[2].beautyValue = 50;
            //清晰度
            self.adjustModels[3].beautyValue = 20;
            for(int i = 0; i < self.adjustModels.count; i++){
                [self updateCurrentBeautyValue:self.adjustModels[i]];
            }
            break;
        default:
            break;
    }
}


- (void)updateCurrentBeautyValue:(STNewBeautyCollectionViewModel *)model{
    [self updateBeautyDataSources:model];
}

- (void)updateBeautyDataSources:(STNewBeautyCollectionViewModel *)model{
    //1.update manul operation values
    [self.beautyValueManager.manualBeautyValues setObject:@(model.beautyValue)
                                                   forKey:@(model.beautyType)];
    //update 基础美颜、美形、微整形、调整
    NSDictionary<NSNumber *, NSNumber *> *dataSource = [self.beautyValueManager getBeautyValue];
    NSArray *modelArray = @[self.baseBeautyModels,
                            self.beautyShapeModels,
                            self.microSurgeryModels,
                            self.adjustModels];
    for(NSArray<STNewBeautyCollectionViewModel *> *models in modelArray){
        for(STNewBeautyCollectionViewModel *curModel in models){
            //update current value
            if(curModel.beautyType == model.beautyType){
                model.beautyValue = dataSource[@(model.beautyType)].intValue;
                break;
            }
        }
    }
    
    //2.update defaul values
    [self.beautyValueManager.defaultBeautyValues setObject:@(model.beautyValue)
                                                    forKey:@(model.beautyType)];
}


//get sticker overLap values
- (void)setBeautyParamsWithBeautyInfo:(st_effect_beauty_info_t)beautyInfo{
    
    //update preview value from sticker values
    [self updateBaseBeauty:beautyInfo];
    [self updateReshap:beautyInfo];
    [self updatePlastic:beautyInfo];
    [self updateTone:beautyInfo];
    
    //这里要更新 overlap values
    STBeautyType beautyType = [self mapType:beautyInfo.type];
    [self.beautyValueManager.stickerBeautyValues setObject:@((int)(beautyInfo.strength * 100))
                                                    forKey:@(beautyType)];
}

- (STBeautyType)mapType:(st_effect_beauty_type_t)type{
    switch (type) {
        case EFFECT_BEAUTY_BASE_WHITTEN:
            return STBeautyTypeWhiten1;
        case EFFECT_BEAUTY_BASE_REDDEN:
            return STBeautyTypeRuddy;
        case EFFECT_BEAUTY_BASE_FACE_SMOOTH:
            return STBeautyTypeDermabrasion1;
        case EFFECT_BEAUTY_RESHAPE_SHRINK_FACE:
            return STBeautyTypeShrinkFace;
        case EFFECT_BEAUTY_RESHAPE_ENLARGE_EYE:
            return STBeautyTypeEnlargeEyes;
        case EFFECT_BEAUTY_RESHAPE_SHRINK_JAW:
            return STBeautyTypeShrinkJaw;
        case EFFECT_BEAUTY_PLASTIC_THIN_FACE:
            return STBeautyTypeThinFaceShape;
        case EFFECT_BEAUTY_PLASTIC_NARROW_NOSE:
            return STBeautyTypeNarrowNose;
        case EFFECT_BEAUTY_TONE_CONTRAST:
            return STBeautyTypeContrast;
        case EFFECT_BEAUTY_TONE_CLEAR:
            return STBeautyTypeClarity;
        case EFFECT_BEAUTY_TONE_SHARPEN:
            return STBeautyTypeSharpen;
        case EFFECT_BEAUTY_TONE_SATURATION:
            return STBeautyTypeSaturation;
        case EFFECT_BEAUTY_RESHAPE_NARROW_FACE:
            return STBeautyTypeNarrowFace;
        case EFFECT_BEAUTY_PLASTIC_THINNER_HEAD:
            return STBeautyTypeHead;
        case EFFECT_BEAUTY_RESHAPE_ROUND_EYE:
            return STBeautyTypeRoundEye;
        case EFFECT_BEAUTY_PLASTIC_APPLE_MUSLE:
            return STBeautyTypeAppleMusle;
        case EFFECT_BEAUTY_PLASTIC_PROFILE_RHINOPLASTY:
            return STBeautyTypeProfileRhinoplasty;
        case EFFECT_BEAUTY_PLASTIC_BRIGHT_EYE:
            return STBeautyTypeBrightEye;
        case EFFECT_BEAUTY_PLASTIC_REMOVE_DARK_CIRCLES:
            return STBeautyTypeRemoveDarkCircles;
        case EFFECT_BEAUTY_PLASTIC_WHITE_TEETH:
            return STBeautyTypeWhiteTeeth;
        case EFFECT_BEAUTY_PLASTIC_SHRINK_CHEEKBONE:
            return STBeautyTypeShrinkCheekbone;
        case EFFECT_BEAUTY_PLASTIC_OPEN_CANTHUS:
            return STBeautyTypeOpenCanthus;
        case EFFECT_BEAUTY_PLASTIC_REMOVE_NASOLABIAL_FOLDS://祛法令纹
            return STBeautyTypeRemoveNasolabialFolds;
        case EFFECT_BEAUTY_PLASTIC_OPEN_EXTERNAL_CANTHUS://开外眼角
            return STBeautyTypeOpenExternalCanthusRatio;
        case EFFECT_BEAUTY_PLASTIC_CHIN_LENGTH://下巴
            return STBeautyTypeChin;
        case EFFECT_BEAUTY_PLASTIC_HAIRLINE_HEIGHT://额头
            return STBeautyTypeHairLine;
        case EFFECT_BEAUTY_PLASTIC_NOSE_LENGTH://长鼻
            return STBeautyTypeLengthNose;
        case EFFECT_BEAUTY_PLASTIC_MOUTH_SIZE://嘴形
            return STBeautyTypeMouthSize;
        case EFFECT_BEAUTY_PLASTIC_PHILTRUM_LENGTH://缩人中
            return STBeautyTypeLengthPhiltrum;
        case EFFECT_BEAUTY_PLASTIC_EYE_ANGLE://眼睛角度
            return STBeautyTypeEyeAngle;
        case EFFECT_BEAUTY_PLASTIC_EYE_DISTANCE ://眼距
            return STBeautyTypeEyeDistance;
        default:
            return -1;
    }
}

- (void)removeSticker{
    if(_valueStack.stickerValueStack.count) [_valueStack.stickerValueStack removeLastObject];
}

- (void)restoreBeforeStickerParametersMenu:(BOOL)Menu{
    //update 基础美颜、美形、微整形、调整
    NSDictionary<NSNumber *, NSNumber *> *dataSource = [self.beautyValueManager getBeautyValue];
    NSArray *modelArray = @[self.baseBeautyModels,
                            self.beautyShapeModels,
                            self.microSurgeryModels,
                            self.adjustModels];
    for(NSArray<STNewBeautyCollectionViewModel *> *models in modelArray){
        for(STNewBeautyCollectionViewModel *model in models){
            model.beautyValue = dataSource[@(model.beautyType)].intValue;
        }
    }
}


//更新基础美颜
- (void)updateBaseBeauty:(st_effect_beauty_info_t)beauty_info{
    switch (beauty_info.type) {
        case 101:{
            switch (beauty_info.mode) {
                case 0:
                    self.baseBeautyModels[0].beautyValue = beauty_info.strength  * 100;
                    self.baseBeautyModels[1].beautyValue = 0;
                    self.baseBeautyModels[2].beautyValue = 0;
                    break;
                case 1:
                    self.baseBeautyModels[0].beautyValue = 0;
                    self.baseBeautyModels[1].beautyValue = beauty_info.strength  * 100;
                    self.baseBeautyModels[2].beautyValue = 0;
                    break;
                case 2:
                    self.baseBeautyModels[0].beautyValue = 0;
                    self.baseBeautyModels[1].beautyValue = 0;
                    self.baseBeautyModels[2].beautyValue = beauty_info.strength  * 100;
                    break;
                default:
                    break;
            }
            break;
        }
        case 102:{
            self.baseBeautyModels[3].beautyValue = beauty_info.strength  * 100;
            break;
        }
        case 103:{
            switch (beauty_info.mode) {
                case 0:
                    self.baseBeautyModels[5].beautyValue = beauty_info.strength  * 100;
                    self.baseBeautyModels[4].beautyValue = 0;
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

//更新美形
- (void)updateReshap:(st_effect_beauty_info_t)beauty_info{
    switch (beauty_info.type) {
        case 201:{//瘦脸
            self.beautyShapeModels[0].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 202:{//大眼
            self.beautyShapeModels[1].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 203:{//小脸
            self.beautyShapeModels[2].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 204:{//窄脸
            self.beautyShapeModels[3].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 205:{//圆眼
            self.beautyShapeModels[4].beautyValue = beauty_info.strength * 100;
            break;
        }
        default:
            break;
    }
}

//更新微整形
- (void)updatePlastic:(st_effect_beauty_info_t)beauty_info{
    switch (beauty_info.type) {
        case 301:{
            self.microSurgeryModels[0].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 302:{
            self.microSurgeryModels[1].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 303:{
            self.microSurgeryModels[2].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 304:{
            self.microSurgeryModels[3].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 305:{
            self.microSurgeryModels[4].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 306:{
            self.microSurgeryModels[5].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 307:{
            self.microSurgeryModels[6].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 308:{
            self.microSurgeryModels[7].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 309:{
            self.microSurgeryModels[8].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 310:{
            self.microSurgeryModels[9].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 311:{
            self.microSurgeryModels[10].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 312:{
            self.microSurgeryModels[11].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 313:{
            self.microSurgeryModels[12].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 314:{
            self.microSurgeryModels[13].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 315:{
            self.microSurgeryModels[14].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 316:{
            self.microSurgeryModels[15].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 317:{
            self.microSurgeryModels[16].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 318:{
            self.microSurgeryModels[17].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 319:{
            self.microSurgeryModels[18].beautyValue = beauty_info.strength * 100;
            break;
        }
        default:
            break;
    }
}

//更新调整
- (void)updateTone:(st_effect_beauty_info_t)beauty_info{
    switch (beauty_info.type) {
        case 601:{//对比度
            self.adjustModels[0].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 602:{//饱和度
            self.adjustModels[1].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 603:{//锐化
            self.adjustModels[2].beautyValue = beauty_info.strength * 100;
            break;
        }
        case 604:{//锐化
            self.adjustModels[3].beautyValue = beauty_info.strength * 100;
            break;
        }
        default:
            break;
    }
}

- (NSArray *)getCurrentFilterDataSourcesByName:(NSString *)modelName{
    if (modelName) {
        NSArray<NSArray<STCollectionViewDisplayModel *> *> *arrays = _filterDataSources.allValues;
        for(NSArray<STCollectionViewDisplayModel *> *array in arrays){
            if ([self filterDataSorces:array containModelName:modelName]) {
                return array;
            }
        }
    }
    return nil;
}

- (BOOL)filterDataSorces:(NSArray<STCollectionViewDisplayModel *>*)array
            containModel:(STCollectionViewDisplayModel *)model{
    if (!array || !model) {
        return NO;
    }
    return [self filterDataSorces:array containModelName:model.strName];
}

- (BOOL)filterDataSorces:(NSArray<STCollectionViewDisplayModel *>*)array
        containModelName:(NSString *)modelName{
    if (!array || !modelName) {
        return NO;
    }
    for(STCollectionViewDisplayModel *model in array){
        if ([model.strName isEqual:modelName]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkActiveCodeWithData:(NSData *)dataLicense{
    NSString *strKeyActiveCode = @"ACTIVE_CODE_ONLINE";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strActiveCode = [userDefaults objectForKey:strKeyActiveCode];
    st_result_t iRet = ST_E_FAIL;
    
    if (strActiveCode.length) {
        iRet = st_mobile_check_activecode_from_buffer(
                                                      [dataLicense bytes],
                                                      (int)[dataLicense length],
                                                      strActiveCode.UTF8String,
                                                      (int)[strActiveCode length]
                                                      );
        
        if (ST_OK == iRet) {
            return YES;
        }
    }
    char active_code[10240];
    int active_code_len = 10240;
    
#if USE_SDK_ONLINE_ACTIVATION
    iRet = st_mobile_generate_activecode_online([[NSBundle mainBundle] pathForResource:@"SENSEMEONLINE" ofType:@"lic"].UTF8String, active_code, &active_code_len);
#else
    iRet = st_mobile_generate_activecode_from_buffer(
                                                     [dataLicense bytes],
                                                     (int)[dataLicense length],
                                                     active_code,
                                                     &active_code_len
                                                     );
    
#endif
    
    strActiveCode = [[NSString alloc] initWithUTF8String:active_code];
    
    
    if (iRet == ST_OK && strActiveCode.length) {
        
        [userDefaults setObject:strActiveCode forKey:strKeyActiveCode];
        [userDefaults synchronize];
        
        return YES;
    }
    
    return NO;
}



- (NSString *)getSHA1StringWithData:(NSData *)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *strSHA1 = [NSMutableString string];
    
    for (int i = 0 ; i < CC_SHA1_DIGEST_LENGTH ; i ++) {
        
        [strSHA1 appendFormat:@"%02x" , digest[i]];
    }
    
    return strSHA1;
}

@end
