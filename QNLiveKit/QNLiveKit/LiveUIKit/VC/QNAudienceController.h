//
//  QNAudienceController.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/6.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNBaseRTCController.h"

NS_ASSUME_NONNULL_BEGIN

@class RoomHostView,OnlineUserView,ImageButtonView,BottomMenuView,LinkStateView;

@interface QNAudienceController : QNBaseRTCController

@property (nonatomic, strong) RoomHostView *roomHostView;
@property (nonatomic, strong) OnlineUserView *onlineUserView;
@property (nonatomic, strong) ImageButtonView *pubchatView;
@property (nonatomic, strong) BottomMenuView *bottomMenuView;
@property (nonatomic, strong) LinkStateView *linkSView;

@end

NS_ASSUME_NONNULL_END
