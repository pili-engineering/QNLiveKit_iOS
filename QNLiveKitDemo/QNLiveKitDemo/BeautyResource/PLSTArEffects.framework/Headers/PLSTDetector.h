//
//  PLSTDetector.h
//  PLSTArEffects
//
//  Created by 李政勇 on 2020/6/3.
//  Copyright © 2020 Pili. All rights reserved.
//

#import "core/include/st_mobile_human_action.h"
#import "core/include/st_mobile_animal.h"

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct QNAllResult{
    st_mobile_human_action_t *humanResult;
    st_mobile_animal_face_t *animal_result;
    int animal_count;
}QNAllResult;

typedef struct QNDetectConfig{
    unsigned long long humanConfig;
    unsigned long long animalConfig;
}QNDetectConfig;

/*!
 @class PLSTDetector
 @abstract 检测类，检测人脸、动作等
 */
@interface PLSTDetector : NSObject

/*!
 @method 
 @abstract 初始化方法
 
 @param modelPath 模型路径
 @param config 配置信息，二进制位表示
 
 @since v1.0.0
 */
- (nullable instancetype)initWith:(NSString*)modelPath config:(unsigned int)config;

- (instancetype)initWithConfig:(unsigned int)config;

/// 添加model
/// @param modelPath 模型路径
- (st_result_t)setModelPath:(NSString *)modelPath;

/*!
 @method 
 @abstract 添加子模型
 
 @param subModelPath 子模型路径
 
 @since v1.0.0
 */
- (st_result_t)addSubModel:(NSString*)subModelPath;

/*!
 @method
 @abstract 添加动物检测模型
 
 @param catFaceModel 动物检测模型路径
 
 @since v1.3.1
 */
- (st_result_t)addAnimalModelModel:(NSString *)animalFaceModel;
/*!
 @method 
 @abstract 检测视频帧
 
 @param buffer 像素buffer
 @param camOrt 视频方向
 @param config 待检测项，二进制位表示
 @param res 检测结果，由用户分配内存
 
 @since v1.0.0
 */
- (st_result_t)detect:(CVPixelBufferRef)buffer
    cameraOrientation:(AVCaptureVideoOrientation)camOrt
         detectConfig:(unsigned long long)config
               result:(st_mobile_human_action_t*)res;

/*!
 @method
 @abstract 检测视频帧
 
 @param buffer 像素buffer
 @param camOrt 视频方向
 @param config 待检测项，二进制位表示
 @param res 检测结果，由用户分配内存 (human + cat)
 
 @since v1.3.1
 */
- (st_result_t)detect:(CVPixelBufferRef)buffer
    cameraOrientation:(AVCaptureVideoOrientation)camOrt
         detectConfig:(QNDetectConfig)config
          allResult:(QNAllResult*)res;

@end

NS_ASSUME_NONNULL_END
