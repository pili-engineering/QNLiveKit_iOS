//
//  QNPersonalViewModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNPersonInfoModel;

@interface QNPersonalViewModel : NSObject
//获取用户信息
+ (void)requestPersonInfo:(void (^)(QNPersonInfoModel *personInfo))success;
//修改用户信息
+ (void)changePersonInfoWithNickName:(NSString *)nickName success:(void (^)(QNPersonInfoModel *personInfo))success;

@end

NS_ASSUME_NONNULL_END
