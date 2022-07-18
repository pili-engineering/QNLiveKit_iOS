//
//  BeautyLiveViewController.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/30.
//

#import <UIKit/UIKit.h>
#import "BeautyBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo,QNLivePushClient,QNLiveRoomClient,QNChatRoomService,LiveChatRoom,QNMergeOption,QPKService,QRenderView,FDanmakuView,QLinkMicService,RoomHostView,OnlineUserView,ImageButtonView,BottomMenuView,STBaseViewController;

@interface BeautyLiveViewController : BeautyBaseController

@property (nonatomic, strong) RoomHostView *roomHostView;//房主槽位
@property (nonatomic, strong) OnlineUserView *onlineUserView;//右上角在线人数槽位
@property (nonatomic, strong) ImageButtonView *pubchatView;//左下角聊天框槽位
@property (nonatomic, strong) BottomMenuView *bottomMenuView;//右下角操作槽位

@property (nonatomic, strong) QRenderView *preview;//自己画面的预览视图
@property (nonatomic, strong) UIView *renderBackgroundView;//上面只能添加视频流画面
@property (nonatomic,strong) QNLiveRoomInfo *roomInfo;
@property (nonatomic, strong) QNChatRoomService * chatService;
@property (nonatomic, strong) LiveChatRoom *chatRoomView;
@property (nonatomic, strong) FDanmakuView *danmakuView;
@property (nonatomic, strong) QPKService * pkService;
@property (nonatomic, strong) QLinkMicService *linkService;

@end

NS_ASSUME_NONNULL_END
