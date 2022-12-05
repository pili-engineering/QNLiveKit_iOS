//
//  PLSTUtil.h
//  PLSTArEffects
//
//  Created by 李政勇 on 2020/6/17.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "core/include/st_mobile_common.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @class PLSTUtil
 @abstract 辅助类
 */
@interface PLSTUtil : NSObject

/*!
 @property motionMgr
 @brief .
 
 @since v1.0.0
 */
@property(nonatomic, strong, readonly) CMMotionManager* motionMgr;

/*!
 @method shared
 @abstract .
 
 @since v1.0.0
 */
+ (instancetype)shared;

/*!
 @method startUpdate
 @abstract 开始更新motion和设备方向
 
 @since v1.0.0
 */
- (void)startUpdate;

/*!
 @method stopUpdate
 @abstract 停止更新motion和设备方向
 
 @since v1.0.0
 */
- (void)stopUpdate;

/*!
 @method getDeviceOrientation
 @abstract 获取当前设备方向
 
 @since v1.0.0
 */
- (UIDeviceOrientation)getDeviceOrientation;

/*!
 @method 
 @abstract 根据视频方向预测图片将人脸转正需要旋转的角度
 
 @param cot 视频方向
 
 @since v1.0.0
 */
- (st_rotate_type)getRotateWithCameraOrientation:(AVCaptureVideoOrientation)cot;

@end

NS_ASSUME_NONNULL_END
