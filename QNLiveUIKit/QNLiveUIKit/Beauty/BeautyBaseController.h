//
//  BeautyBaseController.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/18.
//

#import <QNLiveKit/QNLiveKit.h>
#import "UIViewController+QViewController.h"

#ifdef useBeauty
#import "STBaseViewController.h"
#endif
@class QNLiveRoomInfo,QNLivePushClient,QNLiveRoomClient,QNChatRoomService,LiveChatRoom,QNMergeOption,QPKService,QRenderView,FDanmakuView,QLinkMicService,PLSTEffectManager,PLSTDetector;

NS_ASSUME_NONNULL_BEGIN

#ifdef useBeauty
@interface BeautyBaseController : STBaseViewController
#else
@interface BeautyBaseController : UIViewController
#endif


@property (nonatomic, strong) QRenderView *preview;//自己画面的预览视图
@property (nonatomic, strong) QRenderView *remoteView;//远端画面
@property (nonatomic, strong) UIView *renderBackgroundView;//上面只能添加视频流画面
@property (nonatomic,strong) QNLiveRoomInfo *roomInfo;
@property (nonatomic, strong) QNChatRoomService * chatService;
@property (nonatomic, strong) LiveChatRoom *chatRoomView;
@property (nonatomic, strong) FDanmakuView *danmakuView;
@property (nonatomic, strong) QPKService * pkService;
@property (nonatomic, strong) QLinkMicService *linkService;

//关闭直播间的回调
@property (nonatomic, copy) void (^closeClickedBlock)(QNLiveRoomInfo *roomInfo);

//暂时离开直播间的回调
@property (nonatomic, copy) void (^leaveClickedBlock)(QNLiveRoomInfo *roomInfo);

//商汤特效
@property (nonatomic, strong) UIButton *effectButton;
@property (nonatomic, assign) BOOL isNullSticker;

@property (nonatomic, assign) BOOL isFirstWholeMakeUp;

-(void)setupSenseAR;
//获取某人的画面
- (QRenderView *)getUserView:(NSString *)uid;

//移除所有远端view
- (void)removeRemoteUserView;

- (void)updateFirstEnterUI;


@end

NS_ASSUME_NONNULL_END
