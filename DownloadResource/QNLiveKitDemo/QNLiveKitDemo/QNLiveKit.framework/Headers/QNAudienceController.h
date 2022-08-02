//
//  QNAudienceController.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/6.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNBaseRTCController.h"

NS_ASSUME_NONNULL_BEGIN

@class RoomHostView,OnlineUserView,ImageButtonView,BottomMenuView,LinkStateView,ExplainingGoodView,PLPlayer;

@interface QNAudienceController : QNBaseRTCController

@property (nonatomic, strong) RoomHostView *roomHostView;
@property (nonatomic, strong) OnlineUserView *onlineUserView;
@property (nonatomic, strong) ImageButtonView *pubchatView;
@property (nonatomic, strong) BottomMenuView *bottomMenuView;
@property (nonatomic, strong) LinkStateView *linkSView;
@property (nonatomic, strong) ExplainingGoodView *goodView;
@property (nonatomic, strong) PLPlayer *player;

@end

NS_ASSUME_NONNULL_END
