//
//  STBMPModel.h
//  SenseMeEffects
//
//  Created by sensetimesunjian on 2019/5/10.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SenseArMaterial.h"

typedef NS_ENUM(NSInteger, STBMPTYPE){
    STBMPTYPE_WHOLEMAKEUP = 0,      // 整妆
    STBMPTYPE_MASKHAIR,         // 染发
    STBMPTYPE_LIP,              // 口红
    STBMPTYPE_CHEEK,            // 腮红
    STBMPTYPE_NOSE,             // 修容
    STBMPTYPE_EYE_BROW,         // 眉毛
    STBMPTYPE_EYE_SHADOW,       // 眼影
    STBMPTYPE_EYE_LINER,        // 眼线
    STBMPTYPE_EYE_LASH,         // 眼睫毛
    STBMPTYPE_EYE_BALL,         // 美瞳
    STBMPTYPE_COUNT,
};

typedef NS_ENUM(NSInteger, STState){
    STStateNotNeedDownload,
    STStateNeedDownlad,
    STStateDownloading,
    STStateDownloaded,
};

@interface STMakeupDataModel : NSObject<NSCopying, NSMutableCopying>

@property (nonatomic, strong) SenseArMaterial *m_material;
@property (nonatomic, strong) UIImage *m_thumbImage;
@property (nonatomic,   copy) NSString *m_iconDefault;
@property (nonatomic,   copy) NSString *m_iconHighlight;
@property (nonatomic,   copy) NSString *m_name;
@property (nonatomic,   copy) NSString *m_zipPath;
@property (nonatomic, assign) BOOL m_selected;
@property (nonatomic, assign) STBMPTYPE m_bmpType;
@property (nonatomic, assign) int m_index;
@property (nonatomic, assign) float m_bmpStrength;
@property (nonatomic, assign) BOOL m_fromOnLine;
@property (nonatomic, assign) STState m_state;

@end

