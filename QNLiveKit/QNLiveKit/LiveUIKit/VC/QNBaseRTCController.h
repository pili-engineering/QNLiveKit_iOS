//
//  QNBaseRTCController.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo,QNLivePushClient,QNLiveRoomClient,QNChatRoomService,LiveChatRoom,QNLinkMicService,QNMergeOption,QNPKService;

@interface QNBaseRTCController : UIViewController

@property (nonatomic, strong) QNGLKView *preview;//自己画面的预览视图
@property (nonatomic, strong) UIView *renderBackgroundView;//上面只能添加视频流画面
@property (nonatomic,strong) QNLiveRoomInfo *roomInfo;
@property (nonatomic, strong) QNLivePushClient *pushClient;
@property (nonatomic, strong) QNLiveRoomClient *roomClient;
@property (nonatomic, strong) QNChatRoomService *chatService;
@property (nonatomic, strong) LiveChatRoom *chatRoomView;
@property (nonatomic, strong) QNLinkMicService *linkService;
@property (nonatomic, strong) QNPKService *pkService;
@property (nonatomic, strong) QNMergeOption *option;

@end

NS_ASSUME_NONNULL_END
