//
//  QNLiveRoomInfo.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveTypeDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveUser;

//房间信息model

@interface QNLiveRoomInfo : NSObject
@property (nonatomic, copy)NSString *chatId;
@property (nonatomic, copy)NSString *coverUrl;
@property (nonatomic, copy)NSString *liveId;
@property (nonatomic, copy)NSString *notice;
@property (nonatomic, copy)NSString *onlineCount;
@property (nonatomic, assign)QNLiveRoomStatus status;
@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *extensions;
@property (nonatomic, strong)QNLiveUser *roomHost;

@end

NS_ASSUME_NONNULL_END
