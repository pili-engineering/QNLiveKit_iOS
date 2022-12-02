//
//  QNIMHostConfig.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMHostConfig : NSObject

@property (nonatomic,copy) NSString *imHost;
@property (nonatomic,assign) int mPort;
@property (nonatomic,copy) NSString *restHost;

- (instancetype)initWithRestHostConfig:(NSString *)restHost imPort:(int)imPort imHost:(NSString *)imHost;

@end

NS_ASSUME_NONNULL_END
