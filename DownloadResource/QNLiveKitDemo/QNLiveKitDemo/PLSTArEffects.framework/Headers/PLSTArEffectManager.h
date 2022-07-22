//
//  PLSTArEffectManager.h
//  PLSTArEffects
//
//  Created by 李政勇 on 2020/6/3.
//  Copyright © 2020 Pili. All rights reserved.
//

#import "core/include/st_mobile_beautify.h"
#import "core/include/st_mobile_common.h"
#import "core/include/st_mobile_makeup.h"
#import "PLSTAudioDelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PLSTEffectModel <NSObject>

@optional

/*!
 @property triggerAction
 @brief 触发效果的动作类型，由二进制位表示，可进行或运算。设置效果后由SDK填充此属性
 
 @since v1.0.0
 */
@property(nonatomic, assign) unsigned long long triggerAction;

@required

/*!
 @property materialPath
 @brief 资源包的路径
 
 @since v1.0.0
 */
@property(nonatomic, copy) NSString* materialPath;

@end


/*!
 @class PLSTArEffectManager
 @abstract 特效管理类，负责特效的设置更新
 */
@interface PLSTArEffectManager : NSObject

/*!
 @property isFrontCamera
 @brief 是否是前置摄像头，需要用户更新
 
 @since v1.0.0
 */
@property(nonatomic, assign) BOOL isFrontCamera;

/*!
 @property effectOn
 @brief 是否启用特效
 
 @since v1.0.0
 */
@property(nonatomic, assign) BOOL effectOn;

/*!
 @property makeupOn
 @brief 是否启用美妆
 
 @since v1.0.0
 */
@property(nonatomic, assign) BOOL makeupOn;

/*!
 @property beautifyOn
 @brief 是否启用美颜，包括美白、磨皮、红润、美型和美体
 
 @since v1.0.0
 */
@property(nonatomic, assign) BOOL beautifyOn;

/*!
 @property triggerAction
 @brief 触发的动作类型，包括美妆和贴纸。二进制位表示，可以或运算
 
 @since v1.0.0
 */
@property(nonatomic, assign, readonly) unsigned long long triggerAction;

/*!
 @property glContext
 @brief OpenGL context
 
 @since v1.0.0
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
 
 @since v1.0.0
 */
- (nullable instancetype)initWithContext:(EAGLContext*)context;

/*!
 @method
 @abstract 更新滤镜
 
 @param filter .
 
 @since v1.0.0
 */
- (st_result_t)updateFilter:(nullable id<PLSTEffectModel>)filter;

/*!
 @method
 @abstract 更新滤镜强度
 
 @param intensity 强度(0-1)
 
 @since v1.0.0
 */
- (st_result_t)updateFilterIntensity:(float)intensity;

/*!
 @method
 @abstract 更新美妆, 传空取消当前类型的美妆
 
 @param makeup .
 @param type 美妆类型
 
 @since v1.0.0
 */
- (st_result_t)updateMakeup:(nullable id<PLSTEffectModel>)makeup type:(st_makeup_type)type;

/*!
 @method
 @abstract 更新美妆强度
 
 @param intensity 强度(0-1)
 @param type 美妆类型
 
 @since v1.0.0
 */
- (void)updateMakeupIntensity:(float)intensity type:(st_makeup_type)type ;

/*!
 @method
 @abstract 更新贴纸，传空取消贴纸
 
 @param sticker .
 
 @since v1.0.0
 */
- (st_result_t)updateSticker:(nullable id<PLSTEffectModel>)sticker;

/*!
 @method
 @abstract 更新美颜强度
 
 @param intensity 强度(根据不同类型有[0 ~ 1]或[-1 ~ 1])
 @param type 美颜类型
 
 @since v1.0.0
 */
- (st_result_t)updateBeautify:(float)intensity type:(st_beautify_type)type;

/*!
 @method
 @abstract 在处理队列里同步运行
 
 @param block .
 
 @since v1.0.0
 */
- (void)runSyncOnProcessingQueue:(void (^)(void))block;

/*!
 @method
 @abstract 在处理队列里异步运行
 
 @param block .
 
 @since v1.0.0
 */
- (void)runAsyncOnProcessingQueue:(void (^)(void))block;


/*!
 @method
 @abstract 处理pixelbuffer， 仅支持BGRA格式
 
 @param buffer 像素buffer
 @param camOrt 视频方向
 @param res detector检测结果
 
 @since v1.0.0
 */
- (void)processBuffer:(CVPixelBufferRef)buffer
    cameraOrientation:(AVCaptureVideoOrientation)camOrt
         detectResult:(st_mobile_human_action_t*)res;


/*!
 @method
 @abstract 处理pixelbuffer， 仅支持BGRA格式
 
 @param buffer 像素buffer
 @param camOrt 视频方向
 @param res detector检测结果
 
 @since v1.0.0
 */
- (void)processBuffer2:(CVPixelBufferRef)buffer
    cameraOrientation:(AVCaptureVideoOrientation)camOrt
         detectResult:(st_mobile_human_action_t*)res;


/*!
 @method
 @abstract 处理纹理, 若用户直接调用此方法请确保inputtexture所在的OpenGL context和初始化manager的context一致
 
 @param inputTexture 输入纹理
 @param width 纹理宽度
 @param height 纹理高度
 @param camOrt 视频方向
 @param res detector检测结果
 
 @since v1.0.0
 */
- (GLuint)processTexture:(GLuint)inputTexture
                   width:(int)width
                  height:(int)height
       cameraOrientation:(AVCaptureVideoOrientation)camOrt
            detectResult:(st_mobile_human_action_t*)res;

@end

NS_ASSUME_NONNULL_END
