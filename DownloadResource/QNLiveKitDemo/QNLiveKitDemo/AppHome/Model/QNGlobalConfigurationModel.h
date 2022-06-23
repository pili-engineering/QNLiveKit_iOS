//
//  QNGlobalConfigurationModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNWelcomeModel;

//全局配置信息Model
@interface QNGlobalConfigurationModel : NSObject
//欢迎页信息
@property (nonatomic, strong) QNWelcomeModel *welcome;

@end

@interface QNWelcomeModel : NSObject
//图片链接
@property (nonatomic, copy) NSString *image;
//跳转链接
@property (nonatomic, copy) NSString *url;

@end





NS_ASSUME_NONNULL_END
