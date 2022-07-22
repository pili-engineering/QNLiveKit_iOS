//
//  QNBaseRTCController.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo,QNLivePushClient,QNLiveRoomClient,QNChatRoomService,LiveChatRoom,QNMergeOption,QPKService,QRenderView,FDanmakuView,QLinkMicService;

@interface QNBaseRTCController : UIViewController

@property (nonatomic, strong) QRenderView *preview;//自己画面的预览视图
@property (nonatomic, strong) QRenderView *remoteView;//远端画面
@property (nonatomic, strong) UIView *renderBackgroundView;//上面只能添加视频流画面
@property (nonatomic,strong) QNLiveRoomInfo *roomInfo;
@property (nonatomic, strong) QNChatRoomService * chatService;
@property (nonatomic, strong) LiveChatRoom *chatRoomView;
@property (nonatomic, strong) FDanmakuView *danmakuView;
@property (nonatomic, strong) QPKService * pkService;
@property (nonatomic, strong) QLinkMicService *linkService;


//获取某人的画面
- (QRenderView *)getUserView:(NSString *)uid;

//移除所有远端view
- (void)removeRemoteUserView;

@end

NS_ASSUME_NONNULL_END
