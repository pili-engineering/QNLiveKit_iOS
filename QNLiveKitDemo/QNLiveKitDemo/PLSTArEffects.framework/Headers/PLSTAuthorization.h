//
//  PLSTAuthorization.h
//  PLSTArEffects
//
//  Created by 李政勇 on 2020/6/16.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "core/include/st_mobile_common.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @class PLSTAuthorization
 @abstract 鉴权类
 */
@interface PLSTAuthorization : NSObject

/*!
 @method 
 @abstract 检测鉴权信息
 
 @param data 鉴权文件数据
 
 @since v1.0.0
 */
+ (st_result_t)checkLicenseWithData:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
