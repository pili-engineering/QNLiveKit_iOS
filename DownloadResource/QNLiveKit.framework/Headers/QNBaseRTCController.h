//
//  QNBaseRTCController.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo,QNLivePushClient,QNLiveRoomClient,QNChatRoomService,LiveChatRoom,QNLinkMicService,QNMergeOption,QNPKService,QRenderView,FDanmakuView;

@interface QNBaseRTCController : UIViewController

@property (nonatomic, strong) QRenderView *preview;//自己画面的预览视图
@property (nonatomic, strong) UIView *renderBackgroundView;//上面只能添加视频流画面
@property (nonatomic,strong) QNLiveRoomInfo *roomInfo;
@property (nonatomic, strong) QNChatRoomService *_Nullable chatService;
@property (nonatomic, strong) LiveChatRoom *chatRoomView;
@property (nonatomic, strong) FDanmakuView *danmakuView;
@property (nonatomic, strong) QNLinkMicService *_Nullable linkService;
@property (nonatomic, strong) QNPKService *_Nullable pkService;

//获取某人的画面
- (QRenderView *)getUserView:(NSString *)uid;

//移除所有远端view
- (void)removeRemoteUserView;

@end

NS_ASSUME_NONNULL_END