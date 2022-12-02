//
//  QNAudienceController.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/6.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNBaseRTCController.h"

NS_ASSUME_NONNULL_BEGIN

@class RoomHostView,OnlineUserView,ImageButtonView,BottomMenuView,LinkStateView,ExplainingGoodView,PLPlayer,GoodsModel;

@interface QNAudienceController : QNBaseRTCController


@property (nonatomic, strong) LinkStateView *linkSView;
@property (nonatomic, strong) ExplainingGoodView *goodView;
@property (nonatomic, strong) PLPlayer *player;
//商品点击回调
@property (nonatomic, copy) void (^goodClickedBlock)(GoodsModel *itemModel);

@end

NS_ASSUME_NONNULL_END
