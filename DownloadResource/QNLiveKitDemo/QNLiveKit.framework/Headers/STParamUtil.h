//
//  STParamUtil.h
//
//  Created by HaifengMay on 16/11/5.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

/*
 * function: 主要用来获取一些系统的参数，如 CPU占用率，帧率等
 */
#import <Foundation/Foundation.h>
#import "st_mobile_human_action.h"
#import "st_mobile_common.h"
#import "st_mobile_effect.h"
#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define STWeakSelf __weak __typeof(self) weakSelf = self;

#define STStrongSelf __strong __typeof(weakSelf) strongSelf = weakSelf;

#define USE_SERVER_ONLINE_ACTIVATION 1
#define USE_SDK_ONLINE_ACTIVATION 0

#ifndef ST_PERFORMANCE_HINT_T_IOS
#define ST_PERFORMANCE_HINT_T_IOS 0
#endif

#define  Threshold_1_2_22(x) x*0.22   // [0,1] -> [0, 0.22]

typedef NS_ENUM(NSInteger, STTitleViewStyle) {
    STTitleViewStyleOnlyImage = 0,
    STTitleViewStyleOnlyCharacter
};

typedef NS_ENUM(NSInteger, STBeautyCategory) {
    STBeautyCategoryWholeEffect,
    STBeautyCategoryBase,
    STBeautyCategoryShape,
    STBeautyCategoryMicroPlastic,
    STBeautyCategoryMakeUp,
    STBeautyCategoryFilter,
    STBeautyCategoryAdjust
};

typedef NS_ENUM(NSInteger, STBeautyType) {
    
    STBeautyTypeNone,
    
    
    STBeautyTypeMakeupZPYuanQi,
    STBeautyTypeMakeupZBZiRan,
    STBeautyTypeMakeupZBYuanQi,
    STBeautyTypeMakeupZBYuanHua,
    STBeautyTypeMakeupZPZiRan,
    STBeautyTypeMakeupNvshen,
    STBeautyTypeMakeupRedwine,
    STBeautyTypeMakeupSweet,
    STBeautyTypeMakeupWestern,
    STBeautyTypeMakeupWhitetea,
    STBeautyTypeMakeupZhigan,
    STBeautyTypeMakeupDeep,
    STBeautyTypeMakeupTianran,
    STBeautyTypeMakeupSweetgirl,
    STBeautyTypeMakeupOxygen,

    //16
    STBeautyTypeWhiten1,
    STBeautyTypeWhiten2,
    STBeautyTypeWhiten3,
    STBeautyTypeRuddy,
    STBeautyTypeDermabrasion1,
    STBeautyTypeDermabrasion2,
    STBeautyTypeDehighlight,
    //23
    STBeautyTypeShrinkFace,
    STBeautyTypeEnlargeEyes,
    STBeautyTypeShrinkJaw,
    STBeautyTypeNarrowFace,
    STBeautyTypeRoundEye,
    STBeautyTypeHead,
    //29
    STBeautyTypeThinFaceShape,
    STBeautyTypeChin,
    STBeautyTypeHairLine,
    STBeautyTypeNarrowNose,
    STBeautyTypeLengthNose,
    STBeautyTypeMouthSize,
    STBeautyTypeLengthPhiltrum,
    
    STBeautyTypeAppleMusle,
    STBeautyTypeProfileRhinoplasty,
    STBeautyTypeBrightEye,
    STBeautyTypeRemoveDarkCircles,
    STBeautyTypeWhiteTeeth,
    STBeautyTypeShrinkCheekbone,
    STBeautyTypeEyeDistance,
    STBeautyTypeEyeAngle,
    STBeautyTypeOpenCanthus,
    STBeautyTypeOpenExternalCanthusRatio,
    STBeautyTypeRemoveNasolabialFolds,
    
    STBeautyTypeContrast,
    STBeautyTypeSaturation,
    STBeautyTypeSharpen,
    STBeautyTypeClarity,
};

typedef NS_ENUM(NSInteger, STStickerType) {
    
    STStickerTypeNew,
    STStickerType2D,
    STStickerTypeAvatar,
    STStickerType3D,
    STStickerTypeGesture,
    STStickerTypeSegment,
    STStickerTypeDeformation,
    STStickerTypeMorph,
    STStickerTypeParticle,
    STStickerTypeObjectTrack
};

typedef NS_ENUM(NSInteger, STEffectsType) {
    
    STEffectsTypeNone = 0,
    
    STEffectsTypeSticker2D,
    STEffectsTypeStickerAvatar,
    STEffectsTypeSticker3D,
    STEffectsTypeStickerGesture,
    STEffectsTypeStickerSegment,
    STEffectsTypeStickerFaceChange,
    STEffectsTypeStickerFaceDeformation,
    STEffectsTypeStickerParticle,
    STEffectsTypeStickerNew,
    STEffectsTypeStickerMy,
    STEffectsTypeStickerAdd,
    
    STEffectsTypeObjectTrack,
    
    STEffectsTypeBeautyFilter,
    STEffectsTypeBeautyWholeMakeup,
    STEffectsTypeBeautyBase,
    STEffectsTypeBeautyShape,
    STEffectsTypeBeautyBody,
    STEffectsTypeBeautyMicroSurgery,
    STEffectsTypeBeautyMakeUp,
    STEffectsTypeBeautyAdjust,
    
    STEffectsTypeFilterPortrait,
    STEffectsTypeFilterScenery,
    STEffectsTypeFilterStillLife,
    STEffectsTypeFilterDeliciousFood,
    
};


void addSubModel(st_handle_t handle, NSString* modelName);
void setBeauty(st_handle_t handle, st_effect_beauty_type_t type, NSString *path, float value);
//void setBeautify(st_handle_t beautifyHandle, st_effect_beauty_type_t type, NSString *path);
//void setBeautifyParam(st_handle_t beautifyHandle, st_effect_beauty_type_t type, float value);
//void setBeautifyMode(st_handle_t beautyHandle, st_effect_beauty_type_t type, int mode);
float getBodyRatio(float value);
float getNewBodyRatio(float value);
float getLongLegsRatio(float value);
float getShouldersValue(float value);
float getThinLegValue(float value);

@interface STParamUtil : NSObject

/*
 * 返回CPU占用率的分子（分母为100）
 */
+ (float) getCpuUsage;


/**
 获取通用物体素材路径

 @return 路径数组
 */
+ (NSArray *)getTrackerPaths;


/**
 获取特定类型贴纸素材路径

 @param type STEffectsType
 @return 路径数组
 */
+ (NSArray *)getStickerPathsByType:(STEffectsType)type;


/**
 获取特定类型滤镜路径

 @param type STEffectsType
 @return 路径数组
 */
+ (NSArray *)getFilterModelPathsByType:(STEffectsType)type;

+ (UIAlertController *)showAlertWithTitle:(NSString *)title Message:(NSString *)message actions:(NSArray *)action onVC:(UIViewController *)controller;

+ (NSArray *)getFilterModelsByType:(STEffectsType)type;

+ (NSString *)getDocumentPath:(NSString *)name needCreate:(BOOL)create;

@end
