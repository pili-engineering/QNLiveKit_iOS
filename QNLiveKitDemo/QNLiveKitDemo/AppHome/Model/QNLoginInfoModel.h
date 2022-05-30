//
//  QNLoginInfoModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNImconfigModel : NSObject

@property (nonatomic, copy) NSString *imToken;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *imUsername;

@property (nonatomic, copy) NSString *imPassword;

@property (nonatomic, copy) NSString *imUid;

@end

@interface QNLoginInfoModel : NSObject
//登录token
@property (nonatomic, copy) NSString *loginToken;
//用户ID
@property (nonatomic, copy) NSString *accountId;

@property (nonatomic, copy) NSString *nickname;
//im配置信息
@property (nonatomic, strong) QNImconfigModel *imConfig;

@end

NS_ASSUME_NONNULL_END

