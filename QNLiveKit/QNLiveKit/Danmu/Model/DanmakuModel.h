//
//  DanmakuModel.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveUser;
@interface DanmakuModel : NSObject
@property (nonatomic, copy)NSString *action_danmu;
@property (nonatomic, strong)QNLiveUser *sendUser;
@property (nonatomic, copy)NSString *content;
@property (nonatomic, copy)NSString *senderRoomId;
@property (nonatomic, copy)NSString *extensions;

@end

NS_ASSUME_NONNULL_END
