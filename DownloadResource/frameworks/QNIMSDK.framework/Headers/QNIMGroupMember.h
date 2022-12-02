//
//  QNIMGroupMember.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMGroupMember : NSObject

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *groupNickname;
@property (nonatomic, assign) long long createTime;

@end

NS_ASSUME_NONNULL_END
