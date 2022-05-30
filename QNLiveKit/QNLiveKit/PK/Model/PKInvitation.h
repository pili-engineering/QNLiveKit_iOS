//
//  PKInvitation.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <Foundation/Foundation.h>
#import "QNLiveUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKInvitation : NSObject

@property (nonatomic, strong)QNLiveUser *initiator;

@property (nonatomic, strong)QNLiveUser *receiver;

@property (nonatomic, copy)NSString *invitationId;

@property (nonatomic, copy)NSString *initiatorRoomId;

@property (nonatomic, copy)NSString *receiverRoomId;

@property (nonatomic, copy)NSString *extensions;

@end

NS_ASSUME_NONNULL_END
