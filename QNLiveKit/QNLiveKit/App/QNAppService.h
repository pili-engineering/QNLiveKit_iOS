//
//  QNAppService.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/12/14.
//

#import <Foundation/Foundation.h>
#import "QNLiveTypeDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNAppInfo : NSObject

@property (nonatomic, copy) NSString *IMAppID;

@end

typedef void (^QNGetAppInfoComplete)(QNAppInfo * appInfo);

@interface QNAppService : NSObject


/// 获取应用的全局配置信息
/// @param complete 成功回调
/// @param failue 失败回调
+ (void)getAppInfoWithComplete:(QNGetAppInfoComplete)complete failure:(QNFailureCallback)failue;

@end

NS_ASSUME_NONNULL_END
