//
//  PubChatModel.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/2.
//

#import <Foundation/Foundation.h>
#import "QNLiveUser.h"
#import "Extension.h"

NS_ASSUME_NONNULL_BEGIN

//公屏消息
@interface PubChatModel : NSObject

@property(nonatomic, strong) QNLiveUser *sendUser;

@property(nonatomic, strong) NSMutableArray <Extension *> *extensions;

@property(nonatomic, copy) NSString *content;//消息内容

@property(nonatomic, copy) NSString *senderRoomId;

@property(nonatomic, copy) NSString *action;

@end

NS_ASSUME_NONNULL_END
