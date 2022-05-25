//
//  PubChatModel.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *action_welcome = @"liveroom-welcome";
static NSString *action_bye = @"liveroom-bye-bye";
static NSString *action_like = @"liveroom-like";
static NSString *action_puchat = @"liveroom-pubchat";
static NSString *action_pubchat_custom = @"liveroom-pubchat-custom";

@class QNLiveUser;

@interface PubChatModel : NSObject

@property (nonatomic, copy)NSString *action;
@property (nonatomic, strong)QNLiveUser *sendUser;
@property (nonatomic, copy)NSString *content;
@property (nonatomic, copy)NSString *senderRoomId;
@property (nonatomic, copy)NSString *extensions;
//获取消息类型
- (NSString *)getMsgAction;
@end

NS_ASSUME_NONNULL_END
