//
//  QNIMGroupApplication.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    QNIMGroupApplicationStatusPending,
    QNIMGroupApplicationStatusAccepted,
    QNIMGroupApplicationStatusDeclined,
} QNIMGroupApplicationStatus;

NS_ASSUME_NONNULL_BEGIN

@interface QNIMGroupApplication : NSObject

@property (nonatomic,assign, readonly) long long groupId;
@property (nonatomic,assign, readonly) long long applicationId;
@property (nonatomic,assign, readonly) long long expiredTime;
@property (nonatomic,copy, readonly) NSString *reason;
@property (nonatomic,assign, readonly) QNIMGroupApplicationStatus applicationStatus;

@end

NS_ASSUME_NONNULL_END
