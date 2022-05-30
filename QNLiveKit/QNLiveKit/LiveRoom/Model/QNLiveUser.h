//
//  QNLiveUser.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "Extension.h"
NS_ASSUME_NONNULL_BEGIN

@interface QNLiveUser : NSObject
@property (nonatomic, copy)NSString *anchor_id;
@property (nonatomic, copy)NSString *nickname;
@property (nonatomic, strong)NSArray <Extension *> *extension;
@property (nonatomic, copy)NSString *avatar;
@property (nonatomic, copy)NSString *qnImUid;
@end

NS_ASSUME_NONNULL_END
