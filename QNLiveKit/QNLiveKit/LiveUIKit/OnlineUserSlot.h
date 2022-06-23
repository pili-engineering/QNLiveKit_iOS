//
//  OnlineUserSlot.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import "QNInternalViewSlot.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

@interface OnlineUserSlot : QNInternalViewSlot

- (void)updateWith:(QNLiveRoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END
