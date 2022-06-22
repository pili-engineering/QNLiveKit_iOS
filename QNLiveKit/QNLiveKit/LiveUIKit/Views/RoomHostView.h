//
//  RoomHostView.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import "QLiveView.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//房主槽位

@class QNLiveRoomInfo;

@interface RoomHostView : QLiveView

- (void)updateWith:(QNLiveRoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END
