//
//  RoomHostSlot.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import "QNInternalViewSlot.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//房主槽位置

@class QNLiveRoomInfo;

@interface RoomHostSlot : QNInternalViewSlot

- (void)updateWith:(QNLiveRoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END
