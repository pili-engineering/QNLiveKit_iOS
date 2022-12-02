//
//  LinkInvitation.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface LinkInvitation : NSObject

@property (nonatomic, strong)QNLiveUser *initiator;

@property (nonatomic, strong)QNLiveUser *receiver;

@property (nonatomic, copy)NSString *initiatorRoomId;

@property (nonatomic, copy)NSString *receiverRoomId;

@property (nonatomic, copy)NSString *extensions;
//连麦类型  用户向主播连麦  / 主播跨房连麦
@property (nonatomic, assign)QNLinkType linkType;

@end

NS_ASSUME_NONNULL_END
