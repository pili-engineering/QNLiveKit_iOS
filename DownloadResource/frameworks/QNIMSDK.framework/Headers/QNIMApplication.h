//
//  QNIMApplication.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    QNIMApplicationStatusPending, //请求待处理
    QNIMApplicationStatusAccepted, //请求已接受
    QNIMApplicationStatusDeclined, //请求已拒绝
}QNIMApplicationStatus;

@interface QNIMApplication : NSObject
@property (nonatomic,assign) long long rosterId;
@property (nonatomic,copy) NSString *reason;
@property (nonatomic,assign) QNIMApplicationStatus applicationStatus;
@property (nonatomic, assign) long long expireTime;
@end

NS_ASSUME_NONNULL_END
