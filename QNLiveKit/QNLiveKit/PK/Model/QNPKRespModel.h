//
//  QNPKRespModel.h
//  QNLiveKit
//
//  Created by xiaodao on 2023/6/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//PK建连响应数据
@interface QNPKRespModel : NSObject

//PK会话ID
@property (nonatomic, copy) NSString *sessionId;
//PK状态
@property (nonatomic, assign) NSInteger status;
//pkToken
@property (nonatomic, copy) NSString *pkToken;

@end

NS_ASSUME_NONNULL_END
