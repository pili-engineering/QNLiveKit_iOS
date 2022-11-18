//
//  PLSTEffectManager.h
//  PLSTArEffects
//
//  Created by 孙慕 on 2021/7/5.
//  Copyright © 2021 Pili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PLSTAudioDelegate.h"
#import "core/include/st_mobile_common.h"
#import "core/include/st_mobile_effect.h"

#import "PLSTAudioDelegate.h"
#import <CoreVideo/CoreVideo.h>
#import <OpenGLES/EAGL.h>

#import "PLSTDetector.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @class PLSTArEffectManager
 @abstract 特效管理类，负责特效的设置更新
 */
@interface PLSTEffectManager : NSObject

/*!
 @property isFrontCamera
 @brief 是否是前置摄像头，需要用户更新
 
 @since v1.3.0
 */
@property(nonatomic, assign) BOOL isFrontCamera;

/*!
 @property effectOn
 @brief 是否启用特效
 
 @since v1.3.0
 */
@property(nonatomic, assign) BOOL effectOn;

/*!
 @property needDetectAnimal
 @brief 是否启用猫脸检测，默认  NO
 
 @since v1.3.0
 */
@property (nonatomic, assign) BOOL needDetectAnimal;

/*!
 @property glContext
 @brief OpenGL context
 
 @since v1.3.0
 */
@property(nonatomic, strong, readonly) EAGLContext* glContext;

/*!
 @property audioDelegate
 @brief 音频代理，负责播放贴纸里的音效，有默认实现
 
 @since v1.0.0
 */
@property(nonatomic, strong) id<PLSTAudioDelegate> audioDelegate;

/*!
 @method
 @abstract 初始化方法
 
 @param context .
 
 @since v1.3.0
 */
- (instancetype)initWithContext:(EAGLContext*)context handleConfig:(uint32_t)handleConfig;


/*!
 @method
 @abstract 更换缓存中的素材包 (删除已有的素材包)
 @param path .资源路径
 @param package_id .
 
 @since v1.0.0
 */
- (st_result_t)updateSticker:(NSString *)path pID:(int *)package_id;;


/*!
 @method
 @abstract  待添加的素材包文件路径
 @param path .资源路径
 @param package_id .
 
 @since v1.0.0
 */
- (st_result_t)addSticker:(NSString *)path pID:(int *)package_id;


/*!
 @method
 @abstract 删除指定素材包
 
 @param package_id .
 
 @since v1.0.0
 */
- (st_result_t)removeSticker:(int)package_id;


/*!
 @method
 @abstract 更新美颜强度
 
 @param intensity 强度(根据不同类型有[0 ~ 1]或[-1 ~ 1])
 @param type 美颜美妆类型
 
 @since v1.0.0
 */
- (st_result_t)updateBeautify:(float)intensity type:(st_effect_beauty_type_t)type;
/*!
 @method
 @abstract加载美颜素材，可以通过将path参数置为nullptr，清空之前类型设置的对应素材（如美颜、美妆、滤镜素材）
 目前对美颜支持设置美白、红润两种自定义的素材
 @param[in] type 美颜美妆类型
 @param[in] path 待添加的素材文件路径
 @return 成功返回ST_OK, 失败返回其他错误码, 错误码定义在st_mobile_common.h中, 如ST_E_FAIL等
 
 /@since v1.3.1
 */
- (st_result_t)setBeautify:(NSString *)path type:(st_effect_beauty_type_t)type;

/*!
 @method
 @abstract设置美颜的模式, 目前仅对磨皮和美白有效，支持的有效模式为[0, 1, 2]三个值
 @param[in] type 美颜美妆类型
 @param[in] mode 模式，支持的有效模式为[0, 1, 2]三个值
 @return 成功返回ST_OK, 失败返回其他错误码, 错误码定义在st_mobile_common.h中, 如ST_E_FAIL等
 
 /@since v1.3.1
 */
- (st_result_t)setBeautifyMode:(int)mode type:(st_effect_beauty_type_t)type;

/*!
@brief 设置贴纸素材包内部美颜组合的强度，强度范围[0.0, 1.0]
@param[in] handle 已初始化的特效句柄
@param[in] group 美颜组合类型，目前只支持设置美妆、滤镜组合的强度
@param[in] strength 强度值
@return 成功返回ST_OK, 失败返回其他错误码, 错误码定义在st_mobile_common.h中, 如ST_E_FAIL等
 */
- (st_result_t)setPackageBeautyGroupStrengthPkg_id:(int)pkg_id group:(st_effect_beauty_group_t)group strength:(float) strength;

/*!
 @method
 @abstract 在处理队列里同步运行
 
 @param block .
 
 @since v1.3.0
 */
- (void)runSyncOnProcessingQueue:(void (^)(void))block;

/*!
 @method
 @abstract 在处理队列里异步运行
 
 @param block .
 
 @since v1.3.0
 */
- (void)runAsyncOnProcessingQueue:(void (^)(void))block;

// 获取当前特效句柄
- (st_handle_t)getMobileEffectHandle;

//获取需要的检测配置选项
-(uint64_t)getEffectDetectConfig;

//获取目前需要的动物检测类型
-(uint64_t)getEffectAnimalDetectConfig;


/*!
 @method
 @abstract 处理pixelbuffer， 仅支持BGRA格式
 
 @param buffer 像素buffer
 @param camOrt 视频方向
 @param res detector检测结果
 
 @since v1.3.0
 */
- (void)processBuffer:(CVPixelBufferRef)buffer
    cameraOrientation:(AVCaptureVideoOrientation)camOrt
         detectResult:(QNAllResult*)res;


/*!
 @method
 @abstract 处理纹理, 若用户直接调用此方法请确保inputtexture所在的OpenGL context和初始化manager的context一致
 
 @param inputTexture 输入纹理
 @param width 纹理宽度
 @param height 纹理高度
 @param camOrt 视频方向
 @param res detector检测结果
 
 @since v1.3.0
 */
- (GLuint)processTexture:(GLuint)inputTexture
                   width:(int)width
                  height:(int)height
       cameraOrientation:(AVCaptureVideoOrientation)camOrt
            detectResult:(QNAllResult*)res;

@end


NS_ASSUME_NONNULL_END
