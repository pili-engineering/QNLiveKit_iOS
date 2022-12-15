//
//  QLiveConfig.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 低代码SDK 配置信息
@interface QLiveConfig : NSObject


/// 低代码服务对外域名配置，形式如下：
/// https://qlive-api.com:8080
@property (nonatomic, copy) NSString *serverURL;

@end

NS_ASSUME_NONNULL_END
