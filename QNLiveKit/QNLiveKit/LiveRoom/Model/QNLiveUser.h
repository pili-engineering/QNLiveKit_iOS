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
@property (nonatomic, copy)NSString *user_id;
@property (nonatomic, copy)NSString *nick;
@property (nonatomic, strong)NSArray <Extension *> *extension;
@property (nonatomic, copy)NSString *avatar;
@property (nonatomic, copy)NSString *im_userid;
@property (nonatomic, copy)NSString *im_username;
@end

NS_ASSUME_NONNULL_END
