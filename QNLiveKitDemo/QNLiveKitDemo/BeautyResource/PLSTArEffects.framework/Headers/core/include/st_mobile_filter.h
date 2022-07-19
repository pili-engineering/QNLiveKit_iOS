#ifndef INCLUDE_STMOBILE_ST_MOBILE_FILTER_H_
#define INCLUDE_STMOBILE_ST_MOBILE_FILTER_H_

#include "st_mobile_common.h"


/// @defgroup st_mobile_gl_filter
/// @brief
/// 滤镜接口主要包括滤镜相关功能，相关接口定义在st_mobile_filter.h文件中
/// 目前该接口支持RGBA纹理格式数据输入，具体细节请参考接口文档或示例代码
///
/// @code
/// st_result_t ret = ST_OK;
/// st_handle_t handle = NULL;
/// ret = st_mobile_gl_filter_create(&handle);
/// ret = st_mobile_gl_filter_set_style(handle, "../filter.zip");
/// st_mobile_gl_filter_set_param(handle, ST_FILTER_STRENGTH, 1.0f);
/// ret = st_mobile_gl_filter_process_texture(handle, in_tex, width, height, out_tex);
/// st_mobile_gl_filter_destroy(handle);
/// @endcode
///
/// @note
/// st_mobile_filter.h 在8.0版本已经被废弃，为了获取更高性能或者更多新功能，请使用 st_mobile_effect.h
///
/// @{

/// @brief 创建OpenGL滤镜句柄
/// @param [out] handle 初始化的滤镜句柄
/// @return 成功返回ST_OK, 错误则返回错误码
ST_SDK_API st_result_t
st_mobile_gl_filter_create(
    st_handle_t *handle
);

/// @brief 设置滤镜风格, 必须在OpenGL线程中调用
/// @param [in] handle 已初始化的滤镜句柄
/// @param [in] style_model_path 滤镜风格模型路径
/// @return 成功返回ST_OK, 错误则返回错误码
ST_SDK_API st_result_t
st_mobile_gl_filter_set_style(
    st_handle_t handle,
    const char* style_model_path
);

/// @brief 设置滤镜风格
/// @param [in] handle 已初始化的滤镜句柄
/// @param [in] buffer 模型缓存起始地址
/// @param [in] buffer_size 模型缓存大小
/// @return 成功返回ST_OK，错误返回错误代码
ST_SDK_API st_result_t
st_mobile_gl_filter_set_style_from_buffer(
st_handle_t handle,
const unsigned char* buffer,
unsigned int buffer_size
);

///@brief 滤镜参数类型
typedef enum {
    ST_GL_FILTER_STRENGTH,                  ///< 滤镜效果强度, 根据实际场景调节, 取值范围[0, 1.0], 推荐使用1.0, 默认值1.0
    ST_GL_FILTER_HAS_STYLE,                 ///< 当前是否设置了有效的滤镜素材，只有get时有效，大于0，存在有效素材，小于0，不存在有效素材
    ST_GL_FILTER_PARAM_SYNC_OUTPUT = 1000,  /// 同步输出，传入非0值，将禁用内部的双缓冲读取渲染结果的机制，否则在PC上使用双缓冲读取渲染结果（性能高、结果差一帧）
} st_gl_filter_type;

/// @brief 设置滤镜参数
/// @param [in] handle 已初始化的滤镜句柄
/// @param [in] type 滤镜参数关键字, 例如ST_GL_FILTER_STRENGTH
/// @param [in] value 参数取值
/// @return 成功返回ST_OK, 错误则返回错误码, 错误码定义在st_mobile_common.h中, 如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_gl_filter_set_param(
    st_handle_t handle,
    st_gl_filter_type type,
    float value
);

/// @brief 获取滤镜参数
/// @param [in] handle 已初始化的滤镜句柄
/// @param [in] type 滤镜参数关键字, 例如ST_GL_FILTER_STRENGTH
/// @param [out] value 参数取值
/// @return 成功返回ST_OK, 错误则返回错误码, 错误码定义在st_mobile_common.h中, 如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_gl_filter_get_param(
    st_handle_t handle,
    st_gl_filter_type type,
    float* value
);

/// @brief 对OpenGL中的纹理进行滤镜处理, 必须在OpenGL线程中调用
/// @param[in] handle 已初始化的滤镜句柄
/// @param[in] textureid_src 待处理的纹理id, 仅支持RGBA纹理
/// @param[in] image_width 输入纹理的宽度(以像素为单位)
/// @param[in] image_height 输入纹理的高度(以像素为单位)
/// @param[in] textureid_dst 处理后的纹理id, 仅支持RGBA纹理; 不能和textureid_src使用同一个纹理
/// @return 成功返回ST_OK, 错误则返回错误码, 错误码定义在st_mobile_common.h中, 如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_gl_filter_process_texture(
    st_handle_t handle,
    unsigned int textureid_src,
    int image_width, int image_height,
    unsigned int textureid_dst
);

/// @brief 对OpenGL中的纹理进行滤镜处理, 并输出buffer. 必须在OpenGL线程中调用
/// @param[in] handle 已初始化的滤镜句柄
/// @param[in] textureid_src 待处理的纹理id, 仅支持RGBA纹理
/// @param[in] image_width 输入纹理的宽度(以像素为单位)
/// @param[in] image_height 输入纹理的高度(以像素为单位)
/// @param[in] textureid_dst 处理后的纹理id, 仅支持RGBA纹理; 不能和textureid_src使用同一个纹理
/// @param[out] img_out 输出图像数据数组, 需要用户分配内存, 如果是null, 不输出buffer
/// @param[in] fmt_out 输出图片的类型, 支持NV21, NV12, BGR, BGRA, RGBA格式.
/// @return 成功返回ST_OK, 错误则返回错误码,错误码定义在st_mobile_common.h中,如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_gl_filter_process_texture_and_output_buffer(
    st_handle_t handle,
    unsigned int textureid_src,
    int image_width, int image_height,
    unsigned int textureid_dst,
    unsigned char *img_out, st_pixel_format fmt_out
);

/// @brief 对图像buffer做滤镜处理, 必须在OpenGL线程中调用
/// @param[in] handle 已初始化的滤镜句柄
/// @param[in] img_in 输入图片的数据数组
/// @param[in] fmt_in 输入图片的类型, 支持NV21, NV12, BGR, BGRA, RGBA, YUV420P格式
/// @param[in] image_width 输入图片的宽度(以像素为单位)
/// @param[in] image_height 输入图片的高度(以像素为单位)
/// @param[in] image_stride 用于检测的图像的跨度(以像素为单位), 即每行的字节数; 目前仅支持字节对齐的padding, 不支持roi
/// @param[out] img_out 输出图像数据数组
/// @param[in] fmt_out 输出图片的类型, 支持NV21, NV12, BGR, BGRA, RGBA, YUV420P格式
/// @return 成功返回ST_OK, 错误则返回错误码, 错误码定义在st_mobile_common.h中, 如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_gl_filter_process_buffer(
    st_handle_t handle,
    const unsigned char *img_in, st_pixel_format fmt_in, int image_width, int image_height, int image_stride,
    unsigned char *img_out, st_pixel_format fmt_out
);

/// @brief 重置内部process texture接口output buffer时的双缓冲（PC平台），避免在传入texture时域上不连续时的闪一阵旧结果问题
/// @param[in] handle 已初始化的滤镜句柄
ST_SDK_API st_result_t
st_mobile_gl_filter_reset_output_buffer_cache(
    st_handle_t handle
);

/// @brief 释放OpenGL滤镜句柄, 必须在OpenGL线程中调用
/// @param[in] handle 已初始化的滤镜句柄
ST_SDK_API void
st_mobile_gl_filter_destroy(
    st_handle_t handle
);

/// @}

#endif // INCLUDE_STMOBILE_ST_MOBILE_FILTER_H_
