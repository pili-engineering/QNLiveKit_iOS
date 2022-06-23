//
//  QNAppConficModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMInfoModel : NSObject

@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *userToken;
@end

@interface QNWelcomeModel : NSObject
//启动图片链接
@property (nonatomic, copy) NSString *image;
//跳转链接
@property (nonatomic, copy) NSString *url;
@end

@interface QNAppConficModel : NSObject
//欢迎页信息
@property (nonatomic, strong) QNWelcomeModel *welcome;
//im配置信息
@property (nonatomic, copy) QNIMInfoModel *imConfig;

//获取最新版本
+ (void)getAppVersion:(void (^)(NSURL *packagePage))complete;

@end

NS_ASSUME_NONNULL_END
