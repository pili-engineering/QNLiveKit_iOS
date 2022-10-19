//
//  OnlineUserView.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import "QLiveView.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

//右上角在线人数槽位
@interface OnlineUserView : QLiveView

- (void)updateWith:(QNLiveRoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END
