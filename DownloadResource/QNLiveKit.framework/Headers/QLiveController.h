//
//  QLiveController.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import "QNBaseRTCController.h"

NS_ASSUME_NONNULL_BEGIN

@class RoomHostView,OnlineUserView,ImageButtonView,BottomMenuView;

@interface QLiveController : QNBaseRTCController

@property (nonatomic, strong) RoomHostView *roomHostView;//房主槽位
@property (nonatomic, strong) OnlineUserView *onlineUserView;//右上角在线人数槽位
@property (nonatomic, strong) ImageButtonView *pubchatView;//左下角聊天框槽位
@property (nonatomic, strong) BottomMenuView *bottomMenuView;//右下角操作槽位


@end

NS_ASSUME_NONNULL_END
