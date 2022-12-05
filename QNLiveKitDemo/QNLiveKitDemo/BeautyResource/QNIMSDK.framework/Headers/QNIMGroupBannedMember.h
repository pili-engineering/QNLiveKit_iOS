//
//  QNIMGroupBannedMember.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMGroupBannedMember : NSObject

@property (nonatomic, readonly) NSInteger uid;
@property (nonatomic, copy, readonly) NSString *groupNickname;
@property (nonatomic, readonly) long long createTime;
@property (nonatomic, readonly) long long expiredTime;

@end

NS_ASSUME_NONNULL_END
