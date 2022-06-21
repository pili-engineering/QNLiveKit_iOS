//
//  OnlineUserComponent.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import "QLiveComponent.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

//右上角在线人数槽位
@interface OnlineUserComponent : QLiveComponent

- (void)updateWith:(QNLiveRoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END
