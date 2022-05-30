//
//  QNPersonInfoModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//用户信息Model
@interface QNPersonInfoModel : NSObject

@property (nonatomic, copy) NSString *accountId;

@property (nonatomic, copy) NSString *phone;
//昵称
@property (nonatomic, copy) NSString *nickname;
//头像
@property (nonatomic, copy) NSString *avatar;

@end

NS_ASSUME_NONNULL_END
