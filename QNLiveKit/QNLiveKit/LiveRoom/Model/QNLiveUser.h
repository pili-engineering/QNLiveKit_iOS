//
//  QNLiveUser.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNLiveUser : NSObject

@property (nonatomic, copy)NSString *uid;
@property (nonatomic, copy)NSString *nick;
@property (nonatomic, copy)NSString *extensions;
@property (nonatomic, copy)NSString *qnImUid;

@end

NS_ASSUME_NONNULL_END
